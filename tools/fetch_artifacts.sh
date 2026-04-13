#!/bin/bash
# Fetch build artifacts from the hightide-artifacts PVC on Nautilus NRP.
# Artifacts are saved by K8s jobs when submitted with `./k8s/run.sh --upload-artifacts`.
#
# Usage:
#   ./tools/fetch_artifacts.sh                      # all designs
#   ./tools/fetch_artifacts.sh asap7                # all asap7 designs
#   ./tools/fetch_artifacts.sh asap7 lfsr           # specific design
#   ./tools/fetch_artifacts.sh --design lfsr        # one design, all platforms
#
# Options:
#   --output-dir DIR  Where to copy artifacts (default: artifacts/)
#   --keep            Keep artifacts on the PVC after fetching (default: delete)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_DIR"

NAMESPACE="vlsida"
PVC_NAME="hightide-artifacts"
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

# Start a temporary pod to access the PVC
POD_NAME="hightide-fetch-$$"
echo "Starting temporary pod to access PVC..."
kubectl run "$POD_NAME" -n "$NAMESPACE" \
    --image=alpine \
    --restart=Never \
    --overrides='{
      "spec": {
        "containers": [{
          "name": "fetch",
          "image": "alpine",
          "command": ["sleep", "3600"],
          "volumeMounts": [{
            "name": "artifacts",
            "mountPath": "/artifacts"
          }]
        }],
        "volumes": [{
          "name": "artifacts",
          "persistentVolumeClaim": {
            "claimName": "'"$PVC_NAME"'"
          }
        }]
      }
    }' >/dev/null 2>&1

# Wait for the pod to be ready
echo "Waiting for pod..."
kubectl wait --for=condition=Ready pod/"$POD_NAME" -n "$NAMESPACE" --timeout=60s >/dev/null 2>&1

cleanup() {
    echo "Cleaning up temporary pod..."
    kubectl delete pod "$POD_NAME" -n "$NAMESPACE" --ignore-not-found=true >/dev/null 2>&1
}
trap cleanup EXIT

mkdir -p "$OUTPUT_DIR"
echo "Fetching artifacts to $OUTPUT_DIR/"
echo ""

PASS=0
FAIL=0

for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform leaf relpath <<< "$entry"
    printf "  %-12s %-30s " "$platform" "$leaf"

    REMOTE_DIR="/artifacts/designs/$relpath"

    # Check if remote directory exists
    if ! kubectl exec "$POD_NAME" -n "$NAMESPACE" -- ls "$REMOTE_DIR" >/dev/null 2>&1; then
        echo "NOT FOUND"
        ((FAIL++))
        continue
    fi

    LOCAL_DIR="$OUTPUT_DIR/$relpath"
    mkdir -p "$LOCAL_DIR"

    # Copy artifacts from PVC via kubectl cp
    if kubectl cp "$NAMESPACE/$POD_NAME:$REMOTE_DIR" "$LOCAL_DIR" >/dev/null 2>&1; then
        if [[ "$KEEP_REMOTE" != "true" ]]; then
            kubectl exec "$POD_NAME" -n "$NAMESPACE" -- rm -rf "$REMOTE_DIR" 2>/dev/null
            echo "OK (deleted remote)"
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
