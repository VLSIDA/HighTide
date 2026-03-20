#!/bin/bash
# Extract Docker image from MODULE.bazel (single source of truth)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_IMAGE=$(grep -oP 'image\s*=\s*"\K[^"]+' "$SCRIPT_DIR/MODULE.bazel")

if [ -z "$DOCKER_IMAGE" ]; then
  echo "ERROR: Could not extract Docker image from MODULE.bazel"
  exit 1
fi

echo "Running OpenROAD flow with image: ${DOCKER_IMAGE}"
cd OpenROAD-flow-scripts
docker run --rm -it \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v $(pwd)/flow:/OpenROAD-flow-scripts/flow \
  -v $(pwd)/..:/OpenROAD-flow-scripts/HighTide \
  -w /OpenROAD-flow-scripts/HighTide \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${HOME}/.Xauthority:/.Xauthority \
  --network host \
  --security-opt seccomp=unconfined \
  ${DOCKER_IMAGE} \
  "$@"