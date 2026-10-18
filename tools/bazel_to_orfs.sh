#!/usr/bin/env bash
#
# Prepare a HighTide bazel design as a self-contained, portable
# OpenROAD-flow-scripts (ORFS) bundle — so OpenROAD researchers can run the
# RTL-to-GDS flow in plain ORFS (a custom openroad binary, modified flow Tcl,
# added/changed steps, different constraints) with no bazel and no HighTide
# checkout, on any machine.
#
# For each design it materializes the RTL via bazel (fetching the hermetic
# http_archive sources / running any RTL genrules — but NOT synthesis),
# extracts the resolved ORFS config.mk (tools/bazel_to_config_mk.sh --abs), and
# copies every input into a self-contained, relocatable bundle:
#
#   <work-dir>/
#     inputs/      every design input — RTL, includes, SDC, LEF/LIB, tcl.
#                  config.mk references them via $(PREPARED_INPUTS), so the
#                  bundle resolves wherever it is copied.
#     config.mk    the resolved ORFS design config.
#     run.sh       runs the full flow from RTL against an ORFS install.
#
# The bundle runs the whole flow FROM RTL (synth -> finish), so the machine
# that runs it needs an OpenROAD-flow-scripts install whose tools/install has
# yosys + yosys-slang, plus an openroad binary.  (For the pure-bazel full flow
# with zero setup, just `bazel build //designs/<plat>/<design>:<design>_final`.)
#
# Default is to PREPARE only and print run instructions; pass --run to also run
# the bundle locally.
#
# Usage:
#   tools/bazel_to_orfs.sh [options] <target> [make-target...]
#
# <target> is one design, or a bazel-style pattern for many:
#   designs/asap7/lfsr            one design
#   designs/asap7/NVDLA           a container -> all its sub-designs
#   //designs/asap7/...           all asap7 designs (recursive wildcard)
#   //designs/...  |  all         every design, every platform
#   asap7 | nangate45 | sky130hd  all designs on that platform
# With a multi-design target it prepares (or, with --run, runs) each in turn,
# continuing past failures and printing a summary.
#
# Options:
#   --run            After preparing, run the bundle now (needs --flow-home).
#   --benchmark-dir DIR
#                    Export inputs under DIR/designs/ and copy each pinned
#                    ORFS platform once under DIR/platforms/. Export-only
#                    unless combined with --run.
#   --flow-home DIR  ORFS install to run against (its flow/ dir or root); its
#                    tools/install must have yosys + yosys-slang.  Required with
#                    --run; also baked into run.sh as the default FLOW_HOME.
#   --openroad BIN   openroad executable (OPENROAD_EXE) to bake into run.sh and
#                    use with --run.  Default: the ORFS install's own openroad.
#   --work-dir DIR   Bundle directory.  Default: <repo>/.orfs_bundles/<plat>/<design>.
#   --config FILE    Use this config.mk instead of extracting one.
#   --no-build       Skip the bazel RTL materialization (assume inputs exist).
#   -h, --help       Print this help and exit.
#
# make-target default: "synth floorplan place cts route finish"
#
# Examples:
#   # Prepare one design (bundle + instructions, no run):
#   tools/bazel_to_orfs.sh designs/asap7/lfsr
#   # Export all benchmark RTL, design inputs, and shared platform trees only:
#   tools/bazel_to_orfs.sh --benchmark-dir .hightide_export all
#   # Prepare every asap7 design as portable bundles:
#   tools/bazel_to_orfs.sh //designs/asap7/...
#   # Run a prepared bundle elsewhere (self-contained, no bazel):
#   FLOW_HOME=~/OpenROAD-flow-scripts OPENROAD_EXE=~/OpenROAD/build/src/openroad \
#     .orfs_bundles/asap7/lfsr/run.sh
#   # Prepare + run locally against your ORFS install, through placement:
#   tools/bazel_to_orfs.sh --run --flow-home ~/OpenROAD-flow-scripts \
#     designs/asap7/lfsr synth floorplan place
#
# QoR comparability: HighTide's published numbers come from the bazel-orfs
# build.  A bundle reproduces them only if the ORFS install's yosys / openroad
# match the commits bazel-orfs pins (printed on --run); otherwise the baseline
# shifts and some config.mk workaround vars may be stale.

set -euo pipefail

usage() {
    sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 1
}

