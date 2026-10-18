#!/usr/bin/env bash
#
# Extract an ORFS-compatible config.mk for a HighTide design from the
# bazel-orfs flow's generated artifacts.
#
# Each flow stage exposes its resolved config as a `<stage>.mk` bazel
# output group, written by a cheap analysis-phase action. This script
# builds ONLY those config output groups — so it costs no synthesis or
# place-and-route, just bazel analysis (seconds) — then unions the
# `export VAR?=VALUE` lines across stages (different stages contribute
# different vars: floorplan → CORE_UTILIZATION, final → GDS_ALLOW_EMPTY,
# etc.), drops the Bazel-internal ones, adds the cquery-resolved
# VERILOG_FILES (the one var the .mk files omit), and emits a config.mk
# you can feed to upstream OpenROAD-flow-scripts (`make DESIGN_CONFIG=...`).
#
# Usage:
#   tools/bazel_to_config_mk.sh [--abs] <design-dir-or-label> [output-file]
#
# Options:
#   --abs   Emit absolute paths (rooted at the repo) for the path-bearing
#           vars (VERILOG_FILES, SDC_FILE, ADDITIONAL_LEFS/LIBS/GDS,
#           PDN_TCL, IO_CONSTRAINTS, FOOTPRINT_TCL, MACRO_PLACEMENT_TCL,
#           VERILOG_INCLUDE_DIRS) so the config.mk runs from any CWD and
#           against any ORFS clone. Default keeps workspace-relative paths.
#
# Examples:
#   tools/bazel_to_config_mk.sh designs/asap7/lfsr
#   tools/bazel_to_config_mk.sh --abs designs/asap7/lfsr   ./lfsr.config.mk
#   tools/bazel_to_config_mk.sh //designs/asap7/lfsr:lfsr   ./lfsr.config.mk
#   tools/bazel_to_config_mk.sh designs/asap7/liteeth/liteeth_mac_axi_mii
#
# Caveats:
# - Without --abs, VERILOG_FILES / SDC_FILE paths are workspace-relative;
#   run upstream ORFS Make from the HighTide repo root (or use --abs).
# - For designs whose RTL is generated at build time (sv2v, Chisel, or
#   Python generators), the resolved VERILOG_FILES paths point into
#   bazel-out/; build the design first so the generated sources exist.
# - PLATFORM_DIR is intentionally stripped — let ORFS Make derive it
#   from $(FLOW_HOME)/platforms/$(PLATFORM).

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
    [ -f "$(git rev-parse --show-toplevel)/bazel-orfs/MODULE.bazel" ] && return
    cat >&2 <<'EOF'
ERROR: the bazel-orfs submodule is not initialized.
HighTide's Bazel build needs it (the patches/ files are symlinks into it).
Run, from the repo root:
  git submodule update --init bazel-orfs
EOF
    exit 1
}

abs=0
positional=()
while [ $# -gt 0 ]; do
    case "$1" in
        --abs)      abs=1; shift ;;
        -h|--help)  usage ;;
        --)         shift; while [ $# -gt 0 ]; do positional+=("$1"); shift; done ;;
        -*)         echo "ERROR: unknown option: $1" >&2; usage ;;
        *)          positional+=("$1"); shift ;;
    esac
done

[ "${#positional[@]}" -ge 1 ] && [ "${#positional[@]}" -le 2 ] || usage

input=${positional[0]}
output=${positional[1]:-}

repo_root=$(git rev-parse --show-toplevel)

