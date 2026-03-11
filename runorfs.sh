#!/bin/bash
cd OpenROAD-flow-scripts
ORFS_TAG="26Q1-510-g44e0991fc"
LOCAL_TAG=$(git describe --tags --abbrev=9 2>/dev/null)
if [[ "$LOCAL_TAG" != "$ORFS_TAG" ]]; then
  echo "Warning: Commit is not on correct tag. Local tag is $LOCAL_TAG"
  LOCAL_TAG=$ORFS_TAG # fallback tag or handle error
fi
echo "Running OpenROAD flow with tag: ${LOCAL_TAG}"
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
  openroad/orfs:${LOCAL_TAG}
  "$@"