require_bazel() {
    command -v bazel >/dev/null 2>&1 && return
    cat >&2 <<'EOF'
ERROR: 'bazel' is not installed or not on PATH.
HighTide resolves each design's configuration with Bazel (via Bazelisk).
Install Bazelisk (recommended — it auto-fetches the pinned Bazel version):
  Linux x86_64:
    sudo curl -fsSL -o /usr/local/bin/bazel \
      https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
    sudo chmod +x /usr/local/bin/bazel
  npm:  npm install -g @bazelbuild/bazelisk
  go:   go install github.com/bazelbuild/bazelisk@latest
More:   https://github.com/bazelbuild/bazelisk
EOF
    exit 1
}

# The Bazel build (and the patches/ symlinks it references) need the
# bazel-orfs submodule checked out — otherwise bazel fails deep in repo
# fetch with a cryptic "Cannot find patch file" error.
require_bazel_orfs() {
    [ -f "$repo_root/bazel-orfs/MODULE.bazel" ] && return
    cat >&2 <<'EOF'
ERROR: the bazel-orfs submodule is not initialized.
HighTide's Bazel build needs it (the patches/ files are symlinks into it).
Run, from the repo root:
  git submodule update --init bazel-orfs
EOF
    exit 1
}

flow_home=""
openroad=""
work_dir=""
config=""
benchmark_dir=""
no_build=0
run=0          # default: prepare the portable bundle only, don't run ORFS
positional=()
flags=()   # design-independent flags, replayed to per-design child invocations

while [ $# -gt 0 ]; do
    case "$1" in
        --run)       run=1;        flags+=("$1");      shift ;;
        --benchmark-dir)
                       benchmark_dir=$2; shift 2 ;;
        --flow-home) flow_home=$2; flags+=("$1" "$2"); shift 2 ;;
        --openroad)  openroad=$2;  flags+=("$1" "$2"); shift 2 ;;
        --work-dir)  work_dir=$2;  shift 2 ;;   # per-design; not replayed
        --config)    config=$2;    shift 2 ;;   # per-design; not replayed
        --no-build)  no_build=1;   flags+=("$1");      shift ;;
        # accepted for back-compat; preparing is now the default (no-op)
        --prepare-only|--no-run) flags+=("$1"); shift ;;
        -h|--help)   usage ;;
        --)          shift; while [ $# -gt 0 ]; do positional+=("$1"); shift; done ;;
        -*)          echo "ERROR: unknown option: $1" >&2; usage ;;
        *)           positional+=("$1"); shift ;;
    esac
done

[ "${#positional[@]}" -ge 1 ] || usage
input=${positional[0]}
# The bundle always runs the full flow from RTL (synth onward); the default
# make targets reflect that.  Extra positional args override them.
targets=("${positional[@]:1}")
[ "${#targets[@]}" -ne 0 ] || targets=(synth floorplan place cts route finish)

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

if [ -n "$benchmark_dir" ]; then
    [ -z "$work_dir" ] || { echo "ERROR: --benchmark-dir and --work-dir are mutually exclusive." >&2; exit 1; }
    benchmark_dir=$(python3 -c 'import os, sys; print(os.path.abspath(sys.argv[1]))' "$benchmark_dir")
    flags+=(--benchmark-dir "$benchmark_dir")
fi

# Every runnable design is a leaf package whose BUILD.bazel calls
# hightide_design()/orfs_flow(). Container packages (NVDLA, bp_processor) and
# platform dirs (designs/asap7) don't — they just hold subpackages.
enumerate_designs() {   # <dir> -> prints each design package under it
    find "$1" -name BUILD.bazel 2>/dev/null | sort | while read -r bf; do
        grep -Eq '^[[:space:]]*(hightide_design|orfs_flow)\(' "$bf" && dirname "$bf"
    done
}

# --- Expand the input into a design list ----------------------------------
# Bazel-style recursive wildcard is the primary syntax:
#   //designs/...            all designs, every platform
#   designs/asap7/...        all asap7 designs
#   //designs/asap7/NVDLA/...  every NVDLA partition
# Also accepted: the "all" alias and a bare platform (asap7|nangate45|
# sky130hd); a bare container/platform dir (designs/asap7/NVDLA) expands to
# its sub-designs; anything else is a single design package/label.
design_list=()
sel=${input#//}                 # tolerate the leading // of a bazel label
case "$sel" in
    all|ALL|designs|designs/) root="designs" ;;
    asap7|nangate45|sky130hd) root="designs/$sel" ;;
    *...) root=${sel%...}; root=${root%/}; [ -n "$root" ] || root="designs" ;;
    *)    root="" ;;
