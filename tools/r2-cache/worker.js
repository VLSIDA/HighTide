// Bazel HTTP remote cache (https://bazel.build/remote/caching#http-caching)
// backed by a Cloudflare R2 bucket.
//
// Anonymous GET/HEAD (public read), token-authenticated PUT (write) — same
// access model as the bazel-remote + htpasswd setup on donut.
//
// R2 keys mirror the Bazel HTTP cache paths: "ac/<sha256>" and "cas/<sha256>".
// CAS entries are content-addressed, so an existing key is never rewritten
// (saves R2 Class A write operations on repeat uploads).
//
// Known limit: PUT bodies through a Worker on a free-plan zone are capped at
// 100 MB — same ceiling as the tunnel. Reads are NOT capped. Large-artifact
// writes must go over the R2 S3 API (multipart) instead; see README.md.

const PATH_RE = /^\/(ac|cas)\/([0-9a-f]{64})$/;

function authorized(request, env) {
  // Accept "Authorization: Basic base64(user:token)" (what bazel sends for
  // https://user:token@host URLs) or "Authorization: Bearer <token>".
  // CACHE_WRITE_TOKEN is a wrangler secret holding the full "user:token"
  // string for Basic, and its token part alone works for Bearer.
  const expected = env.CACHE_WRITE_TOKEN;
  if (!expected) return false; // no secret configured -> read-only cache
  const header = request.headers.get("Authorization") || "";
  if (header.startsWith("Basic ")) {
    let decoded;
    try {
      decoded = atob(header.slice(6));
    } catch {
      return false;
    }
    return timingSafeEqual(decoded, expected);
  }
  if (header.startsWith("Bearer ")) {
    const token = expected.includes(":")
      ? expected.slice(expected.indexOf(":") + 1)
      : expected;
    return timingSafeEqual(header.slice(7), token);
  }
  return false;
}

function timingSafeEqual(a, b) {
  const enc = new TextEncoder();
  const ab = enc.encode(a);
  const bb = enc.encode(b);
  if (ab.byteLength !== bb.byteLength) return false;
  return crypto.subtle.timingSafeEqual(ab, bb);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/" || url.pathname === "/status") {
      return new Response("HighTide bazel R2 cache: OK\n", { status: 200 });
    }

    const m = PATH_RE.exec(url.pathname);
    if (!m) return new Response("not found\n", { status: 404 });
    const kind = m[1]; // "ac" | "cas"
    const key = `${kind}/${m[2]}`;

    switch (request.method) {
      case "GET": {
        const obj = await env.BUCKET.get(key);
        if (!obj) return new Response("not found\n", { status: 404 });
        return new Response(obj.body, {
          status: 200,
          headers: {
            "Content-Length": String(obj.size),
            "Content-Type": "application/octet-stream",
            // CAS is immutable; AC entries can be overwritten but stale
            // reads are harmless for a content-addressed build cache.
            "Cache-Control": "public, max-age=86400",
          },
        });
      }

      case "HEAD": {
        const obj = await env.BUCKET.head(key);
        if (!obj) return new Response(null, { status: 404 });
        return new Response(null, {
          status: 200,
          headers: { "Content-Length": String(obj.size) },
        });
      }

      case "PUT": {
        if (!authorized(request, env)) {
          return new Response("unauthorized\n", {
            status: 401,
            headers: { "WWW-Authenticate": 'Basic realm="bazel-cache"' },
          });
        }
        if (kind === "cas" && (await env.BUCKET.head(key))) {
          return new Response(null, { status: 200 }); // already have it
        }
        if (request.headers.get("Content-Length") !== null) {
          await env.BUCKET.put(key, request.body);
        } else {
          // R2 put() needs a known length; buffer chunked uploads.
          await env.BUCKET.put(key, await request.arrayBuffer());
        }
        return new Response(null, { status: 201 });
      }

      default:
        return new Response("method not allowed\n", {
          status: 405,
          headers: { Allow: "GET, HEAD, PUT" },
        });
    }
  },
};
