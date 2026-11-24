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
#   --branch BRANCH    Git branch to build (default: main, NOT the checked-out
#                      branch — pass --branch when building any other branch,
#                      or the pod builds main and cache-replays its results)
#   --cpu NUM          CPU request per job (overrides design_resources.conf)
#   --mem SIZE         Memory request per job (overrides design_resources.conf)
#   --upload-artifacts Save build artifacts (bazel-bin) to the hightide-artifacts PVC for debug
#   --dry-run          Print generated YAML without submitting
#   --status           Show status of submitted jobs
#   --delete           Delete jobs (filtered by platform/design args)
#
# Per-design resource sizing lives in k8s/design_resources.conf (CPU, memory,
# and ephemeral-storage). --cpu / --mem are job-wide overrides; for one-off
# resource bumps just edit the conf file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="${HIGHTIDE_JOB_TEMPLATE:-$SCRIPT_DIR/job-template.yaml}"
RESOURCES_CONF="$SCRIPT_DIR/design_resources.conf"
NAMESPACE="vlsida"

# Defaults
BRANCH="main"
CLI_CPU=""             # --cpu N (empty = use design_resources.conf)
CLI_MEM=""             # --mem N (empty = use design_resources.conf)
DRY_RUN=false
MODE="submit"
UPLOAD_ARTIFACTS="false"
FILTER_PLATFORM=""
FILTER_DESIGN=""

# Resolve a resource value from design_resources.conf for the given design.
# Tries <platform>/<design>, falls back to "defaults", then to the supplied
# default. Reads from $RESOURCES_CONF.
read_resource() {
  local key="$1" design_id="$2" fallback="$3"
  if [[ -f "$RESOURCES_CONF" ]]; then
    local val
    for tag in "$design_id" defaults; do
      val=$(awk -v t="$tag" -v k="$key" '
        $1 == t {
          for (i = 2; i <= NF; i++) {
            n = split($i, a, "=")
            if (n == 2 && a[1] == k) { print a[2]; exit }
          }
        }' "$RESOURCES_CONF")
      [[ -n "$val" ]] && { echo "$val"; return; }
    done
  fi
  echo "$fallback"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --branch)
    BRANCH="$2"
    shift 2
    ;;
  --cpu)
    CLI_CPU="$2"
    shift 2
    ;;
  --mem)
    CLI_MEM="$2"
    shift 2
    ;;
  --upload-artifacts)
    UPLOAD_ARTIFACTS=true
    shift
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --status)
    MODE="status"
    shift
    ;;
  --delete)
    MODE="delete"
    shift
    ;;
  --design)
    FILTER_DESIGN="$2"
    shift 2
    ;;
  -h | --help)
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

# User label for filtering (only show/delete your own jobs)
USER_LABEL=$(echo "$USER" | tr '[:upper:]' '[:lower:]')

# Handle status/delete modes
if [[ "$MODE" == "status" ]]; then
  echo "Jobs in namespace $NAMESPACE (user: $USER_LABEL):"
  kubectl get jobs -n "$NAMESPACE" -l app=hightide,user="$USER_LABEL" \
    -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[0].type,COMPLETIONS:.status.succeeded,FAILURES:.status.failed,AGE:.metadata.creationTimestamp' \
    2>/dev/null || kubectl get jobs -n "$NAMESPACE" -l app=hightide,user="$USER_LABEL"
  echo ""
  echo "Pods:"
  kubectl get pods -n "$NAMESPACE" -l app=hightide,user="$USER_LABEL" \
    -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName' \
    2>/dev/null || kubectl get pods -n "$NAMESPACE" -l app=hightide,user="$USER_LABEL"
  exit 0
fi

