#!/usr/bin/env bash
# ============================================================
# setup_srecord.sh — Build & install SRecord 1.65 locally
# Installs into ./srecord relative to where you run it
# Supports: Linux (x86_64 / arm64) and macOS (x86_64 / arm64)
# ============================================================

set -euo pipefail

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"

cd ..

SRECORD_VERSION="1.65"
SRECORD_NAME="1.65.0-Linux"
INSTALL_DIR="$(pwd)/srecord"
BUILD_DIR="$(pwd)/srecord-build"

SOURCE_URL="https://sourceforge.net/projects/srecord/files/srecord/${SRECORD_VERSION}/srecord-${SRECORD_NAME}.tar.gz/download"
TARBALL_NAME="srecord-${SRECORD_VERSION}.tar.gz"

echo "============================================"
echo "  SRecord ${SRECORD_VERSION} Setup"
echo "  Install : ${INSTALL_DIR}"
echo "============================================"

# Check if install already exists
if [[ -x "${INSTALL_DIR}/bin/srec_cat" ]]; then
  echo "SRecord already installed at ${INSTALL_DIR}/bin/"
  exit 0
fi

# Check OS
OS="$(uname -s)"

# Ensure required dependencies exist
echo ""
echo "Checking build dependencies..."

MISSING=()
for dep in cmake g++ make tar; do
  command -v "${dep}" &>/dev/null || MISSING+=("${dep}")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Missing required tools: ${MISSING[*]}"
  exit 1
fi

echo "Done."

# Source Download
echo ""
echo "Downloading SRecord (${SRECORD_VERSION}) from ${SOURCE_URL}"
echo ""

mkdir -p "${BUILD_DIR}"
TARBALL="${BUILD_DIR}/${TARBALL_NAME}"

if command -v curl &>/dev/null; then
  curl -fsSL --progress-bar -L "${SOURCE_URL}" -o "${TARBALL}"
elif command -v wget &>/dev/null; then
  wget -q --show-progress "${SOURCE_URL}" -O "${TARBALL}"
else
  echo "Neither curl nor wget found."
  exit 1
fi

# Extract tarball
echo "Extracting..."
tar -xzf "${TARBALL}" -C "${BUILD_DIR}"

SOURCE_DIR="$(find "${BUILD_DIR}" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
if [[ -z "${SOURCE_DIR}" ]]; then
  echo "Could not find extracted source directory in ${BUILD_DIR}"
  exit 1
fi
echo "    Source dir: ${SOURCE_DIR}"

# Config/Build/Install stage
if [[ -f "${SOURCE_DIR}/CMakeLists.txt" ]]; then
  
  CMAKE_BUILD_DIR="${BUILD_DIR}/cmake-build"
  mkdir -p "${CMAKE_BUILD_DIR}"

  # Config
  echo ""
  echo "Configuring with CMake..."
  cmake -S "${SOURCE_DIR}" \
        -B "${CMAKE_BUILD_DIR}" \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -Wno-dev \
        --no-warn-unused-cli \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON

  # Build
  echo ""
  echo "Building SRecord ${SRECORD_VERSION}..."
  echo ""
  JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
  cmake --build "${CMAKE_BUILD_DIR}" --parallel "${JOBS}"

  # Install
  echo ""
  echo "Installing to ${INSTALL_DIR}..."
  cmake --install "${CMAKE_BUILD_DIR}"

else
  # Pre-built binary tarball, only file install needed
  echo ""
  echo "Pre-built binary detected, copying files to ${INSTALL_DIR}..."
  mkdir -p "${INSTALL_DIR}"
  cp -r "${SOURCE_DIR}/." "${INSTALL_DIR}/"
  # Ensure binaries are executable
  find "${INSTALL_DIR}/bin" -type f -exec chmod +x {} \; 2>/dev/null || \
  find "${INSTALL_DIR}" -maxdepth 1 -type f -name "srec_*" -exec chmod +x {} \;
fi

# Verify installation was succesful
echo ""
echo "Verifying installation..."

BINS=("srec_cat" "srec_cmp" "srec_info")
ALL_OK=true

for bin in "${BINS[@]}"; do
  # Check both ./bin/<bin> and ./<bin>
  if [[ -x "${INSTALL_DIR}/bin/${bin}" ]]; then
    echo "  ${bin}  →  ${INSTALL_DIR}/bin/${bin}"
  elif [[ -x "${INSTALL_DIR}/${bin}" ]]; then
    echo "  ${bin}  →  ${INSTALL_DIR}/${bin}"
  else
    echo "  ${bin} not found under ${INSTALL_DIR}"
    ALL_OK=false
  fi
done

if [[ "${ALL_OK}" != "true" ]]; then
  echo ""
  echo "Binaries are missing, the build failed."
  exit 1
fi

# Clean SRecord build files
echo ""
echo "Cleaning up build files..."
rm -rf "${BUILD_DIR}"

echo "Done! SRecord bin files have been installed to ${INSTALL_DIR}/bin."
