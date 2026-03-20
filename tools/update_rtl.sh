#!/bin/bash
# Helper for Bazel genrules to initialize git submodules and generate RTL.
# Called from genrule cmd with: bash tools/update_rtl.sh <submodule_path> <setup_script> <output_files...>
#
# Arguments:
#   $1 - submodule path relative to workspace root (e.g., designs/src/sha3/dev/repo)
#   $2 - setup script relative to workspace root (e.g., designs/src/sha3/dev/setup.sh)
#   $3... - output files to copy from the setup script's working dir to Bazel outputs
#
# The script resolves the workspace root by following symlinks from the execroot,
# initializes the git submodule, runs the setup script, and copies outputs.

set -e

SUBMODULE_PATH="$1"
SETUP_SCRIPT="$2"
shift 2

# Find workspace root by following the symlink of the setup script
REAL_SETUP=$(readlink -f "$SETUP_SCRIPT")
SETUP_REL_PATH="$SETUP_SCRIPT"
WORKSPACE_ROOT="${REAL_SETUP%/$SETUP_REL_PATH}"

# Initialize git submodule from the workspace root
cd "$WORKSPACE_ROOT"
git submodule update --init "$SUBMODULE_PATH" >&2

# Run the setup/generation script from its directory
SETUP_DIR=$(dirname "$REAL_SETUP")
cd "$SETUP_DIR"
bash "$(basename "$REAL_SETUP")" >&2
