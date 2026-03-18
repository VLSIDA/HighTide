#!/usr/bin/env bash
# Build script for Snitch Cluster (PULP Platform).
# Uses clustergen to generate the cluster wrapper from a config,
# Bender for dependency management, and outputs SystemVerilog file lists
# for yosys-slang (no sv2v conversion needed).
# Top module: snitch_cluster_wrapper

set -euo pipefail

DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

# ── Ensure git safe.directory is set (needed inside Docker) ──────────
git config --global --add safe.directory '*' 2>/dev/null || true

# ── Locate or download bender ────────────────────────────────────────
if command -v bender >/dev/null 2>&1; then
    BENDER="$(command -v bender)"
    echo "Using system bender: $BENDER"
elif [ -f "$DIR/bender" ]; then
    BENDER="$DIR/bender"
    echo "Using local bender"
elif [ -f "$DIR/../../../src/floonoc/dev/bender" ]; then
    # Reuse bender from floonoc if available
    BENDER="$(readlink -f "$DIR/../../../src/floonoc/dev/bender")"
    echo "Using floonoc bender: $BENDER"
else
    echo "bender not found. Downloading prebuilt binary..."
    BENDER_VERSION="0.28.2"
    BENDER_TAR="bender-${BENDER_VERSION}-x86_64-linux-gnu-ubuntu22.04.tar.gz"
    curl -sSL -o "$BENDER_TAR" \
        "https://github.com/pulp-platform/bender/releases/download/v${BENDER_VERSION}/${BENDER_TAR}"
    tar xzf "$BENDER_TAR"
    rm -f "$BENDER_TAR"
    chmod +x ./bender
    BENDER="$DIR/bender"
    echo "bender binary downloaded successfully!"
fi

# ── Check that snitch_cluster repo is initialized ────────────────────
REPO="$(pwd)/repo"
if [ ! -f "$REPO/Bender.yml" ]; then
    echo "Error: snitch_cluster repo not found at $REPO."
    echo "Run: git submodule update --init designs/src/snitch_cluster/dev/repo"
    exit 1
fi

# ── Fetch Bender dependencies ────────────────────────────────────────
cd "$REPO"
if [ ! -d ".bender" ]; then
    echo "Fetching Bender dependencies..."
    "$BENDER" checkout
else
    echo "Bender dependencies already present"
fi

# ── Install clustergen dependencies and generate wrapper ─────────────
cd "$DIR"
VENV_DIR="$DIR/.venv"
if [ ! -x "$VENV_DIR/bin/python" ]; then
    echo "Creating venv for clustergen..."
    python3 -m venv "$VENV_DIR"
fi
export PATH="$VENV_DIR/bin:$PATH"
source "$VENV_DIR/bin/activate"

# Install clustergen dependencies
pip install --quiet json5 jsonref mako jsonschema 2>/dev/null || true

# Generate cluster wrapper and package from config
mkdir -p generated
CFG="$DIR/cluster_cfg.json"
if [ ! -f "$CFG" ]; then
    echo "Using default cluster config"
    CFG="$REPO/cfg/default.json"
fi

CLUSTERGEN="$REPO/util/clustergen/clustergen.py"
WRAPPER_TPL="$REPO/hw/snitch_cluster/src/snitch_cluster_wrapper.sv.tpl"
PKG_TPL="$REPO/hw/snitch_cluster/src/snitch_cluster_pkg.sv.tpl"

echo "Generating snitch_cluster_wrapper.sv..."
python3 "$CLUSTERGEN" -c "$CFG" -o generated/snitch_cluster_wrapper.sv --template "$WRAPPER_TPL"

echo "Generating snitch_cluster_pkg.sv..."
python3 "$CLUSTERGEN" -c "$CFG" -o generated/snitch_cluster_pkg.sv --template "$PKG_TPL"

# Generate bootrom (needed by the cluster)
# Use patched version: combinational logic instead of large ROM array
echo "Installing patched snitch_bootrom.sv..."
cp "$DIR/patches/snitch_bootrom.sv" "$DIR/generated/snitch_bootrom.sv"

