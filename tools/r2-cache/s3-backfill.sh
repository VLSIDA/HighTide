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

# Script-scoped AWS config: 64 MB multipart chunks (a 2 GB blob is ~30 parts
# instead of ~230 at the 8 MB default — fewer chances for R2 to drop a part
# and fail CompleteMultipartUpload with InvalidPart).
_AWSCFG=$(mktemp)
printf '[default]\ns3 =\n  multipart_chunksize = 64MB\n' > "$_AWSCFG"
export AWS_CONFIG_FILE="$_AWSCFG"
trap 'rm -f "$_AWSCFG"' EXIT

uploaded=0 skipped=0 bytes=0 failed=0
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
      # Tolerate per-blob failures (transient R2 InvalidPart etc.): retry
      # once, then record and continue — never abort the remaining blobs.
      if ! aws s3 cp "$f" "s3://$BUCKET/$key" \
             --endpoint-url "$R2_ENDPOINT" --no-progress \
         && ! aws s3 cp "$f" "s3://$BUCKET/$key" \
             --endpoint-url "$R2_ENDPOINT" --no-progress; then
        echo "upload FAILED after retry: $key"
        failed=$((failed + 1))
        continue
      fi
    fi
    uploaded=$((uploaded + 1))
    bytes=$((bytes + size))
  done < <(find "$CACHE_DIR/$kind" -type f -size +"${MIN_MB}"M 2>/dev/null)
done

# Second pass: action-cache entries, ALL sizes. When an action has an
# oversized output, bazel's own 413'd blob upload makes it skip writing
# the AC entry — so without this pass, big-output actions never become
# cache hits even though the pass above published their blobs. AC files
# are tiny; one that references a missing CAS blob is harmless (bazel
# falls back to executing the action).
ac_up=0 ac_skip=0
if [[ -d "$CACHE_DIR/ac" ]]; then
  while IFS= read -r f; do
    hash=$(basename "$f")
    [[ "$hash" =~ ^[0-9a-f]{64}$ ]] || continue
    key="ac/$hash"
    if aws s3api head-object --bucket "$BUCKET" --key "$key" \
         --endpoint-url "$R2_ENDPOINT" >/dev/null 2>&1; then
      ac_skip=$((ac_skip + 1)); continue
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "would upload $key"
    elif ! aws s3 cp "$f" "s3://$BUCKET/$key" \
           --endpoint-url "$R2_ENDPOINT" --no-progress >/dev/null; then
      echo "AC upload FAILED: $key"; failed=$((failed + 1)); continue
    fi
    ac_up=$((ac_up + 1))
  done < <(find "$CACHE_DIR/ac" -type f 2>/dev/null)
fi

echo "done: $uploaded uploaded ($((bytes / 1024 / 1024)) MB), $skipped already present, $failed failed; AC: $ac_up uploaded, $ac_skip present"
[[ $failed -eq 0 ]]
