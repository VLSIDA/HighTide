#!/usr/bin/env bash
# ============================================================
# setup_bazel.sh — Install Bazel 7.4.1 locally
# Supports: Linux (x86_64 / arm64) and macOS (x86_64 / arm64)
# ============================================================

set -euo pipefail

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"
cd ..
# Set specific bazel version, install dir, and binary location
BAZEL_VERSION="7.4.1"
INSTALL_DIR="$(pwd)"
BAZEL_BIN="${INSTALL_DIR}/bazel"

# Check for aarch64 or x86_64 architectures (mac/linux)
OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  PLATFORM="linux-x86_64" ;;
      aarch64) PLATFORM="linux-arm64"  ;;
      *)       echo "Unsupported Linux arch: ${ARCH}"; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64) PLATFORM="darwin-x86_64" ;;
      arm64)  PLATFORM="darwin-arm64"  ;;
      *)      echo "Unsupported macOS arch: ${ARCH}"; exit 1 ;;
    esac
    ;;
  *)
    echo "Unsupported OS: ${OS}"
    exit 1
    ;;
esac

# Set download to download bazel version
DOWNLOAD_URL="https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-${PLATFORM}"

echo "============================================"
echo "  Bazel ${BAZEL_VERSION} Setup"
echo "  Platform : ${PLATFORM}"
echo "  Install  : ${BAZEL_BIN}"
echo "============================================"

# Check to see if bazel has already been installed
# check to see if needed bazel version is already being used
# Check if python version is already installed
if [[ -x "${BAZEL_BIN}" ]]; then
  echo "Bazel ${BAZEL_VERSION} is already installed at ${BAZEL_BIN}"
  exit 0
fi


# Download
echo ""
echo "Downloading ${DOWNLOAD_URL}"
echo ""



if command -v curl &>/dev/null; then
  curl -fsSL --progress-bar "${DOWNLOAD_URL}" -o "${BAZEL_BIN}"
elif command -v wget &>/dev/null; then
  wget -q --show-progress "${DOWNLOAD_URL}" -O "${BAZEL_BIN}"
else
  echo "Neither curl nor wget found. Please install one and retry."
  exit 1
fi

# make the bin an executable
chmod +x "${BAZEL_BIN}"

# ensure that download was succesful
echo "Verifying installation..."
INSTALLED_VERSION="$("${BAZEL_BIN}" --version 2>/dev/null | awk '{print $2}')"

if [[ "${INSTALLED_VERSION}" == "${BAZEL_VERSION}" ]]; then
  echo "Bazel ${INSTALLED_VERSION} installed successfully!"
else
  echo "Version mismatch — expected ${BAZEL_VERSION}, got ${INSTALLED_VERSION}"
  exit 1
fi

echo ""
echo "Done! Run '${INSTALL_DIR}/bazel --version' in the working directory to confirm."
