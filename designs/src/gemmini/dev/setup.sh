#!/usr/bin/env bash
set -euo pipefail

cd -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ── Install/locate JDK 17 ─────────────────────────────────────────────
JDK_PREFIX="$(pwd)/openjdk-17"

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
  echo "Installing OpenJDK 17 locally..."
  TB_NAME="openjdk-17_linux-x64_bin.tar.gz"
  URL="https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/${TB_NAME}"
  TB="${JDK_PREFIX}/${TB_NAME}"

  mkdir -p "${JDK_PREFIX}"

  if [[ ! -f "${TB}" ]]; then
    curl -L --fail --retry 3 --retry-delay 2 -o "${TB}" "${URL}"
  fi

  tar -xzf "${TB}" -C "${JDK_PREFIX}" --strip-components=1

  if [[ ! -x "${JDK_PREFIX}/bin/java" ]]; then
    echo "Error: java binary not found after extraction" >&2
    exit 1
  fi

  rm -f "${TB}"

  export JAVA_HOME="${JDK_PREFIX}"
  export PATH="${JAVA_HOME}/bin:${PATH}"
  echo "OpenJDK 17 installed to ${JDK_PREFIX}"
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