# --- Normalize the input to package + target name -------------------
case "$input" in
    //*:*)        # //designs/asap7/lfsr:lfsr
        label=${input#//}
        pkg=${label%:*}
        name=${label##*:}
        ;;
    //*)          # //designs/asap7/lfsr  (no :target → derive from BUILD.bazel)
        pkg=${input#//}
        name=""
        ;;
    *)            # designs/asap7/lfsr  (or with trailing /)
        pkg=${input%/}
        name=""
        ;;
esac

build_file="${pkg}/BUILD.bazel"
[ -f "$build_file" ] || {
    echo "ERROR: no $build_file" >&2
    exit 1
}

# Container packages (NVDLA, bp_processor) hold only shared filegroups; the
# real hightide_design() calls live in subpackages. List them so the user
# picks a concrete sub-design instead of getting a cryptic "no name" error.
list_subdesigns() {
    find "$1" -mindepth 2 -name BUILD.bazel 2>/dev/null | sort | while read -r bf; do
        grep -q 'hightide_design\|orfs_flow' "$bf" && dirname "$bf"
    done
}

# If no target was supplied, read the name from the hightide_design()
# (or orfs_flow()) call in BUILD.bazel — first quoted value after `name =`.
if [ -z "$name" ]; then
    name=$(awk -F'"' '
        /hightide_design\(|orfs_flow\(/   { in_call = 1 }
        in_call && /name[[:space:]]*=/    { print $2; exit }
    ' "$build_file")
    if [ -z "$name" ]; then
        subs=$(list_subdesigns "$pkg")
        if [ -n "$subs" ]; then
            {
                echo "ERROR: $pkg groups sub-designs; it has no design of its own."
                echo "Pick one:"
                echo "$subs" | sed 's|^|  tools/bazel_to_config_mk.sh |'
            } >&2
        else
            echo "ERROR: could not find name = \"...\" in $build_file" >&2
        fi
        exit 1
    fi
fi

# --- Extract config from the per-stage config files (NO flow build) -------
# Each stage exposes its resolved config as the <stage>.mk output group,
# written by a cheap analysis-phase action — so building just these groups
# costs no synthesis or place-and-route (they complete as "internal"
# actions in seconds). VERILOG_FILES is the one resolved variable the
# <stage>.mk files omit; pull it from the synth target's verilog_files
# attr via cquery (analysis only, no build).
stages=(synth floorplan place cts grt route final)
targets=()
for s in "${stages[@]}"; do targets+=("//${pkg}:${name}_${s}"); done
config_groups=1_synth.mk,2_floorplan.mk,3_place.mk,4_cts.mk,5_1_grt.mk,5_2_route.mk,6_final.mk

require_bazel
require_bazel_orfs
echo "Extracting config of //${pkg}:${name} (config only, no flow build) ..." >&2
bazel build "${targets[@]}" --output_groups="$config_groups" >&2

verilog_files=$(bazel cquery --output=files \
    "labels(verilog_files, //${pkg}:${name}_synth)" 2>/dev/null | tr '\n' ' ')

# Bazel output base: hermetic designs source RTL from http_archives, whose
# files live at $output_base/external/+_repo_rules+<repo>/... — NOT under the
# repo root (there is no repo-root external/ symlink). This location is always
# present once the repo is fetched, unlike execroot/external/, which Bazel only
# materializes per-action and prunes on cache hits. --abs routes external/
# tokens here; bazel-out/ genrule outputs resolve via the repo-root bazel-out
# convenience symlink, and repo-relative source tokens (SDC/LEF/...) via the
# repo root.
output_base=$(bazel info output_base 2>/dev/null)

# --- Locate the result dir + collect the per-stage config .mk files -------
results_root="bazel-bin/${pkg}/results"
[ -d "$results_root" ] || {
    echo "ERROR: $results_root missing after build" >&2
    exit 1
}

# Stage configs are <N>_<stage>.mk; skip the *.args.mk / *.short.mk / args.mk
# helper configs.
mapfile -t mks < <(find "$results_root" -type f -name '*.mk' \
    ! -name '*.args.mk' ! -name '*.short.mk' ! -name 'args.mk' 2>/dev/null | sort)
[ "${#mks[@]}" -gt 0 ] || {
    echo "ERROR: no per-stage *.mk under $results_root" >&2
    exit 1
}

# --- Filter + union -------------------------------------------------
# Drop Bazel-internal vars that ORFS Make computes itself or doesn't want.
SKIP_VARS='^(WORK_HOME|FLOW_VARIANT|LEC_CHECK|GENERATE_ARTIFACTS_ON_FAILURE|PLATFORM_DIR)$'

emit() {
    cat <<EOF
# Generated by tools/bazel_to_config_mk.sh from BUILD.bazel.
# Source : //${pkg}:${name}
# Reproduce:
#   bazel build //${pkg}:${name}_final
#   tools/bazel_to_config_mk.sh ${pkg}
#
# Run upstream ORFS from the HighTide repo root, e.g.:
#   make -C OpenROAD-flow-scripts/flow DESIGN_CONFIG=\$(pwd)/${pkg}/config.mk

EOF

    # `export VAR?=VALUE` → keep the first occurrence of each VAR.
    # The per-stage .mk files omit VERILOG_FILES; inject the cquery-resolved
    # list so the union is complete. With --abs, prefix each repo-relative
    # token of the path-bearing vars with the repo root (runs from any CWD).
    {
        grep -h '^export ' "${mks[@]}"
        [ -n "$verilog_files" ] && printf 'export VERILOG_FILES?=%s\n' "${verilog_files% }"
    } \
        | awk -v skip="$SKIP_VARS" -v abs="$abs" -v root="$repo_root" -v outbase="$output_base" '
            # Vars whose value is one or more file/dir paths.
            function is_pathvar(k) {
                return (k ~ /^(VERILOG_FILES|SDC_FILE|ADDITIONAL_LEFS|ADDITIONAL_LIBS|ADDITIONAL_GDS|IO_CONSTRAINTS|FOOTPRINT_TCL|MACRO_PLACEMENT_TCL|VERILOG_INCLUDE_DIRS|PDN_TCL)$/) || (k ~ /_TCL$/)
            }
            function emit_pathvar(lhs, val) {
                n = split(val, toks, /[[:space:]]+/)
                out = ""
                for (i = 1; i <= n; i++) {
                    t = toks[i]
                    if (t == "") continue
                    if (abs == "1" && t !~ /^\// && t !~ /^-/ && t !~ /^\$/) {
                        if (t ~ /^external\//)
                            t = outbase "/" t
                        else
                            t = root "/" t
                    }
                    out = (out == "" ? t : out " " t)
                }
                print lhs out
            }
            {
                pos = index($0, "?=")
                if (pos == 0) next
                lhs = substr($0, 1, pos + 1)   # includes "?="
                val = substr($0, pos + 2)
                key = lhs
                sub(/^export /, "", key)
                sub(/\?=$/, "", key)
                sub(/[[:space:]]+$/, "", key)
                if (key ~ skip)   next
                if (seen[key]++)  next

                # Slang-specific -I options must be staged like other include
                # directories, not silently discarded by the JSON exporter.
                if (key == "SYNTH_SLANG_ARGS") {
                    n = split(val, toks, /[[:space:]]+/)
                    out = ""
                    for (i = 1; i <= n; i++) {
                        t = toks[i]
                        if (t == "-I") {
                            slang_includes = slang_includes " " toks[++i]
                        } else if (t ~ /^-I/) {
                            slang_includes = slang_includes " " substr(t, 3)
                        } else {
                            out = (out == "" ? t : out " " t)
                        }
                    }
                    val = out
                }
                if (key == "VERILOG_INCLUDE_DIRS") {
                    include_dirs = val
                } else if (is_pathvar(key)) {
                    emit_pathvar(lhs, val)
                } else {
                    print lhs val
                }
            }
            END {
                if (slang_includes != "" || seen["VERILOG_INCLUDE_DIRS"])
                    emit_pathvar("export VERILOG_INCLUDE_DIRS?=", include_dirs " " slang_includes)
            }' \
        | sort
}

if [ -z "$output" ]; then
    emit
else
    emit > "$output"
    echo "Wrote $output" >&2
fi
