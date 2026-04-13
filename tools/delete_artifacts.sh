#!/bin/bash
# Delete build artifacts from the hightide-artifacts PVC on Nautilus NRP.
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

NAMESPACE="vlsida"
PVC_NAME="hightide-artifacts"
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

# Start a temporary pod to access the PVC
POD_NAME="hightide-delete-$$"
echo "Starting temporary pod to access PVC..."
kubectl run "$POD_NAME" -n "$NAMESPACE" \
    --image=alpine \
    --restart=Never \
    --overrides='{
      "spec": {
        "containers": [{
          "name": "delete",
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

echo "Waiting for pod..."
kubectl wait --for=condition=Ready pod/"$POD_NAME" -n "$NAMESPACE" --timeout=60s >/dev/null 2>&1

cleanup() {
    echo "Cleaning up temporary pod..."
    kubectl delete pod "$POD_NAME" -n "$NAMESPACE" --ignore-not-found=true >/dev/null 2>&1
}
trap cleanup EXIT

PASS=0
FAIL=0

for entry in "${TARGETS[@]}"; do
    IFS='|' read -r platform leaf relpath <<< "$entry"
    printf "  %-12s %-30s " "$platform" "$leaf"

    REMOTE_DIR="/artifacts/designs/$relpath"
    if kubectl exec "$POD_NAME" -n "$NAMESPACE" -- rm -rf "$REMOTE_DIR" 2>/dev/null; then
        echo "DELETED"
        ((PASS++))
    else
        echo "NOT FOUND"
        ((FAIL++))
    fi
done

echo ""
echo "Deleted: $PASS  Not found: $FAIL"
