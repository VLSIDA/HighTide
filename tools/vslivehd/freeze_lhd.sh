#!/bin/bash
# Freeze the current opt lhd (binary + runfiles) as artifacts/lhdsweep/bin/<name>/lhd
# so rebuilds cannot change a measured sweep. Usage: freeze_lhd.sh NAME
set -e
NAME=$1
TREE=${LIVEHD:-/lscratch/renau/livehd}
SRC=$TREE/bazel-bin/lhd
DST=/lscratch/renau/HighTide/artifacts/lhdsweep/bin/$NAME
[ -e "$DST" ] && { echo "$DST exists"; exit 1; }
mkdir -p "$DST"
cp -L "$SRC/lhd" "$DST/lhd"
cp -rL "$SRC/lhd.runfiles" "$DST/lhd.runfiles"
chmod -R u+rwX "$DST"
sha256sum "$DST/lhd" | tee "$DST/lhd.sha256"
# Source provenance: the tree, its HEAD and a hash of its uncommitted diff (empty when clean).
{ echo "tree $TREE"; echo "head $(git -C "$TREE" rev-parse HEAD)"
  echo "dirty_diff_sha256 $(git -C "$TREE" diff HEAD | { read -r -n1 c && { printf %s "$c"; cat; } | sha256sum | cut -d' ' -f1 || echo none; })"
} > "$DST/source.txt"
