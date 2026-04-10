#!/bin/bash
# Submit HighTide design builds as Kubernetes Jobs on NRP Nautilus.
#
# Usage:
#   ./k8s/run.sh [platform] [design]   # single design on a platform
#   ./k8s/run.sh [platform]            # all designs for a platform
#   ./k8s/run.sh --design [design]     # a design across all platforms
#   ./k8s/run.sh                       # all designs, all platforms
#   ./k8s/run.sh --status              # show job status
#   ./k8s/run.sh --delete              # delete all jobs
#   ./k8s/run.sh --delete asap7        # delete all asap7 jobs
#   ./k8s/run.sh --delete asap7 lfsr   # delete a specific job
#   ./k8s/run.sh --delete --design lfsr # delete lfsr across all platforms
#
# Options:
#   --branch BRANCH    Git branch to build (default: current branch)
#   --cpu NUM          CPU request per job (default: 8)
#   --mem SIZE         Memory request per job (default: 64Gi)
#   --upload-artifacts Upload build artifacts (bazel-bin) to GCS for debug
#   --dry-run          Print generated YAML without submitting
#   --status           Show status of submitted jobs
#   --delete           Delete jobs (filtered by platform/design args)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$SCRIPT_DIR/job-template.yaml"
NAMESPACE="vlsida"

# Defaults
BRANCH="main"
CPU_REQUEST="8"
CPU_LIMIT="16"
MEM_REQUEST="64Gi"
MEM_LIMIT="128Gi"
DRY_RUN=false
MODE="submit"
UPLOAD_ARTIFACTS="false"
FILTER_PLATFORM=""
FILTER_DESIGN=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --branch)   BRANCH="$2"; shift 2 ;;
        --cpu)      CPU_REQUEST="$2"; CPU_LIMIT="$((${2} * 2))"; shift 2 ;;
        --mem)      MEM_REQUEST="$2"; MEM_LIMIT="${2%Gi}"; MEM_LIMIT="$((MEM_LIMIT * 2))Gi"; shift 2 ;;
        --upload-artifacts) UPLOAD_ARTIFACTS=true; shift ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --status)   MODE="status"; shift ;;
        --delete)   MODE="delete"; shift ;;
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

# Handle status/delete modes
if [[ "$MODE" == "status" ]]; then
    echo "Jobs in namespace $NAMESPACE:"
    kubectl get jobs -n "$NAMESPACE" -l app=hightide \
        -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[0].type,COMPLETIONS:.status.succeeded,FAILURES:.status.failed,AGE:.metadata.creationTimestamp' \
        2>/dev/null || kubectl get jobs -n "$NAMESPACE" -l app=hightide
    echo ""
    echo "Pods:"
    kubectl get pods -n "$NAMESPACE" -l app=hightide \
        -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName' \
        2>/dev/null || kubectl get pods -n "$NAMESPACE" -l app=hightide
    exit 0
fi

if [[ "$MODE" == "delete" ]]; then
    LABEL_SELECTOR="app=hightide"
    DESC="all"
    if [[ -n "$FILTER_PLATFORM" ]]; then
        LABEL_SELECTOR="$LABEL_SELECTOR,platform=$FILTER_PLATFORM"
        DESC="$FILTER_PLATFORM"
    fi
    if [[ -n "$FILTER_DESIGN" ]]; then
        design_label=$(echo "$FILTER_DESIGN" | tr '[:upper:]' '[:lower:]')
        LABEL_SELECTOR="$LABEL_SELECTOR,design=$design_label"
        DESC="$DESC/$FILTER_DESIGN"
    fi
    echo "Deleting $DESC hightide jobs in $NAMESPACE..."
    kubectl delete jobs -n "$NAMESPACE" -l "$LABEL_SELECTOR"
    exit 0
fi

