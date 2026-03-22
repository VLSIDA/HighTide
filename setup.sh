#!/bin/bash
set -e

# Extract the Docker image tag from MODULE.bazel (single source of truth)
DOCKER_IMAGE=$(grep -oP 'image\s*=\s*"\K[^"]+' MODULE.bazel)

if [ -z "$DOCKER_IMAGE" ]; then
    echo "ERROR: Could not extract Docker image from MODULE.bazel"
    exit 1
fi

echo "=== HighTide Setup ==="

# 1. Initialize ORFS submodule (used by both Make and Bazel flows)
echo "Initializing ORFS submodule..."
git submodule init OpenROAD-flow-scripts
git submodule update --recursive OpenROAD-flow-scripts

# 2. Create symlinks for Make flow
echo "Creating symlinks for Make flow..."
ln -sf OpenROAD-flow-scripts/flow/util .
ln -sf OpenROAD-flow-scripts/flow/scripts .
ln -sf OpenROAD-flow-scripts/flow/platforms .

# 3. Pull Docker image (used by both flows)
echo "Pulling Docker image: ${DOCKER_IMAGE}"
docker pull "${DOCKER_IMAGE}"

echo "=== Setup complete ==="
echo "  Make flow:  ./runorfs.sh"
echo "  Bazel flow: bazel build //designs/asap7/lfsr:lfsr_synth"
