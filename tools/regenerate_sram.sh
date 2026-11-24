#!/usr/bin/env bash
# tools/regenerate_sram.sh <design> <platform>
#
# Runs bsg_fakeram on designs/src/<design>/dev/generated/fakeram_<platform>.cfg
# and copies the resulting LEF/LIB files into designs/<platform>/<design>/sram/.
# The generated .v and .bb.v files stay under dev/generated/sram/<platform>/
# (yosys auto-blackboxes the macros from LEF, so the behavioral .v is not
# committed). Run from anywhere; uses git rev-parse to locate the repo root.

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <design> <platform>" >&2
  echo "  example: $0 ternip asap7" >&2
  exit 2
fi

DESIGN=$1
PLAT=$2
ROOT=$(git rev-parse --show-toplevel)

CFG="$ROOT/designs/src/$DESIGN/dev/generated/fakeram_$PLAT.cfg"
OUT="$ROOT/designs/src/$DESIGN/dev/generated/sram/$PLAT"
DST_LEF="$ROOT/designs/$PLAT/$DESIGN/sram/lef"
DST_LIB="$ROOT/designs/$PLAT/$DESIGN/sram/lib"

if [[ ! -f "$CFG" ]]; then
  echo "error: no cfg at $CFG" >&2
  exit 1
fi
# bsg_fakeram reads only camelCase snapWidth_nm/snapHeight_nm and silently uses
# a 1 nm grid on the snake_case spelling (CLAUDE.md bug table). Refuse to
# generate off-grid macros; fixing the keys is the intended path.
if grep -qE '"snap_(width|height)_nm"' "$CFG"; then
  echo "error: $CFG uses snake_case snap_width_nm/snap_height_nm, which bsg_fakeram ignores." >&2
  echo "       Rename them to snapWidth_nm/snapHeight_nm, regenerate, and drop the cfg from" >&2
  echo "       SNAKE_CASE_ALLOWLIST in tools/check_sram_cfg.py." >&2
  exit 1
fi
# Analytical tech nodes (7, 130, 2) skip CACTI entirely — only check if needed.
_TECH_NM=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['tech_nm'])" "$CFG" 2>/dev/null || echo "0")
if [[ "$_TECH_NM" != "7" && "$_TECH_NM" != "130" && "$_TECH_NM" != "2" ]]; then
  if [[ ! -x "$ROOT/tools/bsg_fakeram/tools/cacti/cacti" ]]; then
    echo "error: CACTI binary not built; run 'cd tools/bsg_fakeram && make tools'" >&2
    exit 1
  fi
fi

mkdir -p "$DST_LEF" "$DST_LIB"

# Wipe the bsg_fakeram output dir so stale macros (from an earlier cfg or a
# half-failed CACTI run) don't get copied through.
rm -rf "$OUT"
mkdir -p "$OUT"

CACTI_BUILD_DIR="$ROOT/tools/bsg_fakeram/tools/cacti" \
  python3 "$ROOT/tools/bsg_fakeram/scripts/run.py" "$CFG" --output_dir "$OUT"

# Wipe any stale LEF/LIB in the destination too.
rm -f "$DST_LEF"/*.lef "$DST_LIB"/*.lib

# Copy LEF/LIB into the per-design sram/{lef,lib}/ tree
for d in "$OUT"/*/; do
  name=$(basename "$d")
  cp "$d/$name.lef" "$DST_LEF/"
  cp "$d/$name.lib" "$DST_LIB/"
done

# wd_in pins are inputs by definition; an OUTPUT one is the bsg_fakeram
# side-vs-function bug (pre-c83ecb4) that shorts write-data buses in PnR.
bad_wd=$(grep -B1 -h 'DIRECTION[[:space:]]\+OUTPUT' "$DST_LEF"/*.lef | grep -o '[A-Za-z0-9_]*wd_in\[[0-9]*\]' || true)
if [[ -n "$bad_wd" ]]; then
  echo "error: generated LEFs declare $(wc -l <<<"$bad_wd") wd_in pin(s) DIRECTION OUTPUT; check the bsg_fakeram pin" >&2
  exit 1
fi

echo "regenerated $(ls "$OUT" | wc -l) macros for $DESIGN/$PLAT -> $DST_LEF, $DST_LIB"
echo "next: after synthesis, run tools/check_sram_usage.py $PLAT $DESIGN to confirm every macro is instantiated"
