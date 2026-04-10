#!/bin/bash
# Delete build artifacts uploaded by K8s jobs from GCS.
# Removes tarballs at gs://hightide-bazel-cache/artifacts/<platform>/<design>/build.tar.gz
#
# Usage:
#   ./tools/delete_artifacts.sh                      # all designs
#   ./tools/delete_artifacts.sh asap7                # all asap7 designs
#   ./tools/delete_artifacts.sh asap7 lfsr           # specific design
#   ./tools/delete_artifacts.sh --design lfsr        # one design, all platforms
#
# Options:
#   --yes  Skip confirmation prompt

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

GCS_BUCKET="gs://hightide-bazel-cache/artifacts"
SKIP_CONFIRM=false
FILTER_PLATFORM=""
FILTER_DESIGN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes)    SKIP_CONFIRM=true; shift ;;
        --design) FILTER_DESIGN="$2"; shift 2 ;;
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

# Check for gsutil/gcloud
if ! command -v gsutil >/dev/null 2>&1 && ! command -v gcloud >/dev/null 2>&1; then
    echo "ERROR: gsutil or gcloud must be installed and authenticated" >&2
    exit 1
fi

GS_CMD="gsutil"
command -v gsutil >/dev/null 2>&1 || GS_CMD="gcloud storage"

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

echo "Will delete artifacts for ${#TARGETS[@]} design(s):"
for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform leaf relpath <<< "$entry"
    echo "  $platform/$leaf"
done
echo ""

if [[ "$SKIP_CONFIRM" != "true" ]]; then
    read -p "Proceed? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

PASS=0
FAIL=0

for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform leaf relpath <<< "$entry"
    printf "  %-12s %-30s " "$platform" "$leaf"

    GCS_PATH="$GCS_BUCKET/designs/$relpath/build.tar.gz"
    if $GS_CMD rm "$GCS_PATH" 2>/dev/null; then
        echo "DELETED"
        ((PASS++))
    else
        echo "NOT FOUND"
        ((FAIL++))
    fi
done

echo ""
echo "Deleted: $PASS  Not found: $FAIL"
