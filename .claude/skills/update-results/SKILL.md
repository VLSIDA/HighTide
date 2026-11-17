---
name: update-results
description: Refresh webpage/results.html, webpage/index.html (Design Portfolio platform badges), webpage/gallery.html, and webpage/figures/ to reflect each (platform, design) pair's latest cached build. Detects stale rows by comparing a per-row data-commit attribute to the design's most recent commit, then does ONE batched bazel build of all stale designs' lightweight _gallery targets against the (localhost, on the cache host) remote cache — using the build-event log for an authoritative cached/missing split — regenerates the gallery image at <design>_<platform>_<sha>.png, deletes the previous versioned image, and rewrites the table between RESULTS_START / RESULTS_END markers. Use after a build sweep lands new artifacts in the remote cache.
argument-hint: "[platform] [design]"
---

# Update results.html and gallery figures

Keeps `webpage/results.html` and `webpage/figures/` in sync with each design's latest cached `6_report.json`.  Each row pins a **commit SHA** (the most recent commit touching that design's BUILD/SDC/RTL); the gallery image is named with the same SHA so the row and image cannot drift.  Old image files are deleted as new versions land.

The user may have given a `[platform]` and/or `[design]` filter (`$0` / `$1`) — use the same matching semantics as `k8s/run.sh` (positional, with `--design` for design-only).  No filter = sweep everything.

**Operates on the `webpage` git worktree**, not whichever branch the user is currently on.  Find it with `git worktree list | awk '$3=="[webpage]"{print $1}'`.

## Step 1: Locate the webpage worktree and check it's clean

```bash
WT=$(git worktree list | awk '$3=="[webpage]"{print $1}')
test -n "$WT" || die "no webpage worktree found; create one with 'git worktree add ../webpage webpage'"
git -C "$WT" status --short
```

If the worktree has uncommitted changes (other than the ones you're about to make), warn the user and ask whether to proceed — don't blindly add to a dirty tree.

If `webpage` is behind `origin/webpage`, fast-forward it before doing any work:

```bash
git -C "$WT" pull --ff-only
```

## Step 2: (removed — image set is fully versioned)

The one-time canonical→`<design>_<platform>_<sha>` migration is complete: every per-design figure already carries a SHA component and the old canonical-name images no longer exist.  No migration is performed.  (The only un-versioned files left are infra figures — `HighTideFLOW`, `lighthouse`, `final_placement_*` — which are intentionally not per-design and must be left alone.)  Proceed directly to Step 3.

## Step 3: Determine the design list

```bash
bazel query '//designs/...' 2>/dev/null \
    | awk -F: '/_final$/ { sub(":.*", "", $0); print $0 }' \
    | sort -u
```

That yields entries like `//designs/asap7/cnn`.  Strip the prefix to get `<platform>/<design-path>`.  Apply `[platform]` / `[design]` filters if provided.

For each, derive:
- `platform` (first segment)
- `design_dir` (full path under `designs/`)
- `leaf` (last segment of `design_dir`)
- `bazel_target = //designs/<design_dir>:<leaf>_final`
- `gallery_target = //designs/<design_dir>:<leaf>_gallery`
- `report_path = bazel-bin/designs/<design_dir>/logs/<platform>/<top>/base/6_report.json` — `<top>` is whatever the design's `top` is, usually `<leaf>` but not always (e.g. lfsr's top is `lfsr_prbs_gen`).  Read it from `bazel query --output=build //designs/<design_dir>:<leaf>_final` if uncertain, or just glob `logs/<platform>/*/base/6_report.json`.

## Step 4: Compute the design SHA

For each (platform, design):

```bash
sha=$(git log -1 --format=%h -- \
    "designs/$design_dir/" \
    "designs/src/$leaf/" 2>/dev/null)
```

7 chars (default `%h`), matching GitHub's commit-link convention.  If the design has no `designs/src/<leaf>/` (no per-design RTL submodule, e.g. lfsr's RTL is in `designs/src/lfsr/` but for designs whose RTL lives elsewhere, just drop the second arg).

## Step 5a (PREFERRED since 2026-11): fetch from the R2 results index — no bazel

Jobs publish their reports and gallery image to a browsable prefix
(`results/<platform>/<design-path>/<git-sha>/` + a `latest` pointer; see
k8s/job-template.yaml and tools/fetch_results.sh). For each stale pair, try
the index FIRST:

