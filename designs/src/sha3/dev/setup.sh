#!/usr/bin/env bash
set -euo pipefail

cd -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ── Check Java ──────────────────────────────────────────────────────────
if ! command -v java >/dev/null 2>&1; then
  echo "Error: Java (JDK 11+) is required but not found." >&2
  exit 1
fi

JAVA_VER=$(java -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/')
if [ "$JAVA_VER" -lt 11 ] 2>/dev/null; then
  echo "Error: Java 11+ required, found version $JAVA_VER" >&2
  exit 1
fi

# ── Copy pure-Chisel source files from repo ─────────────────────────────
REPO_SRC=repo/src/main/scala
BUILD_SRC=src/main/scala/sha3

if [ ! -d "$REPO_SRC" ]; then
  echo "Error: Repo source not found at $REPO_SRC. Run 'git submodule update --init'." >&2
  exit 1
fi

for f in theta.scala rhopi.scala chi.scala iota.scala common.scala constants.scala; do
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
sbt "runMain sha3.Sha3Emitter"

if [ ! -f generated/sha3.v ]; then
  echo "Error: Verilog generation failed — generated/sha3.v not found." >&2
  exit 1
fi

echo "Verilog generation complete: generated/sha3.v"
