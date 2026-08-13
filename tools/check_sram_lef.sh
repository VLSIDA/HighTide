#!/usr/bin/env bash
# tools/check_sram_lef.sh
#
# Lint every committed FakeRAM LEF for the wd_in pin-direction bug: bsg_fakeram
# before c83ecb4 set pin DIRECTION by which die side the pin landed on rather
# than by pin function, so the upper half of every write-data bus came out
# DIRECTION OUTPUT while Liberty correctly said input.  Gate-level sim then
# floats those bits and OpenROAD PnR shorts them into one net (unroutable
# GRT-0116).  See CLAUDE.md and HighTide#234.
#
# Any LEF that trips this is electrically invalid and must be regenerated with
# tools/regenerate_sram.sh.  Exits non-zero if anything is wrong.

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

bad=0
while IFS= read -r lef; do
  # A wd_in pin is an input by definition; anything else is the side-vs-function bug.
  offenders=$(grep -B1 'DIRECTION[[:space:]]\+OUTPUT' "$lef" | grep -o '[A-Za-z0-9_]*wd_in\[[0-9]*\]' || true)
  if [[ -n "$offenders" ]]; then
    n=$(wc -l <<<"$offenders")
    echo "FAIL $lef: $n wd_in pin(s) declared DIRECTION OUTPUT"
    sed 's/^/        /' <<<"$offenders"
    bad=$((bad + 1))
  fi
done < <(find designs -path '*/sram/lef/*.lef' | sort)

if (( bad )); then
  echo
  echo "$bad LEF file(s) carry the wd_in direction bug — regenerate with:"
  echo "    tools/regenerate_sram.sh <design> <platform>"
  exit 1
fi

echo "OK: no wd_in pin is declared DIRECTION OUTPUT"
