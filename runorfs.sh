#!/bin/bash
# Extract Docker image from MODULE.bazel to stay in sync with bazel-orfs
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
image=$(grep 'image\s*=' "$SCRIPT_DIR/MODULE.bazel" | head -1 | sed 's/.*"\(.*\)".*/\1/')
if [ -z "$image" ]; then
  echo "Error: Could not extract Docker image from MODULE.bazel"
  exit 1
fi
echo "Running OpenROAD flow with image: ${image}"
docker run --rm -it \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v $SCRIPT_DIR:/OpenROAD-flow-scripts/UCSC_ML_suite \
  -w /OpenROAD-flow-scripts/UCSC_ML_suite \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${HOME}/.Xauthority:/.Xauthority \
  --network host \
  --security-opt seccomp=unconfined \
  ${image} \
  "$@"