# Discover designs
discover_designs() {
    for build_file in "$REPO_DIR"/designs/*/BUILD.bazel \
                      "$REPO_DIR"/designs/*/*/BUILD.bazel \
                      "$REPO_DIR"/designs/*/*/*/BUILD.bazel; do
        [[ -f "$build_file" ]] || continue
        grep -q 'hightide_design(' "$build_file" || continue

        local dir
        dir=$(dirname "$build_file")
        local name
        name=$(grep -A1 'hightide_design(' "$build_file" | grep -oP 'name\s*=\s*"\K[^"]+')
        [[ -z "$name" ]] && continue

        local relpath="${dir#$REPO_DIR/designs/}"
        local platform="${relpath%%/*}"
        local target="//designs/$relpath:${name}_final"

        echo "$platform|$name|$relpath|$target"
    done
}

# Collect matching designs
DESIGNS=()
while IFS='|' read -r platform name relpath target; do
    # Apply platform filter
    if [[ -n "$FILTER_PLATFORM" && "$platform" != "$FILTER_PLATFORM" ]]; then
        continue
    fi
    # Apply design filter (match against name or the design directory component)
    if [[ -n "$FILTER_DESIGN" ]]; then
        design_dir="${relpath#*/}"  # strip platform prefix
        if [[ "$name" != "$FILTER_DESIGN" && "$design_dir" != *"$FILTER_DESIGN"* ]]; then
            continue
        fi
    fi
    DESIGNS+=("$platform|$name|$relpath|$target")
done < <(discover_designs | sort)

if [[ ${#DESIGNS[@]} -eq 0 ]]; then
    echo "No designs matched the given filters."
    echo "  Platform: ${FILTER_PLATFORM:-<all>}"
    echo "  Design:   ${FILTER_DESIGN:-<all>}"
    exit 1
fi

echo "Submitting ${#DESIGNS[@]} job(s) to NRP Nautilus ($NAMESPACE)..."
echo "  Branch: $BRANCH"
echo "  Resources: ${CPU_REQUEST} CPU / ${MEM_REQUEST} memory"
echo ""

# Generate and submit jobs
for entry in "${DESIGNS[@]}"; do
    IFS='|' read -r platform name relpath target <<< "$entry"

    # Create a DNS-safe job name using the leaf directory name
    leaf_name="${relpath##*/}"
    job_name="hightide-${platform}-${leaf_name}"
    job_name=$(echo "$job_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | cut -c1-63)

    # Generate YAML from template
    yaml=$(sed \
        -e "s|__JOB_NAME__|${job_name}|g" \
        -e "s|__BRANCH__|${BRANCH}|g" \
        -e "s|__BAZEL_TARGET__|${target}|g" \
        -e "s|__UPLOAD_ARTIFACTS__|${UPLOAD_ARTIFACTS}|g" \
        -e "s|__CPU_REQUEST__|${CPU_REQUEST}|g" \
        -e "s|__CPU_LIMIT__|${CPU_LIMIT}|g" \
        -e "s|__MEM_REQUEST__|${MEM_REQUEST}|g" \
        -e "s|__MEM_LIMIT__|${MEM_LIMIT}|g" \
        "$TEMPLATE")

    # Add labels for filtering
    yaml=$(echo "$yaml" | sed '/^  template:$/a\    metadata:\n      labels:\n        app: hightide\n        platform: '"$platform"'\n        design: '"$(echo "$name" | tr '[:upper:]' '[:lower:]')"'')

    if [[ "$DRY_RUN" == true ]]; then
        echo "--- # $platform / $name"
        echo "$yaml"
        echo ""
    else
        echo -n "  $platform/$name ($target) ... "
        if echo "$yaml" | kubectl apply -n "$NAMESPACE" -f - >/dev/null 2>&1; then
            echo "submitted"
        else
            # Job may already exist — try deleting and resubmitting
            kubectl delete job "$job_name" -n "$NAMESPACE" --ignore-not-found=true >/dev/null 2>&1
            if echo "$yaml" | kubectl apply -n "$NAMESPACE" -f - >/dev/null 2>&1; then
                echo "resubmitted"
            else
                echo "FAILED"
                echo "$yaml" | kubectl apply -n "$NAMESPACE" -f - 2>&1 | sed 's/^/    /'
            fi
        fi
    fi
done

if [[ "$DRY_RUN" == false ]]; then
    echo ""
    echo "Monitor with:"
    echo "  ./k8s/run.sh --status"
    echo "  kubectl logs -f job/hightide-<platform>-<design> -n $NAMESPACE"
fi
