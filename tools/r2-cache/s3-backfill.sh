#!/usr/bin/env bash
# Backfill large blobs from the local bazel disk cache into the R2 bucket.
#
# Bazel uploads blobs itself through the Worker (tools/r2-cache/worker.js),
# but PUTs through a free-plan zone are capped at 100 MB, so oversized CAS
# blobs (big stage ODBs etc.) never make it. This script pushes them over the
# R2 S3 API (multipart, no size cap that matters) into the same key layout
# the Worker serves: cas/<sha256>, ac/<sha256>.
#
# Bazel's --disk_cache layout is identical (<dir>/{ac,cas}/<2hex>/<hash>),
# so after any local build of a big design, run this to publish its large
# artifacts. Objects already in the bucket are skipped.
#
# Usage: s3-backfill.sh [--min-size-mb N] [--dry-run] [--cache-dir DIR]
# Credentials: source ~/.hightide-r2-s3-env (AWS_ACCESS_KEY_ID,
# AWS_SECRET_ACCESS_KEY, R2_ENDPOINT), or have them in the environment.

set -euo pipefail

MIN_MB=95          # just under the 100 MB Worker cap
CACHE_DIR="${HOME}/.cache/bazel-disk-cache"
BUCKET=hightide-bazel-cache
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --min-size-mb) MIN_MB="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=1; shift ;;
    --cache-dir)   CACHE_DIR="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${R2_ENDPOINT:-}" && -r "${HOME}/.hightide-r2-s3-env" ]]; then
  # shellcheck source=/dev/null
  . "${HOME}/.hightide-r2-s3-env"
fi
: "${R2_ENDPOINT:?R2_ENDPOINT not set (source ~/.hightide-r2-s3-env)}"

uploaded=0 skipped=0 bytes=0
for kind in cas ac; do
  [[ -d "$CACHE_DIR/$kind" ]] || continue
  while IFS= read -r f; do
    hash=$(basename "$f")
    [[ "$hash" =~ ^[0-9a-f]{64}$ ]] || continue
    key="$kind/$hash"
    if aws s3api head-object --bucket "$BUCKET" --key "$key" \
         --endpoint-url "$R2_ENDPOINT" >/dev/null 2>&1; then
      skipped=$((skipped + 1))
      continue
    fi
    size=$(stat -c%s "$f")
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "would upload $key ($((size / 1024 / 1024)) MB)"
    else
      echo "uploading $key ($((size / 1024 / 1024)) MB)"
      aws s3 cp "$f" "s3://$BUCKET/$key" \
        --endpoint-url "$R2_ENDPOINT" --no-progress
    fi
    uploaded=$((uploaded + 1))
    bytes=$((bytes + size))
  done < <(find "$CACHE_DIR/$kind" -type f -size +"${MIN_MB}"M 2>/dev/null)
done

echo "done: $uploaded uploaded ($((bytes / 1024 / 1024)) MB), $skipped already present"
