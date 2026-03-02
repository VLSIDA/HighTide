#!/usr/bin/env bash
set -euo pipefail

cd -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ── Install/locate JDK 11 ─────────────────────────────────────────────
ROOT_DIR="$(cd ../../../.. && pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
JDK_PREFIX="${PKG_ROOT}/openjdk-11"

if [[ -x "${JDK_PREFIX}/bin/java" ]]; then
  echo "Using local JDK at ${JDK_PREFIX}"
  export JAVA_HOME="${JDK_PREFIX}"
  export PATH="${JAVA_HOME}/bin:${PATH}"
elif command -v java >/dev/null 2>&1; then
  JAVA_VER=$(java -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/')
  if [ "$JAVA_VER" -lt 11 ] 2>/dev/null; then
    echo "System Java is version $JAVA_VER; need 11+. Installing locally..."
  else
    echo "Using system Java (version $JAVA_VER)"
  fi
fi

if ! command -v java >/dev/null 2>&1 || { JAVA_VER=$(java -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/'); [ "$JAVA_VER" -lt 11 ] 2>/dev/null; }; then
  echo "Installing OpenJDK 11 locally..."
  TB_NAME="openjdk-11.0.2_linux-x64_bin.tar.gz"
  URL="https://download.java.net/java/GA/jdk11/9/GPL/${TB_NAME}"
  TARBALLS="${PKG_ROOT}/_tarballs"
  BUILD="${PKG_ROOT}/_build"
  TB="${TARBALLS}/${TB_NAME}"
  STAGE="${BUILD}/openjdk-11-stage"

  mkdir -p "${TARBALLS}" "${BUILD}"

  if [[ ! -f "${TB}" ]]; then
    curl -L --fail --retry 3 --retry-delay 2 -o "${TB}" "${URL}"
  fi

  rm -rf "${STAGE}"
  mkdir -p "${STAGE}"
  tar -xzf "${TB}" -C "${STAGE}"

  JDK_DIR="$(ls -d "${STAGE}"/jdk-* 2>/dev/null | head -1)"
  if [[ -z "${JDK_DIR}" || ! -d "${JDK_DIR}" ]]; then
    echo "Error: Could not locate extracted JDK directory" >&2
    exit 1
  fi

  rm -rf "${JDK_PREFIX}"
  mv "${JDK_DIR}" "${JDK_PREFIX}"
  rm -rf "${STAGE}"

  export JAVA_HOME="${JDK_PREFIX}"
  export PATH="${JAVA_HOME}/bin:${PATH}"
  echo "OpenJDK 11 installed to ${JDK_PREFIX}"
fi

# ── Copy pure-Chisel source files from repo ─────────────────────────────
REPO_SRC=repo/src/main/scala/gemmini
BUILD_SRC=src/main/scala/gemmini

if [ ! -d "$REPO_SRC" ]; then
  echo "Error: Repo source not found at $REPO_SRC. Run 'git submodule update --init'." >&2
  exit 1
fi

for f in PE.scala Tile.scala Mesh.scala Dataflow.scala Util.scala; do
  cp "$REPO_SRC/$f" "$BUILD_SRC/$f"
done
echo "Copied source files from repo."

# ── Install sbt locally if not on PATH ──────────────────────────────────
if ! command -v sbt >/dev/null 2>&1; then
  SBT_VER=1.9.7
  if [ ! -f "sbt/bin/sbt" ]; then
    echo "Installing sbt $SBT_VER locally..."
    curl -fsSL "https://github.com/sbt/sbt/releases/download/v${SBT_VER}/sbt-${SBT_VER}.tgz" | tar xz
  fi
  export PATH="$PWD/sbt/bin:$PATH"
fi

# ── Generate Verilog ────────────────────────────────────────────────────
echo "Generating Verilog via sbt..."
sbt "runMain gemmini.GemminiMeshEmitter"

if [ ! -f generated/gemmini.v ]; then
  echo "Error: Verilog generation failed — generated/gemmini.v not found." >&2
  exit 1
fi

# ── Promote to release location ───────────────────────────────────────
cp generated/gemmini.v ../gemmini.v
echo "Verilog generation complete: promoted to designs/src/gemmini/gemmini.v"