if [[ "$MODE" == "delete" ]]; then
  LABEL_SELECTOR="app=hightide,user=$USER_LABEL"
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

  # Find matching jobs first so we can list and (if >3) confirm.
  matched_jobs=()
  while read -r jobname; do
    [[ -n "$jobname" ]] && matched_jobs+=("$jobname")
  done < <(kubectl get jobs -n "$NAMESPACE" -l "$LABEL_SELECTOR" \
    -o name 2>/dev/null | sed 's|^job\.batch/||' | sort)

  if [[ ${#matched_jobs[@]} -eq 0 ]]; then
    echo "No matching jobs to delete (selector: $LABEL_SELECTOR)."
    exit 0
  fi

  echo "Jobs to delete ($DESC, ${#matched_jobs[@]}):"
  for j in "${matched_jobs[@]}"; do
    echo "  $j"
  done
  echo ""

  if [[ ${#matched_jobs[@]} -gt 3 ]]; then
    read -r -p "Delete ${#matched_jobs[@]} jobs from $NAMESPACE? [y/N] " reply || reply=""
    if [[ ! "$reply" =~ ^[yY] ]]; then
      echo "Aborted."
      exit 1
    fi
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
    # Build through the gallery, not just _final: <name>_gallery has
    # src=:<name>_final, so this runs the whole RTL-to-GDS flow AND
    # renders+caches the gallery PNG. That makes update-results a pure
    # fast cache fetch instead of re-rendering every design locally.
    local target="//designs/$relpath:${name}_gallery"

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
    design_dir="${relpath#*/}" # strip platform prefix
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

echo "Designs to submit (${#DESIGNS[@]}):"
for entry in "${DESIGNS[@]}"; do
  IFS='|' read -r platform name _ _ <<<"$entry"
  echo "  $platform/$name"
done
echo ""

if [[ "$DRY_RUN" == false && ${#DESIGNS[@]} -gt 3 ]]; then
  read -r -p "Submit ${#DESIGNS[@]} jobs to $NAMESPACE? [y/N] " reply || reply=""
  if [[ ! "$reply" =~ ^[yY] ]]; then
    echo "Aborted."
    exit 1
  fi
fi

echo "Submitting ${#DESIGNS[@]} job(s) to NRP Nautilus ($NAMESPACE)..."
echo "  Branch: $BRANCH"
if [[ -n "$CLI_CPU" || -n "$CLI_MEM" ]]; then
  echo "  CLI overrides: ${CLI_CPU:+CPU=$CLI_CPU} ${CLI_MEM:+memory=$CLI_MEM}"
fi
echo "  Per-design resources from: $RESOURCES_CONF"
echo ""

# Generate and submit jobs
for entry in "${DESIGNS[@]}"; do
  IFS='|' read -r platform name relpath target <<<"$entry"

  # Create a DNS-safe job name with username prefix
  leaf_name="${relpath##*/}"
  job_name="${USER}-hightide-${platform}-${leaf_name}"
  job_name=$(echo "$job_name" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | cut -c1-63)

  # Resolve resources: CLI flag > design entry > defaults entry > fallback.
  design_id="$platform/$leaf_name"
  if [[ -n "$CLI_CPU" ]]; then
    # limit == request: NRP policy (limits within 20% of requests), and an
    # integer request == limit gives Guaranteed QoS, i.e. an exclusive
    # cpuset, so OpenROAD's thread count == the request.
    cpu_request="$CLI_CPU"
    cpu_limit="$CLI_CPU"
  else
    cpu_request=$(read_resource cpu_req "$design_id" 4)
    cpu_limit=$(read_resource cpu_lim "$design_id" "$cpu_request")
  fi
  if [[ -n "$CLI_MEM" ]]; then
    mem_request="$CLI_MEM"
    mem_num="${CLI_MEM%Gi}"
    mem_limit="$((mem_num * 2))Gi"
  else
    mem_request=$(read_resource mem_req "$design_id" 32Gi)
    mem_default_lim="${mem_request%Gi}"
    mem_limit=$(read_resource mem_lim "$design_id" "$((mem_default_lim * 2))Gi")
  fi
  eph_request=$(read_resource eph_req "$design_id" 50Gi)
  eph_limit=$(read_resource eph_lim "$design_id" 100Gi)

  # Generate YAML from template
  yaml=$(sed \
    -e "s|__JOB_NAME__|${job_name}|g" \
    -e "s|__BRANCH__|${BRANCH}|g" \
    -e "s|__BAZEL_TARGET__|${target}|g" \
    -e "s|__UPLOAD_ARTIFACTS__|${UPLOAD_ARTIFACTS}|g" \
    -e "s|__CPU_REQUEST__|${cpu_request}|g" \
    -e "s|__CPU_LIMIT__|${cpu_limit}|g" \
    -e "s|__MEM_REQUEST__|${mem_request}|g" \
    -e "s|__MEM_LIMIT__|${mem_limit}|g" \
    -e "s|__EPH_REQUEST__|${eph_request}|g" \
    -e "s|__EPH_LIMIT__|${eph_limit}|g" \
    "$TEMPLATE")

  # Add labels for filtering
  user_label=$(echo "$USER" | tr '[:upper:]' '[:lower:]')
  yaml=$(echo "$yaml" | sed '/^  template:$/a\    metadata:\n      labels:\n        app: hightide\n        user: '"$user_label"'\n        platform: '"$platform"'\n        design: '"$(echo "$name" | tr '[:upper:]' '[:lower:]')"'')

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