esac

if [ -n "$root" ]; then
    [ -d "$root" ] || { echo "ERROR: no such directory: $root" >&2; exit 1; }
    mapfile -t design_list < <(enumerate_designs "$root")
else
    p=${sel%:*}; p=${p%/}       # drop any :target and trailing slash
    if [ -f "$p/BUILD.bazel" ] && grep -Eq '^[[:space:]]*(hightide_design|orfs_flow)\(' "$p/BUILD.bazel"; then
        design_list=("$p")                              # a single design
    elif [ -d "$p" ]; then
        mapfile -t design_list < <(enumerate_designs "$p")  # container/platform dir
    fi
fi

if [ "${#design_list[@]}" -eq 0 ]; then
    echo "ERROR: no HighTide designs match '$input'." >&2
    echo "       Give a design dir (designs/asap7/lfsr), a container" >&2
    echo "       (designs/asap7/NVDLA), a platform (asap7|nangate45|sky130hd)," >&2
    echo "       or 'all'." >&2
    exit 1
fi

# --- Batch: >1 design → run each in its own child invocation --------------
# Replays the design-independent flags + targets to a fresh bazel_to_orfs.sh per
# design (keeps all the single-design logic in one place). Continues past a
# failure and reports a summary. Per-design --work-dir/--config make no sense
# across a batch.
if [ "${#design_list[@]}" -gt 1 ]; then
    [ -z "$config" ]   || { echo "ERROR: --config can't be used with multiple designs." >&2; exit 1; }
    [ -z "$work_dir" ] || { echo "ERROR: --work-dir can't be used with multiple designs." >&2; exit 1; }
    echo ">> ${#design_list[@]} designs matched:" >&2
    printf '   %s\n' "${design_list[@]}" >&2
    failed=()
    for d in "${design_list[@]}"; do
        printf '\n======== %s ========\n' "$d" >&2
        "$0" "${flags[@]}" "$d" "${targets[@]}" || failed+=("$d")
    done
    if [ "${#failed[@]}" -gt 0 ]; then
        printf '\nFAILED (%d/%d):\n' "${#failed[@]}" "${#design_list[@]}" >&2
        printf '   %s\n' "${failed[@]}" >&2
        exit 1
    fi
    printf '\n>> all %d designs OK\n' "${#design_list[@]}" >&2
    exit 0
fi

pkg=${design_list[0]}

