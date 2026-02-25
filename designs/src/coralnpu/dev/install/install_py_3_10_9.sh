#!/usr/bin/env bash
# ============================================================
# setup_python.sh — Build & install Python 3.10.9 locally
# Installs into ./python-3.10.9 relative to where you run it
# Supports: Linux (x86_64 / arm64) and macOS (x86_64 / arm64)
# ============================================================

set -euo pipefail

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"

cd ..

PYTHON_VERSION="3.10.9"
INSTALL_DIR="$(pwd)/python-${PYTHON_VERSION}"
PYTHON_BIN="${INSTALL_DIR}/bin/python3"

SOURCE_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
BUILD_DIR="/tmp/python-${PYTHON_VERSION}-build"

echo "============================================"
echo "  Python ${PYTHON_VERSION} Setup"
echo "  Install : ${INSTALL_DIR}"
echo "============================================"

# Check if python version is already installed
if [[ -x "${PYTHON_BIN}" ]]; then
  echo "Python ${PYTHON_VERSION} is already installed at ${PYTHON_BIN}"
  exit 0
fi

# Ensure gcc/make/tar exist for build
echo ""
echo "Checking build dependencies..."

MISSING=()
for dep in gcc make tar; do
  command -v "${dep}" &>/dev/null || MISSING+=("${dep}")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Missing required tools: ${MISSING[*]}"
  exit 1
fi

# Download py3.10.9 from source
echo ""
echo "Downloading Python ${PYTHON_VERSION} source from ${SOURCE_URL}"   
echo ""

mkdir -p "${BUILD_DIR}"
TARBALL="${BUILD_DIR}/Python-${PYTHON_VERSION}.tgz"

if command -v curl &>/dev/null; then
  curl -fsSL --progress-bar "${SOURCE_URL}" -o "${TARBALL}"
elif command -v wget &>/dev/null; then
  wget -q --show-progress "${SOURCE_URL}" -O "${TARBALL}"
else
  echo "Neither curl nor wget found (one of these tools is needed for installation)"
  echo "Please install and retry"
  exit 1
fi

# Extract stage
echo ""
echo "Extracting..."
tar -xzf "${TARBALL}" -C "${BUILD_DIR}"

# Config stage
echo ""
echo "Configuring (this may take a moment)..."
cd "${BUILD_DIR}/Python-${PYTHON_VERSION}"

./configure \
  --prefix="${INSTALL_DIR}" \
  --enable-optimizations \
  --with-ensurepip=install \
  --quiet

# Build for py_3.10.9
echo ""
echo "Building Python ${PYTHON_VERSION}..."
echo ""

JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
make -j"${JOBS}" --quiet

echo ""
echo "Installing to ${INSTALL_DIR}..."
make install --quiet

# Verify that we've correctly installed py_3.10.9
echo ""
echo "Verifying installation..."
INSTALLED_VERSION="$("${PYTHON_BIN}" --version 2>&1 | awk '{print $2}')"
if [[ "${INSTALLED_VERSION}" == "${PYTHON_VERSION}" ]]; then
  echo "Python ${INSTALLED_VERSION} installed successfully!"
else
  echo "Version mismatch — expected ${PYTHON_VERSION}, got ${INSTALLED_VERSION}"
  exit 1
fi

# Upgrade pip?
# echo ""
# echo "Upgrading pip..."
# "${INSTALL_DIR}/bin/pip3" install --quiet --upgrade pip
# echo "pip upgraded to $("${INSTALL_DIR}/bin/pip3" --version | awk '{print $2}')"

# Remove build directory
echo ""
echo "Cleaning up build files..."
rm -rf "${BUILD_DIR}"

echo "Done! Run '${INSTALL_DIR}/bin/python3 --version' to confirm."
