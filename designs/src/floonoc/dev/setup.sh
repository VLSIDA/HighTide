#!/usr/bin/env bash
# Build script for FlooNoC (PULP Platform Network-on-Chip).
# Uses FlooGen to generate a 6x8 narrow-wide mesh topology (48 cluster endpoints),
# Bender for dependency management, and outputs SystemVerilog file lists for
# yosys-slang (no sv2v conversion needed).
# Top module: floo_floonoc_mesh_noc (generated 6x8 NW mesh with 48 routers + chimneys).

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

# ── Check that FlooNoC repo is initialized ───────────────────────────
REPO="$(pwd)/repo"
if [ ! -f "$REPO/Bender.yml" ]; then
    echo "Error: FlooNoC repo not found at $REPO."
    echo "Run: git submodule update --init designs/src/floonoc/dev/repo"
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

# ── Generate file list via bender ────────────────────────────────────
echo "Generating file list with bender..."
FLIST_RAW=$("$BENDER" script verilator -t rtl -t floo_synth 2>&1)

cd "$DIR"

# ── Install floogen in a venv and generate mesh topology ─────────────
VENV_DIR="$DIR/.venv"
if [ ! -x "$VENV_DIR/bin/python" ]; then
    echo "Creating venv for floogen..."
    python3 -m venv "$VENV_DIR"
fi
export PATH="$VENV_DIR/bin:$PATH"
source "$VENV_DIR/bin/activate"

if ! command -v floogen >/dev/null 2>&1; then
    echo "Installing floogen..."
    pip install --quiet "$REPO"
fi

echo "Generating 6x8 narrow-wide mesh topology with floogen..."
mkdir -p generated
floogen rtl -c "$DIR/mesh_config.yml" -o generated/ --no-format 2>&1 | tee generated/floogen.log

# Verify floogen output
FLOOGEN_PKG="generated/floo_floonoc_mesh_noc_pkg.sv"
FLOOGEN_TOP="generated/floo_floonoc_mesh_noc.sv"
if [ ! -f "$FLOOGEN_PKG" ] || [ ! -f "$FLOOGEN_TOP" ]; then
    echo "Error: floogen failed to generate RTL." >&2
    echo "Check generated/floogen.log for details." >&2
    exit 1
fi
echo "FlooGen generated: $FLOOGEN_PKG, $FLOOGEN_TOP"

# ── Parse bender flist into files, includes, and defines ─────────────
echo "Parsing bender flist into file lists for yosys-slang..."

SV_FILES=()
INCLUDE_DIRS=()
DEFINES=()

while IFS= read -r line; do
    # Strip whitespace
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
        # Skip files with unsynthesizable constructs
        if [[ "$line" == */deprecated/* ]] || [[ "$line" == */common_verification* ]]; then
            continue
        fi
        # Skip synthesis wrappers (we use floogen-generated top instead)
        if [[ "$line" == */hw/synth/* ]]; then
            continue
        fi
        # Skip AXI-only chimney (we use narrow-wide chimney for NW mesh)
        case "$line" in
            *floo_axi_chimney.sv) continue ;;
        esac
        SV_FILES+=("$line")
    fi
done <<< "$FLIST_RAW"

# Add floogen-generated files (package first, then top module)
SV_FILES+=("$(readlink -f "$DIR/$FLOOGEN_PKG")")
SV_FILES+=("$(readlink -f "$DIR/$FLOOGEN_TOP")")

# ── Write deduplicated output lists to generated/ ────────────────────
# Store paths relative to the dev directory so they work in Docker too.
# verilog.mk will prepend the correct base path.
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
