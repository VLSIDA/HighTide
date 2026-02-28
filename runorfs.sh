#!/bin/bash
cd OpenROAD-flow-scripts
tag=$(git describe --tags --abbrev=8 2>/dev/null)
if [ -z "$tag" ]; then
  echo "Warning: Commit is not on an exact tag."
  tag="v3.0-3201-gf53fbce7" # fallback tag or handle error
fi
echo "Running OpenROAD flow with tag: ${tag}"
docker run --rm -it \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v $(pwd)/flow:/OpenROAD-flow-scripts/flow \
  -v $(pwd)/..:/OpenROAD-flow-scripts/UCSC_ML_suite \
  -w /OpenROAD-flow-scripts/UCSC_ML_suite \
  -e DISPLAY=${DISPLAY} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${HOME}/.Xauthority:/.Xauthority \
  --network host \
  --security-opt seccomp=unconfined \
  openroad/orfs:${tag} \
  "$@"
