#!/bin/bash

set -e

echo "Starting Setup..."

# Change to the script's directory to ensure .venv is created in the right place
export LITEETH_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/repo" && pwd)"
export LITEETH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$LITEETH_DIR" && echo "Working in directory: $(pwd)"

if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

echo "Activating virtual environment..."
source .venv/bin/activate

check_package() {
    ! pip show "$1" &>/dev/null
}

install_git_package() {
    local package_name="$1"
    local repo_url="$2" 
    local commit_hash="$3"
    
    echo "Installing $package_name (this may take a while)..."
    
    # Try direct pip install first
    if pip install --no-cache-dir "git+${repo_url}@${commit_hash}" 2>/dev/null; then
        echo "Successfully installed $package_name"
        return 0
    fi
    echo "$package_name installation failed!" >&2
    return 1
}

if pip --version 2>/dev/null | grep -q "25.1.1"; then
    echo "Pip 25.1.1 is already installed, skipping upgrade..."
else
    echo "Installing/upgrading pip to 25.1.1..."
    pip install --upgrade pip==25.1.1 --no-cache-dir
fi

echo "Checking Python packages..."

if check_package PyYAML; then
    echo "Installing PyYAML..."
    pip install --no-cache-dir pyyaml==6.0.2
fi

if check_package migen; then
    install_git_package "MiGen" "https://github.com/m-labs/migen.git" "4c2ae8dfeea37f235b52acb8166f12acaaae4f7c" 
fi

if check_package litex; then
    install_git_package "LiteX" "https://github.com/enjoy-digital/litex.git" "a25eeecd27309b2a04a9cf74a1d4849e38ff2090"
fi

if check_package liteeth; then
    install_git_package "LiteEth" "https://github.com/enjoy-digital/liteeth.git" "ef5f9ee0cbf1fb4afe0a23a68367c17e95ffb162"
fi

if check_package liteiclink; then
    install_git_package "LiteICLink" "https://github.com/enjoy-digital/liteiclink.git" "ef9c29506c9c8e5d733a54403c6a9ec1df5babd5"
fi

REPO_LICENSE="$LITEETH_REPO/LICENSE"
PARENT_LICENSE="../LICENSE"

if [ ! -f "$PARENT_LICENSE" ]; then
    echo "Copying $REPO_LICENSE -> $(cd .. && pwd)/LICENSE"
    cp -u "$REPO_LICENSE" "$PARENT_LICENSE"
else
    echo "LICENSE file already exists at parent directory, skipping copy"
fi

echo "Finished Initial Setup"

if [ -n "$DESIGN_NAME" ]; then
    LITEETH_DIR="$(dirname "$LITEETH_DIR")"   # step up from dev/ to liteeth/
    YML_PATH="${LITEETH_DIR}/dev/repo/examples"
    TARGET_FILE="${LITEETH_DIR}/${DESIGN_NAME}.v"

    case "$DESIGN_NAME" in
        liteeth_mac_axi_mii)
            YAML_FILE="axi-lite-mii.yml"
            PATCH_FILE="mac_axi_mii.patch"
            ;;
        liteeth_mac_wb_mii)
            YAML_FILE="wishbone_mii.yml"
            PATCH_FILE="mac_wb_mii.patch"
            ;;
        liteeth_udp_raw_rgmii)
            YAML_FILE="udp_raw_ecp5rgmii.yml"
            PATCH_FILE="udp_raw_rgmii.patch"
            ;;
        liteeth_udp_stream_rgmii)
            YAML_FILE="udp_s7phyrgmii.yml"
            PATCH_FILE="udp_stream_rgmii.patch"
            ;;
        liteeth_udp_stream_sgmii)
            YAML_FILE="udp_a7_gtp_sgmii.yml"
            PATCH_FILE="udp_stream_sgmii.patch"
            ;;
        liteeth_udp_usp_gth_sgmii)
            YAML_FILE="udp_usp_gth_sgmii.yml"
            PATCH_FILE="udp_usp_gth_sgmii.patch"
            ;;
        *)
            echo "[ERROR] Unknown DESIGN_NAME: ${DESIGN_NAME}" >&2
            usage
            exit 1
            ;;
    esac

    TARGET_YML="${YML_PATH}/${YAML_FILE}"
    PATCH_FILE_PATH="${LITEETH_DIR}/dev/patch/${PATCH_FILE}"
    GEN_CORE_NAME="${DESIGN_NAME}_build"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BUILD_DIR_NAME="archive"

    echo "Regenerating ${DESIGN_NAME}..."
    echo "${LITEETH_DIR}"
    echo "Setting up ${DESIGN_NAME}..."

    cd "${LITEETH_DIR}/dev"

    [ -d "${LITEETH_DIR}/dev/build" ] && rm -rf build && echo "Cleaning previous build..."

    python3 "${LITEETH_DIR}/dev/repo/liteeth/gen.py" "${TARGET_YML}" && echo "Generating liteeth core..."

    cp "${LITEETH_DIR}/dev/build/gateware/liteeth_core.v" "${TARGET_FILE}" && echo "Copying verilog files..."

    ARCHIVE_DIR="${LITEETH_DIR}/dev/${BUILD_DIR_NAME}/${GEN_CORE_NAME}_${TIMESTAMP}"
    mkdir -p "${ARCHIVE_DIR}"
    cp -r "${LITEETH_DIR}/dev/build/"* "${ARCHIVE_DIR}/" && echo "Build archived"

    [ -d "${LITEETH_DIR}/dev/build" ] && rm -rf build

    patch --silent -N -l "${TARGET_FILE}" < "${PATCH_FILE_PATH}" || true
    echo "Done."
else
    echo "No --design-name specified, skipping RTL generation."
fi