#!/bin/bash
# Fetch build artifacts uploaded by K8s jobs from GCS.
# Artifacts are synced to gs://hightide-bazel-cache/artifacts/designs/<platform>/<design>/
# when jobs are submitted with `./k8s/run.sh --upload-artifacts ...`.
#
# Usage:
#   ./tools/fetch_artifacts.sh                      # all designs
#   ./tools/fetch_artifacts.sh asap7                # all asap7 designs
#   ./tools/fetch_artifacts.sh asap7 lfsr           # specific design
#   ./tools/fetch_artifacts.sh --design lfsr        # one design, all platforms
#
# Options:
#   --output-dir DIR  Where to sync artifacts (default: artifacts/)
#   --keep            Keep artifacts in GCS after fetching (default: delete)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

GCS_BUCKET="gs://hightide-bazel-cache/artifacts"
OUTPUT_DIR="artifacts"
KEEP_REMOTE=false
FILTER_PLATFORM=""
FILTER_DESIGN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --keep)       KEEP_REMOTE=true; shift ;;
        --design)     FILTER_DESIGN="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,/^$/s/^# //p' "$0"
            exit 0
            ;;
        *)
            if [[ -z "$FILTER_PLATFORM" ]]; then
                FILTER_PLATFORM="$1"
            elif [[ -z "$FILTER_DESIGN" ]]; then
                FILTER_DESIGN="$1"
            else
                echo "ERROR: unexpected argument: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if ! command -v gcloud >/dev/null 2>&1; then
    echo "ERROR: gcloud must be installed and authenticated" >&2
    exit 1
fi

# Discover designs
TARGETS=()
for build_file in designs/*/BUILD.bazel \
                  designs/*/*/BUILD.bazel \
                  designs/*/*/*/BUILD.bazel; do
    [[ -f "$build_file" ]] || continue
    grep -q 'hightide_design(' "$build_file" || continue

    dir=$(dirname "$build_file")
    name=$(grep -A1 'hightide_design(' "$build_file" | grep -oP 'name\s*=\s*"\K[^"]+')
    [[ -z "$name" ]] && continue

    relpath="${dir#designs/}"
    platform="${relpath%%/*}"
    leaf="${relpath##*/}"

    if [[ -n "$FILTER_PLATFORM" && "$platform" != "$FILTER_PLATFORM" ]]; then
        continue
    fi
    if [[ -n "$FILTER_DESIGN" ]]; then
        if [[ "$name" != "$FILTER_DESIGN" && "$leaf" != *"$FILTER_DESIGN"* && "$relpath" != *"$FILTER_DESIGN"* ]]; then
            continue
        fi
    fi

    TARGETS+=("$platform|$leaf|$relpath")
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "No designs matched the given filters."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "Syncing artifacts to $OUTPUT_DIR/"
echo ""

PASS=0
FAIL=0

for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform leaf relpath <<< "$entry"
    printf "  %-12s %-30s " "$platform" "$leaf"

    GCS_PATH="$GCS_BUCKET/designs/$relpath"
    LOCAL_DIR="$OUTPUT_DIR/$relpath"

    # Check if remote path has any objects before attempting rsync
    if ! gcloud storage ls "$GCS_PATH/**" >/dev/null 2>&1; then
        echo "NOT FOUND"
        ((FAIL++))
        continue
    fi

    mkdir -p "$LOCAL_DIR"
    if gcloud storage rsync --recursive "$GCS_PATH" "$LOCAL_DIR" >/dev/null 2>&1; then
        if [[ "$KEEP_REMOTE" != "true" ]]; then
            gcloud storage rm --recursive "$GCS_PATH" >/dev/null 2>&1 \
                && echo "OK (deleted remote)" || echo "OK"
        else
            echo "OK"
        fi
        ((PASS++))
    else
        echo "FAILED"
        ((FAIL++))
    fi
done

echo ""
echo "Fetched: $PASS  Not found/failed: $FAIL"
