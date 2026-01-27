#!/usr/bin/env bash
set -euo pipefail

cd -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required but not found." >&2
  exit 1
fi

VENV_DIR="${VENV_DIR:-.venv}"

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  python3 -m venv "$VENV_DIR"
fi

# Prepend venv bin to PATH for this process only
export PATH="$VENV_DIR/bin:$PATH"
source "$VENV_DIR/bin/activate"

python3 -m pip install --no-cache-dir -r requirements.txt

./generate_cnn_verilog.sh