```bash
./tools/fetch_results.sh <platform> <design-path> /tmp/res/<platform>-<design>
# -> 6_finish.rpt, 6_report.json, <leaf>_gallery.png + prints the git sha
```

- The printed sha IS the `data-commit` value for the row; if it matches the
  design's latest commit, the fetch is current — no bazel at all.
- Only fall back to Step 5's batched `_gallery` build for pairs with no
  published entry (anything last built before 2026-11-15, locally-built
  designs like bp_quad, or when `latest` lags the design's commit).
- Anonymous HTTP via https://cache.hightide-benchmarks.dev/results/... —
  works from any host, no credentials, no 100 MB concerns.

## Step 5: Refresh stale designs (batched `_gallery` build)

Parse `webpage/results.html` for existing rows.  Each row is keyed by `data-design` + `data-platform`; its current commit is `data-commit`.  A row is **stale** if `data-commit` ≠ the SHA from Step 4, or the row is missing entirely.

> **Two failure modes to avoid — the timeout must be *kept*, but applied correctly:**
> 1. **A per-design timeout that's too short on a *cold* server → false negatives.**  Cold Bazel analysis of the 56-design repo is ~250 s; a short per-design timeout SIGKILLs designs mid-analysis and mislabels them "NOT CACHED" before Bazel ever queries the cache.  *Fix: warm the server once first (Step 5b) so analysis is paid a single time, then per-design builds are fast for hits.*
> 2. **No per-design timeout → uncached designs build the full flow.**  A `_gallery` target is **not** a cache-only probe: if the design isn't cached, Bazel will run the *entire* RTL-to-GDS flow (synth→…→route→final) to produce the routed DB, then render the image — hours per design.  A single overall wall cap does **not** prevent this; you must bound *each* design so an uncached one fails fast instead of kicking off a multi-hour build.  *Fix: keep a per-design `timeout`, sized post-warm.*
>
> Also never enumerate via `_final`: it carries multi-GB ODB/GDS/SPEF, so `--remote_download_toplevel` over 56 designs never completes.  Use the lightweight `_gallery` target.

### 5a. Point Bazel at the cache, bypassing Cloudflare on the cache host

STALE SINCE 2026-11-14: the public URL now serves the R2 Worker (uncapped reads, edge-served) and the localhost `bazel-remote` holds only OLD-pin content — do NOT use `http://127.0.0.1:8080` for current results. Use the committed `https://cache.hightide-benchmarks.dev` (or donut's `.bazelrc.user` writer URL) for any bazel fallback, and prefer Step 5a's index fetch, which needs no bazel at all.

### 5b. Warm the server once, then per-design timeout-bounded gallery build

**First, warm the Bazel server** with a single no-timeout build of a design known to be cached (e.g. `lfsr`, whose inputs rarely change).  This pays the ~250 s cold full-repo analysis (loading every BUILD file + external repos) exactly once; subsequent per-design builds reuse that warm analysis cache and resolve a hit in seconds.

```bash
# one-time warm-up (also a cache-soundness probe — lfsr MUST be a hit)
bazel --output_base=/tmp/ob_results build //designs/asap7/lfsr:lfsr_gallery \
  --remote_cache=http://127.0.0.1:8080
```

**Then, per stale design, a timeout-bounded gallery build on the now-warm server:**

```bash
# authoritative gallery labels (handles leaf≠name, e.g. bp_quad → bp_processor_gallery)
if timeout 240 bazel --output_base=/tmp/ob_results build "$gallery_target" \
     --remote_cache=http://127.0.0.1:8080 2>/dev/null; then
  : # cached → image + report available under bazel-bin
else
  echo "NOT CACHED: $platform/$leaf (preserve existing row)"; continue
fi
```

Why this is correct where the earlier attempts weren't:
- **Warm server** ⇒ a *cache hit* completes in seconds (per-target analysis is incremental, not the 250 s cold cost), so a modest per-design `timeout` (≈240 s — generous for the largest design's incremental analysis + cache fetch) does **not** false-negative hits.
- **Per-design `timeout`** ⇒ an *uncached* design, which would otherwise run the full multi-hour RTL-to-GDS flow to synthesize the image, is killed at the bound — bounded waste (`timeout × #misses`), correctly classified "not cached", and the from-scratch build never runs.
- Use the lightweight `_gallery` target (one PNG + the flow's small `6_report.json`), never `_final`.

A design is **cached** iff its bounded build exits 0; otherwise it's **genuinely missing** — preserve its existing row (Step 6).  (For a whole-sweep audit you may instead batch with `--keep_going --build_event_json_file=…` and read `targetCompleted.completed.success` from the BEP, but only *after* warm-up and still under an overall `timeout`; the per-design form above is the safe default because it bounds each miss independently.)

### 5c. Per cached design: versioned image + thumbnail

For each design whose `_gallery` succeeded (`sha` from Step 4):

```bash
new_img="$WT/figures/${leaf}_${platform}_${sha}.png"
old_img=$(ls "$WT"/figures/${leaf}_${platform}_*.png 2>/dev/null | grep -v "_${sha}.png$" | head -1)
cp "bazel-bin/designs/$design_dir/${leaf}_gallery.png" "$new_img"
[[ -n "$old_img" ]] && git -C "$WT" rm -f "$old_img"
git -C "$WT" add "$new_img"

python3 tools/gallery/make_thumbnails.py "$WT/figures"   # rebuilds thumbs/ for any new PNG
new_thumb="$WT/figures/thumbs/${leaf}_${platform}_${sha}.jpg"
old_thumb=$(ls "$WT"/figures/thumbs/${leaf}_${platform}_*.jpg "$WT"/figures/thumbs/${leaf}_${platform}.jpg 2>/dev/null | grep -v "_${sha}.jpg$" | head -1)
[[ -n "$old_thumb" ]] && git -C "$WT" rm -f "$old_thumb"
git -C "$WT" add "$new_thumb"
```

Then read `bazel-bin/designs/$design_dir/logs/$platform/<top>/base/6_report.json` (+ `reports/.../6_finish.rpt`) for QoR — both are flow outputs already materialized by the cached gallery build.

Capture QoR from the JSON using the same metric keys `tools/summary.sh` reads:

**Areas / utilization:**
- `finish__design__die__area`
- `finish__design__core__area`
- `finish__design__instance__area__stdcell`
- `finish__design__instance__utilization` (× 100 for %)

**Cell counts** — the table has both a total Cells column and a per-class breakdown (Sequential / Combinational / Buf-Inv).  Total Cells is the sum of the three breakdown columns; it deliberately excludes tap, tie, fill, antenna, and macro instances so the count reflects "real" logic-doing cells:

- **Cells** = Sequential + Combinational + Buf/Inv (computed; do **not** read `finish__design__instance__count__stdcell` because that aggregate also includes tap+tie)
- **Sequential** = `finish__design__instance__count__class:sequential_cell`
- **Combinational** = `finish__design__instance__count__class:multi_input_combinational_cell` (does not include buf/inv)
- **Buf/Inv** = sum of:
  - `finish__design__instance__count__class:inverter`
  - `finish__design__instance__count__class:clock_buffer`
  - `finish__design__instance__count__class:clock_inverter`
  - `finish__design__instance__count__class:timing_repair_buffer`
  - `finish__design__instance__count__class:timing_repair_inverter`
- **Macros** = `finish__design__instance__count__class:macro` (fall back to `finish__design__instance__count__macros` if not present)
- **IOs** = `finish__design__io`

**Timing — convert all platforms to picoseconds.**  asap7 Liberty uses ps natively; nangate45 / sky130hd use ns, so multiply their values by 1000:
- `finish__timing__setup__ws` → **Slack** (signed; positive is good)
- `finish__clock__skew__setup` → **Skew**
- `finish__timing__fmax` (÷ 1e9 for GHz)

**Power:**
- `finish__power__total` (× 1000 for mW)
- **Clock power is not in the JSON** — parse it from `reports/<platform>/<design>/base/6_finish.rpt`.  Find the `report_power` section, then the `Clock` row; sum its 2nd / 3rd / 4th whitespace fields (Internal + Switching + Leakage Watts) and multiply by 1000 for mW.

**Removed columns**: TNS (always 0 for closing designs; redundant with Slack) and DRCs (always 0 in this benchmark suite).

Format with the same precision as `tools/summary.sh` (areas / counts: 1 decimal or integer; timing / fmax: 2 decimals; power: 3 decimals; util: 1 decimal).

## Step 6: Rewrite the table between markers

Find `<!-- RESULTS_START -->` and `<!-- RESULTS_END -->` in `webpage/results.html`.  Replace everything between them with one `<tr>` per (platform, design) in `(platform, design)` sort order:

```html
<tr data-design="cnn" data-platform="asap7" data-commit="a1b2c3d">
  <td><span class="platform-badge badge-asap7">asap7</span></td>
  <td>cnn</td>
  <td>360000.0</td>            <!-- Die Area μm² -->
  <td>336166.0</td>            <!-- Core Area μm² -->
  <td>23936.7</td>             <!-- Inst Area μm² -->
  <td>40.1</td>                <!-- Util % -->
  <td>171586</td>              <!-- Cells (= Sequential + Combinational + Buf/Inv) -->
  <td>28507</td>               <!-- Sequential -->
  <td>106616</td>              <!-- Combinational -->
  <td>36463</td>               <!-- Buf/Inv -->
  <td>65</td>                  <!-- Macros -->
  <td>367</td>                 <!-- IOs -->
  <td>-44.30</td>              <!-- Slack ps -->
  <td>118.16</td>              <!-- Skew ps -->
  <td>0.96</td>                <!-- Fmax GHz -->
  <td>456.091</td>             <!-- Power mW -->
  <td>47.501</td>              <!-- Clk Power mW -->
  <td><a href="https://github.com/VLSIDA/HighTide/commit/a1b2c3d">a1b2c3d</a></td>
</tr>
```

Column order in `<thead>` (18 columns total): Platform, Design, Die Area, Core Area, Inst Area, Util%, Cells, Sequential, Combinational, Buf/Inv, Macros, IOs, Slack ps, Skew ps, Fmax GHz, Power mW, Clk Power mW, Commit.  Keep `data-col` indices on the `<th>` matching the column position so the JS sort/filter logic stays in sync.

The "Cells" filter input reads column 6 (the total).

If a (platform, design) is currently NOT CACHED (Step 5 skipped it), preserve any existing row in the table (don't drop the design from the page just because the user's local cache is empty).  Use `<!-- skipped: not cached on YYYY-MM-DD -->` as a comment marker to make stale-data sources visible.

## Step 7: Update gallery.html thumbnails

`webpage/gallery.html` references the same images.  Both reference families need to point at the versioned names from Step 5:

- `<a class="thumb-link" href="figures/<design>_<platform>_<sha>.png">` — full-res click target
- `<img src="figures/thumbs/<design>_<platform>_<sha>.jpg">` — visible thumbnail

The full-res `href` and the thumbnail `src` MUST share the same SHA — they describe the same routed view; mismatched SHAs means the user clicks a thumb of one build and lands on a different build's full image.

Both references always use the versioned `<design>_<platform>_<sha>` name (no canonical fallback exists anymore).

### Thumbnail order within each design card

For a card whose family has multiple thumbnails (e.g. NVDLA partitions a/c/m/o/p), order the `<a class="thumb-link">` entries by **(platform, variant)** — platform first, then variant alphabetically within each platform.  Platform sequence is always asap7 → nangate45 → sky130hd to match the badge ordering everywhere else.

Concretely: emit all asap7 thumbs (sorted by variant), then all nangate45 thumbs, then all sky130hd thumbs.  This matches the existing NVDLA ordering.

For cards with one thumb per platform (CoralNPU, Vortex, Gemmini, etc.), the variant secondary sort is a no-op — just preserve asap7 → nangate45 → sky130hd order.

### Per-(platform, variant) placeholders for missing thumbs

A design card lists one platform badge per technology it *targets*, and family designs (e.g. NVDLA partitions) have a fixed set of variants per platform.  Every (platform, variant) slot the card *should* contain — based on the design family's targets — gets either a real thumb or a placeholder, so the card's grid layout matches the badge count and the variant set the user expects to see.

```html
<div class="thumb-placeholder"><div class="ph-box">pending</div><span class="thumb-label asap7">asap7</span></div>
```

For family cards (e.g. NVDLA), include a `<span class="thumb-variant">` line inside the placeholder so missing variants are labeled the same way real variant thumbs are:

```html
<div class="thumb-placeholder"><div class="ph-box">pending</div><span class="thumb-label asap7">asap7</span><span class="thumb-variant">partition_c</span></div>
```

Rules:
- Emit a placeholder for every (platform, variant) slot the card should contain that doesn't have a thumb — including missing variants within a platform that already has other variant thumbs.  The card's variant set is intentional documentation of what the design targets, not a build-status signal; visually showing every slot — real or pending — keeps the grid honest.
- Place each placeholder in the (platform, variant) sort position it would occupy if a real thumb existed — i.e. inside the asap7 group, nangate45 group, etc., in alphabetical variant order.

The legacy single `<div class="placeholder">Die image pending</div>` block is deprecated; replace it with the per-(platform, variant) placeholder pattern above on first run.

## Step 8: Update the Design Portfolio platform badges in index.html

`webpage/index.html` has a "Design Portfolio" table (`<section id="designs">`) where each row's last column is a list of `<span class="platform-badge badge-<platform>">…</span>` tags.  Those badges must reflect which platforms each design *actually* reaches `_final` on, derived from the same per-(platform, design) sweep used above.

### Source of truth: walk every portfolio `<tr>`

The portfolio table itself is the source of truth — no skill-side hardcoded list.  Iterate every `<tr>` inside `<section id="designs">` and resolve each row's leaf design name(s) by these rules, in order:

1. **`data-leaves` attribute** on the `<tr>`, if present.  Whitespace-separated list of leaf names and/or globs.  Examples already in the file:
   ```html
   <tr data-leaves="bp_uno bp_quad">    <!-- BlackParrot: two members, not name-derivable -->
   <tr data-leaves="partition_*">       <!-- NVDLA: family glob -->
   ```
   Tokens containing `*` are globs matched against the design list from Step 3; bare tokens are literal leaf names.

2. **Derive from the display name** (`<td><strong>…</strong></td>`) when no `data-leaves` is set.  Lowercase the display name and replace spaces with `_`.  This covers the common case: `Gemmini → gemmini`, `LitePCI → litepci`, `Snitch Cluster → snitch_cluster`, `LiteDRAM → litedram`, `NyuziProcessor → nyuziprocessor` (case-folded — match the design list case-insensitively).

For a family with multiple resolved leaves, a platform badge appears if **any** member has a cached `_final` on that platform.

**Add a `data-leaves` attribute** only when both derivation rules above would miss — i.e. the display name doesn't case-fold to the leaf name(s), or the family has multiple non-name-derivable members.  Avoid adding it gratuitously; the whole point is to keep most rows derivation-only.

### Update procedure

For each portfolio `<tr>`:

1. Resolve the family's leaf names per the rules above.
2. Compute the active-platforms set from Step 5 results: `{platform : ∃ leaf ∈ family with cached _final on platform}`.
3. Re-emit the badge `<td>` with one `<span class="platform-badge badge-<platform>">…</span>` per active platform, ordered asap7 → nangate45 → sky130hd, indented to match the surrounding HTML.
4. If the active set is empty, leave the row's badges as-is and emit `<!-- skipped: no cached _final on YYYY-MM-DD -->` next to the badges so a future sweep can re-evaluate.
5. Don't touch any other column (description, language) — those are hand-curated and have no machine-readable source of truth.

This step is idempotent: running the skill twice in a row produces no diff if the cache state hasn't changed.

## Step 9: Show the diff and stop

```bash
git -C "$WT" status --short
git -C "$WT" diff --stat
git -C "$WT" diff figures/ -- ':(exclude)*.png' | head   # text-only diff for HTML
```

Surface the change set to the user, list any designs that were skipped because the cache was cold, and stop.  Don't `git commit` or `git push` — leave that to the user.

## Worked example

```
/update-results
```

(No filter, so sweep everything.)

```
> Locating webpage worktree at /home/mrg/HighTide/webpage … clean (origin/webpage @ 1d9ccec4).
> Image set already fully versioned — no migration.
> Sweep: 56 (platform, design) pairs; 41 stale vs results.html data-commit.
> Cache: localhost endpoint (http://127.0.0.1:8080), Cloudflare bypassed.
> Batched: bazel build 56 _gallery --keep_going --build_event_json_file …
>   BEP: 53 _gallery succeeded (cached), 3 genuinely missing
>        (asap7/floonoc, nangate45/floonoc, sky130hd/NVDLA/partition_c).
>   wrote figures/cnn_asap7_a1b2c3d.png (replaces cnn_asap7_<old>.png)  … ×53
> Rewrote results.html (56 rows, 3 missing → preserved as comment).
> Rewrote gallery.html (38 image references updated).
> Updated index.html design portfolio: 12 rows, 3 platform badges added (cnn nangate45, gemmini sky130hd, sha3 sky130hd), 1 removed (floonoc nangate45 → cache cold).
> Diff:
>     index.html   |  18 +++++++++--------
>     results.html | 412 ++++++++++++++++++++++++++++++++++++++++++--------------
>     gallery.html |  84 +++++-----
>     figures/     | 38 deletions, 38 creations (renames)
> Run `git -C /home/mrg/HighTide/webpage diff` to review, then commit + push.
```