# Generate peripheral registers (needed by the cluster)
# Check if peakrdl is available; if not, check for pre-generated files
PERIPH_DIR="$REPO/hw/snitch_cluster/src/snitch_cluster_peripheral"
if [ ! -f "$PERIPH_DIR/snitch_cluster_peripheral_reg.sv" ]; then
    if command -v peakrdl >/dev/null 2>&1; then
        echo "Generating peripheral registers with peakRDL..."
        # Generate the RDL from template first
        RDL_TPL="$REPO/hw/snitch_cluster/src/snitch_cluster.rdl.tpl"
        python3 "$CLUSTERGEN" -c "$CFG" -o generated/snitch_cluster.rdl --template "$RDL_TPL"
        peakrdl regblock generated/snitch_cluster.rdl -o "$PERIPH_DIR" --cpuif apb4-flat --default-reset arst_n
    else
        echo "Warning: peakrdl not available. Installing..."
        pip install --quiet peakrdl-regblock 2>/dev/null || true
        RDL_TPL="$REPO/hw/snitch_cluster/src/snitch_cluster.rdl.tpl"
        python3 "$CLUSTERGEN" -c "$CFG" -o generated/snitch_cluster.rdl --template "$RDL_TPL"
        peakrdl regblock generated/snitch_cluster.rdl -o "$PERIPH_DIR" --cpuif apb4-flat --default-reset arst_n
    fi
fi

# Generate address map header
ADDRMAP_SVH="generated/snitch_cluster_addrmap.svh"
if [ ! -f "$ADDRMAP_SVH" ]; then
    if command -v peakrdl >/dev/null 2>&1 || pip install --quiet peakrdl-regblock 2>/dev/null; then
        RDL_FILE="generated/snitch_cluster.rdl"
        if [ ! -f "$RDL_FILE" ]; then
            RDL_TPL="$REPO/hw/snitch_cluster/src/snitch_cluster.rdl.tpl"
            python3 "$CLUSTERGEN" -c "$CFG" -o "$RDL_FILE" --template "$RDL_TPL"
        fi
        peakrdl raw-header "$RDL_FILE" -o "$ADDRMAP_SVH" --format svh -I "$PERIPH_DIR" 2>/dev/null || true
    fi
fi

# ── Generate file list via bender ────────────────────────────────────
cd "$REPO"
echo "Generating file list with bender..."
FLIST_RAW=$("$BENDER" script verilator -t rtl -t snitch_cluster -t snitch_cluster_wrapper 2>&1)

cd "$DIR"

# ── Parse bender flist into files, includes, and defines ─────────────
echo "Parsing bender flist into file lists for yosys-slang..."

SV_FILES=()
INCLUDE_DIRS=()
DEFINES=()

while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue

    if [[ "$line" == +incdir+* ]]; then
        inc_path="${line#+incdir+}"
        if [ -d "$inc_path" ]; then
            INCLUDE_DIRS+=("$inc_path")
        fi
    elif [[ "$line" == +define+* ]]; then
        define="${line#+define+}"
        DEFINES+=("$define")
    elif [[ "$line" == +* ]] || [[ "$line" == -* ]]; then
        continue
    elif [[ "$line" == *Checkout* ]] || [[ "$line" == *warning:* ]]; then
        continue
    elif [ -f "$line" ]; then
        # Skip test/simulation files
        if [[ "$line" == */test/* ]] || [[ "$line" == */tb/* ]]; then
            continue
        fi
        if [[ "$line" == */deprecated/* ]] || [[ "$line" == */common_verification* ]]; then
            continue
        fi
        # Skip files we generate ourselves (avoid duplicates)
        case "$line" in
            *snitch_bootrom.sv|*snitch_cluster_wrapper.sv|*snitch_cluster_pkg.sv) continue ;;
        esac
        # Skip original tc_sram (replaced with fakeram-backed version)
        case "$line" in
            */tc_sram.sv) continue ;;
        esac
        SV_FILES+=("$line")
    fi
done <<< "$FLIST_RAW"

# Add generated files
SV_FILES+=("$(readlink -f generated/snitch_cluster_pkg.sv)")
SV_FILES+=("$(readlink -f generated/snitch_cluster_wrapper.sv)")
SV_FILES+=("$(readlink -f generated/snitch_bootrom.sv)")
SV_FILES+=("$(readlink -f generated/tc_sram.sv)")

# Add generated include dir
INCLUDE_DIRS+=("$(readlink -f generated)")

# ── Write deduplicated output lists to generated/ ────────────────────
for f in "${SV_FILES[@]}"; do
    realpath --relative-to="$DIR" "$f"
done > generated/files.txt
for d in "${INCLUDE_DIRS[@]}"; do
    realpath --relative-to="$DIR" "$d"
done | awk '!seen[$0]++' > generated/includes.txt
printf '%s\n' "${DEFINES[@]}" | awk '!seen[$0]++' > generated/defines.txt

echo "Generated file lists:"
echo "  $(wc -l < generated/files.txt) source files"
echo "  $(wc -l < generated/includes.txt) include directories"
echo "  $(wc -l < generated/defines.txt) defines"
echo "Done. Use SYNTH_HDL_FRONTEND=slang with ORFS to synthesize."
