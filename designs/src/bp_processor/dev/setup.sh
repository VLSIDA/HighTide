#!/usr/bin/env bash
# Build script for Black-Parrot RISC-V multicore processor.
# Converts SystemVerilog sources to Verilog-2005 via sv2v,
# using the canonical file list from bp_top/flist.vcs.

set -eu

DIR="$(dirname "$(readlink -f "$0")")"
cd "$DIR"

PROC=-1

function usage() {
    cat << EOF

Usage: $0 [-h|--help] [-t|--threads N]

Options:
    -h, --help          Print this help message.
    -t, --threads N     Use N cpus when compiling software.

EOF
}

while (( "$#" )); do
    case "$1" in
        -h|--help)
            usage 2>/dev/null
            exit
            ;;
        -t|--threads)
            PROC="$2"
            shift
            ;;
        -*|--*)
            echo "[ERROR] Unsupported flag $1." >&2
            usage 2>/dev/null
            exit 1
            ;;
    esac
    shift
done

if [[ "$PROC" == "-1" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PROC=$(nproc --all)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PROC=$(sysctl -n hw.ncpu)
    else
        PROC=2
    fi
fi

# ── Locate or build sv2v ───────────────────────────────────────────────
if command -v sv2v >/dev/null 2>&1; then
    SV2V="$(command -v sv2v)"
    echo "Using system sv2v: $SV2V"
elif [ -f "./sv2v" ]; then
    SV2V="./sv2v"
    echo "Using local sv2v"
else
    echo "sv2v not found. Downloading prebuilt binary..."
    SV2V_ZIP="sv2v-Linux.zip"
    curl -sSL -o "$SV2V_ZIP" \
        "https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip"
    unzip -o "$SV2V_ZIP" -d sv2v_extract
    cp sv2v_extract/sv2v ./sv2v
    chmod +x ./sv2v
    rm -rf "$SV2V_ZIP" sv2v_extract
    SV2V="./sv2v"
    echo "sv2v binary downloaded successfully!"
fi

# ── Check that BP repo is initialized ───────────────────────────────────
BP_REPO="$(pwd)/repo"
if [ ! -d "$BP_REPO/bp_top" ]; then
    echo "Error: Black-Parrot repo not found at $BP_REPO."
    echo "Run: git submodule update --init designs/src/black_parrot/dev/repo"
    exit 1
fi

# ── Fetch BP dependencies (external submodules) ────────────────────────
if [ ! -d "$BP_REPO/external/basejump_stl/bsg_misc" ]; then
    echo "Fetching Black-Parrot dependencies..."
    cd "$BP_REPO"
    git submodule update --init --recursive
    cd "$DIR"
else
    echo "Black-Parrot dependencies already present"
fi

# ── Parse flist.vcs to get include dirs and source files ───────────────
echo "Parsing bp_top/flist.vcs..."

FLIST="$BP_REPO/bp_top/flist.vcs"
if [ ! -f "$FLIST" ]; then
    echo "Error: $FLIST not found" >&2
    exit 1
fi

SV2V_ARGS=()

while IFS= read -r line; do
    # Strip comments and whitespace
    line="${line%%//*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    [[ "$line" == \#* ]] && continue

    # Replace $BP_DIR with actual path
    line="${line//\$BP_DIR/$BP_REPO}"

    if [[ "$line" == +incdir+* ]]; then
        inc_path="${line#+incdir+}"
        if [ -d "$inc_path" ]; then
            SV2V_ARGS+=("-I$inc_path")
        else
            echo "Warning: include dir not found: $inc_path"
        fi
    elif [[ "$line" == +* ]] || [[ "$line" == -* ]]; then
        # Skip other VCS directives
        continue
    elif [ -f "$line" ]; then
        SV2V_ARGS+=("$line")
    else
        echo "Warning: source file not found: $line"
    fi
done < "$FLIST"

echo "Collected ${#SV2V_ARGS[@]} arguments (includes + sources)"

# ── Run sv2v conversion ────────────────────────────────────────────────
mkdir -p generated

echo "Running sv2v conversion (this may take several minutes)..."
$SV2V \
    --top bp_processor \
    "${SV2V_ARGS[@]}" \
    -w generated/bp_processor.v \
    2>&1 | tee generated/sv2v.log

if [ ! -f generated/bp_processor.v ] || [ ! -s generated/bp_processor.v ]; then
    echo "Error: sv2v conversion failed — generated/bp_processor.v not found or empty." >&2
    echo "Check generated/sv2v.log for details." >&2
    exit 1
fi

echo "sv2v conversion complete: generated/bp_processor.v"
echo "$(wc -l < generated/bp_processor.v) lines generated"

# ── Post-process: strip bsg_mem_*_synth module definitions ────────────
# These contain parameterized register arrays that cause ABC OOM.
# macros.v provides FakeRAM-backed replacements.
echo "Stripping bsg_mem_*_synth module definitions..."
python3 "$DIR/patch_mem.py" generated/bp_processor.v generated/bp_processor.v

# ── Generate FakeRAM LEF/LIB and macros.v ─────────────────────────────
# Find the ASAP7 platform directory (relative to the HighTide root).
HIGHTIDE_ROOT="$(cd "$DIR/../../../.." && pwd)"
SRAM_DIR="$HIGHTIDE_ROOT/designs/asap7/bp_processor/sram"
MACROS_V="$HIGHTIDE_ROOT/designs/asap7/bp_processor/macros.v"

echo "Generating FakeRAM files and macros.v..."
python3 "$DIR/gen_fakeram.py" "$SRAM_DIR" "$MACROS_V"

echo ""
echo "Setup complete. Generated files:"
echo "  RTL:      generated/bp_processor.v"
echo "  FakeRAM:  $SRAM_DIR/lef/ and $SRAM_DIR/lib/"
echo "  Macros:   $MACROS_V"
echo "Review generated/sv2v.log for any warnings."
