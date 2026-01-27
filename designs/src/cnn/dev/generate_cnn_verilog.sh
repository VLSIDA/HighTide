#!/usr/bin/env bash
set -euo pipefail


VENV_DIR="${VENV_DIR:-.venv}"

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  echo "Venv not found" >&2
  exit 1
fi

# Prepend venv bin to PATH for this process only
export PATH="$VENV_DIR/bin:$PATH"
source "$VENV_DIR/bin/activate"

TARGET_DIR="${1:-repo}"
VERILOG_OUT="${2:-cnn.v}"
REQUIRED_PY_MODULES=(veriloggen numpy onnx)

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required but not found." >&2
  exit 1
fi

check_python_modules() {
  local missing_modules
  missing_modules=$(python3 - "$@" <<'PY'
import importlib.util
import sys
missing = [name for name in sys.argv[1:] if importlib.util.find_spec(name) is None]
print(" ".join(missing))
PY
)
  if [ -n "$missing_modules" ]; then
    echo "Missing Python packages detected: $missing_modules" >&2
    echo "Run ./setup.sh to install requirements." >&2
    exit 1
  fi
}

check_python_modules "${REQUIRED_PY_MODULES[@]}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: expected NNgen submodule at '$TARGET_DIR'." >&2
  echo "Run: git submodule update --init designs/src/cnn/dev/repo" >&2
  exit 1
fi

pushd "$TARGET_DIR" >/dev/null

python3 - "$VERILOG_OUT" <<'PY'
import glob
import os
import shutil
import sys

output_path = os.path.abspath(sys.argv[1])
repo_root = os.path.abspath(os.path.dirname(__file__))

if repo_root not in sys.path:
    sys.path.insert(0, repo_root)

from examples.cnn import cnn

try:
    cnn.run(simtype=None, silent=False, verilog_filename=output_path)
except SystemExit as exc:
    # NNgen examples exit early when simulation is disabled; treat code 0 as success.
    if exc.code not in (None, 0):
        raise

verilog_candidates = glob.glob(os.path.join(repo_root, 'cnn_v*', 'hdl', 'cnn.v'))
if not verilog_candidates:
    raise FileNotFoundError('Unable to locate generated Verilog under cnn_v*/hdl/cnn.v')

# Use the most recent match in case multiple runs exist.
verilog_source = max(verilog_candidates, key=os.path.getmtime)
os.makedirs(os.path.dirname(output_path), exist_ok=True)
shutil.copy2(verilog_source, output_path)

print(f"Verilog RTL written to {output_path}")
PY

popd >/dev/null
cp "$TARGET_DIR/cnn.v" cnn.v
echo "CNN Verilog generated at ./cnn.v"
deactivate
./replace_rams_with_fakerams.sh
