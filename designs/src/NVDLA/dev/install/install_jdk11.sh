#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"

NAME="openjdk-11"
PREFIX="${PKG_ROOT}/${NAME}"
TARBALLS="${PKG_ROOT}/_tarballs"
BUILD="${PKG_ROOT}/_build"

TB_NAME="openjdk-11.0.2_linux-x64_bin.tar.gz"
URL="https://download.java.net/java/GA/jdk11/9/GPL/${TB_NAME}"

TB="${TARBALLS}/${TB_NAME}"
STAGE="${BUILD}/${NAME}-stage"

mkdir -p "${TARBALLS}" "${BUILD}"

# If already installed, exit early based on the actual java binary.
if [[ -x "${PREFIX}/bin/java" ]]; then
  echo "[${NAME}] already installed at ${PREFIX}"
  echo "Use it via:"
  echo "  export JAVA_HOME=\"${PREFIX}\""
  echo "  export PATH=\"\${JAVA_HOME}/bin:\$PATH\""
  exit 0
fi

command -v tar >/dev/null 2>&1 || { echo "ERROR: Missing required command: tar" >&2; exit 1; }
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "ERROR: Need curl or wget" >&2
  exit 1
fi

if [[ ! -f "${TB}" ]]; then
  echo "[fetch] downloading: ${URL}"
  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 --retry-delay 2 -o "${TB}" "${URL}"
  else
    wget -O "${TB}" "${URL}"
  fi
else
  echo "[fetch] already exists: ${TB}"
fi

echo "[${NAME}] extracting..."
rm -rf "${STAGE}"
mkdir -p "${STAGE}"
tar -xzf "${TB}" -C "${STAGE}"

JDK_DIR="$(ls -d "${STAGE}"/jdk-* 2>/dev/null | head -1)"
if [[ -z "${JDK_DIR}" || ! -d "${JDK_DIR}" ]]; then
  echo "ERROR: Could not locate extracted JDK directory under ${STAGE}" >&2
  exit 1
fi

rm -rf "${PREFIX}"
mv "${JDK_DIR}" "${PREFIX}"
rm -rf "${STAGE}"

JAVA_BIN="${PREFIX}/bin/java"
JAR_BIN="${PREFIX}/bin/jar"
[[ -x "${JAVA_BIN}" ]] || { echo "ERROR: java binary not found at ${JAVA_BIN}" >&2; exit 1; }
[[ -x "${JAR_BIN}"  ]] || { echo "ERROR: jar binary not found at ${JAR_BIN}" >&2; exit 1; }

echo "[${NAME}] Verifying:"
"${JAVA_BIN}" -version
"${JAR_BIN}"  --version

echo
echo "[${NAME}] installed to ${PREFIX}"
echo "Add to your shell:"
echo "  export JAVA_HOME=\"${PREFIX}\""
echo "  export PATH=\"\${JAVA_HOME}/bin:\$PATH\""