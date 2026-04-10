#!/bin/bash
# Fetch cached build results from the remote cache without building.
# Uses a short timeout so only designs with cached results are fetched.
#
# Usage:
#   ./tools/fetch_cache.sh                      # all designs
#   ./tools/fetch_cache.sh asap7                 # all asap7 designs
#   ./tools/fetch_cache.sh asap7 lfsr            # specific design
#   ./tools/fetch_cache.sh --design lfsr         # one design, all platforms
#   ./tools/fetch_cache.sh --stage synth asap7   # fetch only through synth stage
#
# Options:
#   --stage STAGE   Stop at stage (synth, floorplan, place, cts, route, final)
#                   Default: final
#   --timeout SECS  Remote cache timeout in seconds (default: 30)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

REMOTE_CACHE="https://storage.googleapis.com/hightide-bazel-cache"
TIMEOUT=30
STAGE="final"
FILTER_PLATFORM=""
FILTER_DESIGN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stage)    STAGE="$2"; shift 2 ;;
        --timeout)  TIMEOUT="$2"; shift 2 ;;
        --design)   FILTER_DESIGN="$2"; shift 2 ;;
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

# Discover targets (same logic as k8s/run.sh)
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

    if [[ -n "$FILTER_PLATFORM" && "$platform" != "$FILTER_PLATFORM" ]]; then
        continue
    fi
    if [[ -n "$FILTER_DESIGN" ]]; then
        leaf="${relpath##*/}"
        if [[ "$name" != "$FILTER_DESIGN" && "$leaf" != *"$FILTER_DESIGN"* && "$relpath" != *"$FILTER_DESIGN"* ]]; then
            continue
        fi
    fi

    leaf_name="${relpath##*/}"
    TARGETS+=("$platform|$leaf_name|//designs/$relpath:${name}_${STAGE}")
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "No designs matched the given filters."
    exit 1
fi

echo "Fetching cached results (stage: $STAGE, timeout: ${TIMEOUT}s)"
echo ""

PASS=0
FAIL=0

for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform name target <<< "$entry"
    printf "  %-12s %-30s " "$platform" "$name"

    OUTPUT=$(timeout "$TIMEOUT" bazel build \
        --remote_cache="$REMOTE_CACHE" \
        --remote_upload_local_results=false \
        --local_cpu_resources=0 \
        "$target" 2>&1)
    if [[ $? -eq 0 ]]; then
        REMOTE_HITS=$(echo "$OUTPUT" | grep -oP '\d+(?= remote cache hit)' || true)
        if [[ -n "$REMOTE_HITS" && "$REMOTE_HITS" -gt 0 ]]; then
            echo "OK (remote)"
        else
            echo "OK (local)"
        fi
        ((PASS++))
    else
        echo "NOT CACHED"
        ((FAIL++))
    fi
done

echo ""
echo "Fetched: $PASS  Not cached: $FAIL"

if [[ $PASS -gt 0 ]]; then
    echo ""
    echo "Run ./tools/summary.sh to view results."
fi