# Design target base name (first quoted value after `name =` in the
# hightide_design()/orfs_flow() call).
name=$(awk -F'"' '
    /hightide_design\(|orfs_flow\(/ { in_call = 1 }
    in_call && /name[[:space:]]*=/  { print $2; exit }' "$pkg/BUILD.bazel")
if [ -z "$name" ]; then
    echo "ERROR: could not find name in $pkg/BUILD.bazel" >&2
    exit 1
fi

# --- Work dir + repo/orfs bookkeeping -------------------------------------
if [ -n "$benchmark_dir" ]; then
    work_dir="$benchmark_dir/designs/${pkg#designs/}"
elif [ -z "$work_dir" ]; then
    rel=${pkg#designs/}
    work_dir="$repo_root/.orfs_bundles/${rel%%/*}/${rel##*/}"
fi
mkdir -p "$work_dir"
platform=${pkg#designs/}; platform=${platform%%/*}
orfs_commit=$(grep -oP 'OpenROAD-flow-scripts-\K[0-9a-f]{40}' MODULE.bazel | head -1)

stage_benchmark_platform() {
    local output_base platforms_src source_id
    source_id="$orfs_commit:$(git hash-object MODULE.bazel)"
    echo ">> Staging pinned ORFS platform files for $platform ..." >&2
    output_base=$(bazel info output_base 2>/dev/null)
    platforms_src=""
    while IFS= read -r candidate; do
        if [ -f "$candidate/$platform/config.mk" ]; then
            platforms_src=$candidate
            break
        fi
    done < <(find -L "$output_base/external" -maxdepth 4 -type d \
        -path '*/flow/platforms' 2>/dev/null)
    [ -n "$platforms_src" ] || {
        echo "ERROR: could not locate the Bazel-managed ORFS platform '$platform'." >&2
        exit 1
    }
    python3 "$repo_root/tools/stage_platform.py" \
        "$platforms_src" "$platform" "$benchmark_dir/platforms" "$source_id"
}

# --- Materialize the RTL, extract config, stage a portable bundle ---------
# For hermetic designs the RTL / includes live in the bazel cache (http_archive
# fetches + RTL genrules), so materialize the design's verilog_files first —
# this fetches the archives and runs any RTL genrules, but NOT synthesis — then
# extract the resolved config and copy every input into a self-contained bundle
# (inputs/ + config.mk with $(PREPARED_INPUTS)-relative paths).
require_bazel; require_bazel_orfs
if [ "$no_build" = 0 ]; then
    echo ">> Materializing RTL for //$pkg:${name} ..." >&2
    vfiles=$(bazel cquery --output=label \
        "labels(verilog_files, //$pkg:${name}_synth)" 2>/dev/null \
        | awk '{print $1}' | sort -u)   # strip cquery's " (config-hash)" suffix
    [ -n "$vfiles" ] && bazel build $vfiles >&2
fi

if [ -n "$benchmark_dir" ]; then
    stage_benchmark_platform
fi

if [ -z "$config" ]; then
    config="$work_dir/config.mk"
    echo ">> Extracting config.mk -> $config" >&2
    tools/bazel_to_config_mk.sh --abs "$pkg" "$config"
fi
config=$(realpath "$config")

if [ -n "$benchmark_dir" ] && ! [ "$config" -ef "$work_dir/config.mk" ]; then
    cp "$config" "$work_dir/config.mk"
    config="$work_dir/config.mk"
fi

echo ">> Staging inputs into $work_dir/inputs (portable, self-contained) ..." >&2
stage_args=()
if [ -n "$benchmark_dir" ]; then
    stage_args+=(
        --manifest "$work_dir/manifest.json"
        --platform-dir "$benchmark_dir/platforms/$platform"
    )
fi
python3 "$repo_root/tools/stage_prepared_inputs.py" \
    "${stage_args[@]}" "$config" "$work_dir/inputs" >&2

if [ -n "$benchmark_dir" ]; then
    design_rel=${work_dir#"$benchmark_dir"/}
    cat >> "$config" <<EOF

# Portable HighTide benchmark roots. Set HIGHTIDE_BUNDLE_ROOT to the export
# directory before resolving this Make-compatible configuration.
export PREPARED_INPUTS?=\$(HIGHTIDE_BUNDLE_ROOT)/$design_rel/inputs
export PLATFORM_DIR?=\$(HIGHTIDE_BUNDLE_ROOT)/platforms/$platform
EOF
    if [ "$run" = 0 ]; then
        cat >&2 <<EOF

>> Exported benchmark inputs only — $platform / $name
   design    : $work_dir
   platform  : $benchmark_dir/platforms/$platform
   manifest  : $work_dir/manifest.json
   config    : $config

   No synthesis or physical-design flow was run. Point your tool adapter at
   this export and set HIGHTIDE_BUNDLE_ROOT=$benchmark_dir when resolving
   config.mk.
EOF
        exit 0
    fi
fi

# --- Resolve ORFS flow + openroad (only needed to actually --run) ----------
# The bundle runs the whole flow from RTL, so a run needs an ORFS install whose
# tools/install has yosys + yosys-slang (bazel-orfs's own ORFS flow does not
# ship a yosys binary).  Preparing needs neither.
flow_dir=""
if [ -n "$flow_home" ]; then
    if   [ -f "$flow_home/flow/Makefile" ]; then flow_dir="$flow_home/flow"
    elif [ -f "$flow_home/Makefile" ];      then flow_dir="$flow_home"
    else echo "ERROR: no ORFS Makefile under --flow-home $flow_home" >&2; exit 1
    fi
fi
openroad_exe="$openroad"
opensta_exe=""
[ -z "$openroad_exe" ] || [ -x "$openroad_exe" ] || {
    echo "ERROR: openroad not executable: $openroad_exe" >&2; exit 1; }

# --- Write the self-contained, portable run.sh ----------------------------
# The bundle (inputs/ + config.mk + run.sh) can be copied to any machine and
# run with no bazel and no HighTide checkout — given an ORFS install (with
# yosys + yosys-slang) and an openroad on that machine.  config.mk references
# every input via $(PREPARED_INPUTS), which run.sh points at its own inputs/.
run_script="$work_dir/run.sh"
def_or=""; [ -n "$openroad_exe" ] && def_or=$(printf '%q' "$openroad_exe")
def_sta=""; [ -n "$opensta_exe" ] && def_sta=$(printf '%q' "$opensta_exe")
tq=""; for t in "${targets[@]}"; do tq+=" $(printf '%q' "$t")"; done
{
    echo '#!/usr/bin/env bash'
    echo '# Auto-generated by tools/bazel_to_orfs.sh.  Self-contained portable bundle:'
    echo '# inputs/ + config.mk + run.sh — copy this whole dir to any machine and'
    echo '# run the full ORFS flow from RTL, with no bazel and no HighTide checkout.'
    echo '# The target machine needs an OpenROAD-flow-scripts install whose'
    echo '# tools/install has yosys + yosys-slang, plus an openroad binary:'
    echo '#   FLOW_HOME=/path/to/OpenROAD-flow-scripts \'
    echo '#   OPENROAD_EXE=/path/to/openroad ./run.sh'
    echo '#   ./run.sh floorplan place                  # pick targets'
    echo 'set -euo pipefail'
    echo 'here="$(cd "$(dirname "$0")" && pwd)"'
    echo 'cd "$here"'
    echo '# Inputs were staged under this bundle; config.mk references them via'
    echo '# $(PREPARED_INPUTS), so they resolve wherever the bundle is copied.'
    echo 'export PREPARED_INPUTS="$here/inputs"'
    if [ -n "$benchmark_dir" ]; then
        root_rel=$(python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' \
            "$benchmark_dir" "$work_dir")
        printf 'export HIGHTIDE_BUNDLE_ROOT="$(cd "$here/%s" && pwd)"\n' "$root_rel"
    fi
    printf 'flow_home=${FLOW_HOME:-%q}\n' "$flow_dir"
    printf 'openroad_exe=${OPENROAD_EXE:-%s}\n' "${def_or:-\"\"}"
    printf 'opensta_exe=${OPENSTA_EXE:-%s}\n' "${def_sta:-\"\"}"
    printf 'default_targets=(%s )\n' "$tq"
    echo 'if [ -z "$flow_home" ]; then'
    echo '  echo "ERROR: set FLOW_HOME to an OpenROAD-flow-scripts install (tools/install with yosys+slang)." >&2'
    echo '  exit 1'
    echo 'fi'
    echo '[ -f "$flow_home/flow/Makefile" ] && flow_home="$flow_home/flow"'
    echo 'if [ "$#" -gt 0 ]; then targets=("$@"); else targets=("${default_targets[@]}"); fi'
    echo 'exec make -C "$flow_home" \'
    echo '    DESIGN_CONFIG="$here/config.mk" \'
    echo '    WORK_HOME="$here" \'
    echo '    FLOW_HOME="$flow_home" \'
    echo '    ${openroad_exe:+OPENROAD_EXE="$openroad_exe"} \'
    echo '    ${opensta_exe:+OPENSTA_EXE="$opensta_exe"} \'
    echo '    "${targets[@]}"'
} > "$run_script"
chmod +x "$run_script"

# --- Default: prepared — print instructions.  --run: run it now. ----------
if [ "$run" = 0 ]; then
    cat >&2 <<EOF

>> Prepared (not run) — $platform / $name
   bundle   : $work_dir
              (portable: inputs/ + config.mk + run.sh; copy it anywhere)
   targets  : ${targets[*]}

   Run it — on this or any machine (needs an ORFS install with yosys + slang):
     FLOW_HOME=/path/to/OpenROAD-flow-scripts \\
     OPENROAD_EXE=/path/to/openroad \\
       $run_script

   Or run now on this machine:  tools/bazel_to_orfs.sh --run --flow-home <ORFS> $pkg
EOF
    exit 0
fi

# --- --run: execute the prepared bundle locally ---------------------------
if [ -z "$flow_dir" ]; then
    echo "ERROR: --run needs an ORFS install with yosys + yosys-slang." >&2
    echo "       Pass --flow-home <OpenROAD-flow-scripts> (tools/install must have yosys)." >&2
    echo "       (bazel-orfs's own ORFS flow ships no yosys, so it can't synthesize;" >&2
    echo "        for the pure-bazel full flow use 'bazel build //$pkg:${name}_final'.)" >&2
    exit 1
fi
cat >&2 <<EOF
>> Running upstream ORFS — $platform / $name
   flow_home  : $flow_dir
   openroad   : ${openroad_exe:-<ORFS install default>}
   work_home  : $work_dir
   targets    : ${targets[*]}
   (golden ORFS commit bazel pins: $orfs_commit)
EOF
exec "$run_script" "${targets[@]}"
