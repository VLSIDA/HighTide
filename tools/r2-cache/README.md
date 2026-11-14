# R2-backed Bazel remote cache (experiment)

A Cloudflare Worker that implements Bazel's [HTTP remote cache
protocol](https://bazel.build/remote/caching#http-caching) directly against an
R2 bucket. Goal: serve cache *reads* to any HighTide user from Cloudflare's
edge (free egress, no load on donut), and eventually remove the tunnel's
100 MB upload ceiling by writing large artifacts over the R2 S3 API.

```
writers (donut, k8s)  --PUT /{ac,cas}/<sha>-->  Worker  -->  R2 bucket
readers (anyone)      --GET /{ac,cas}/<sha>-->  Worker  <--  R2 bucket
```

- **Reads:** anonymous, uncapped size, free egress.
- **Writes:** `Authorization: Basic` (bazel's `https://user:token@host` URL
  form) checked against the `CACHE_WRITE_TOKEN` Worker secret.
- **R2 keys** mirror the protocol paths: `ac/<sha256>`, `cas/<sha256>` —
  a plain layout any future frontend (or direct S3 writer) can share.

## One-time setup

```bash
cd tools/r2-cache
npx wrangler login                       # or export CLOUDFLARE_API_TOKEN=...
npx wrangler r2 bucket create hightide-bazel-cache
npx wrangler secret put CACHE_WRITE_TOKEN   # paste "user:token"
npx wrangler deploy
```

Note: enabling R2 on the account requires attaching a payment method even for
free-tier usage (10 GB-month storage, 1M writes, 10M reads free; beyond that
$0.015/GB-month, egress always free).

## Using it

Read-only (what external users would get):

```bash
bazel build --remote_cache=https://hightide-bazel-cache.<acct>.workers.dev \
    //designs/asap7/lfsr:lfsr_synth
```

Read-write (donut / k8s):

```bash
bazel build --remote_cache=https://USER:TOKEN@hightide-bazel-cache.<acct>.workers.dev \
    --remote_upload_local_results=true <target>
```

Keep `--remote_cache_compression` off against this endpoint (it's negated in
the test commands below): the Worker stores bytes verbatim, and mixing
zstd-compressed and raw clients on one bucket would corrupt reads.

## Smoke test

```bash
BASE=https://hightide-bazel-cache.<acct>.workers.dev
H=$(printf 'x%.0s' {1..64} | tr x 0)   # any 64-hex key
curl -fsS "$BASE/status"
curl -fsS -X PUT --data-binary hello "$BASE/cas/$H" -u USER:TOKEN
curl -fsS "$BASE/cas/$H"               # -> hello (no auth needed)
curl -s -o /dev/null -w '%{http_code}\n' -X PUT --data-binary nope "$BASE/cas/$H"  # -> 401
```

## Lifecycle rules (GC)

R2 has no LRU eviction, so the bucket carries two lifecycle rules (set via
`wrangler r2 bucket lifecycle add`, listable with `... lifecycle list`):

- `expire-stale-objects` — delete any object **120 days** after upload.
- `abort-stale-multipart` — abort incomplete multipart uploads after 7 days.

Age-based expiry is crude GC for a CAS: the Worker's PUT dedup never
refreshes an existing object's age, so even a hot blob expires at 120 days.
That costs one cache miss — the next writer build re-executes the action and
re-uploads — and bazel tolerates a missing CAS blob by falling back to local
execution, so expiry is never a correctness problem.

## Large blobs: the S3 backfill path

Confirmed empirically: Worker PUTs are capped at 100 MB on a free-plan zone
(50 MB → 201; 150 MB → instant 413 — same Cloudflare request-body limit as
the tunnel). **Reads are not capped.** The R2 **S3 API**
(`<account>.r2.cloudflarestorage.com`) bypasses the zone proxy entirely:
a 150 MB multipart upload takes ~5 s and reads back through the Worker
byte-identical.

So bazel uploads everything ≤100 MB natively through the Worker, and
**`s3-backfill.sh`** publishes the oversized blobs afterward: it walks the
local bazel disk cache (same `{ac,cas}/<2hex>/<hash>` content-addressed
layout), finds files above the Worker cap, and `aws s3 cp`s them into the
bucket's matching keys, skipping objects already present. Run it after any
local build of the big designs (bp_quad, bp_uno-sky130hd, partition_c, cnn).

S3 credentials are derived from any Cloudflare API token with R2 edit
permission — access key = token ID, secret = SHA-256 of the token value —
no extra dashboard step. They live in `~/.hightide-r2-s3-env`
(`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_ENDPOINT`), which the
script sources automatically.

## Known limits / next steps
- The bucket starts cold (the donut bazel-remote store is not directly
  importable) and is seeded organically: NRP k8s sweeps with write
  credentials repopulate it as designs build.
- Cutover (live since 2026-11-14): a zone Worker route on
  `cache.hightide-benchmarks.dev/*` intercepts requests at the edge, so the
  Worker now serves the canonical cache hostname. `CACHE_WRITE_TOKEN` is set
  to the same `user:token` pair the k8s Secret and writer configs already
  embed, so no client configuration changed. Rollback = delete the route;
  the tunnel and donut's bazel-remote still run untouched underneath.
- The Worker does not handle HTTP `Range` requests (full-object responses
  only). Bazel never sends ranges; add if ever needed.
