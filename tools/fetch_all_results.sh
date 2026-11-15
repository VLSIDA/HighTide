#!/bin/bash
# Fetch every design's published reports from the R2 results index (the
# batch analog of fetch_results.sh): one HTTP round per pair, no bazel.
#
# Usage: ./tools/fetch_all_results.sh [out-dir] [platform-filter]
#   e.g. ./tools/fetch_all_results.sh /tmp/qor         # all platforms
#        ./tools/fetch_all_results.sh /tmp/qor gt2n    # one platform
#
# Output tree: <out>/<platform>/<design>/{6_finish.rpt,6_report.json,*_gallery.png}
# plus <out>/summary.txt (pair, sha or MISSING). Pairs never built with the
# publishing job template simply report MISSING — fall back to
# fetch_cache.sh / a rebuild for those.
set -uo pipefail
BASE="${RESULTS_BASE:-https://cache.hightide-benchmarks.dev}"
OUT=${1:-./results-fetch}
FILTER=${2:-}
cd "$(dirname "$0")/.."
SUM="$OUT/summary.txt"; mkdir -p "$OUT"; : > "$SUM"
for plat in asap7 nangate45 sky130hd gt2n; do
  [ -n "$FILTER" ] && [ "$plat" != "$FILTER" ] && continue
  for dd in designs/$plat/*/; do
    des=$(basename "$dd")
    [ "$des" = src ] && continue
    if [ "$des" = NVDLA ] || [ "$des" = bp_processor ]; then
      subs=$(ls -d "designs/$plat/$des"/*/ 2>/dev/null | xargs -rn1 basename)
      paths=""; for s in $subs; do paths="$paths $des/$s"; done
    else
      paths=$des
    fi
    for dp in $paths; do
      key=$(basename "$dp")
      sha=$(curl -fsS --max-time 15 "$BASE/results/$plat/$dp/latest" 2>/dev/null | tr -d '[:space:]')
      if [ -z "$sha" ]; then echo "$plat/$dp MISSING" >> "$SUM"; continue; fi
      d="$OUT/$plat/$key"; mkdir -p "$d"
      n=0
      for f in 6_finish.rpt 6_report.json; do
        curl -fsS --max-time 30 "$BASE/results/$plat/$dp/$sha/$f" -o "$d/$f" 2>/dev/null && n=$((n+1))
      done
      for g in ${key}_gallery.png bp_processor_gallery.png; do
        curl -fsS --max-time 60 "$BASE/results/$plat/$dp/$sha/$g" -o "$d/$g" 2>/dev/null && { n=$((n+1)); break; } || rm -f "$d/$g"
      done
      echo "$plat/$dp $sha files=$n" >> "$SUM"
    done
  done
done
awk '{if ($2=="MISSING") m++; else f++} END {printf "fetched %d pairs, %d missing (see %s)\n", f+0, m+0, "'$SUM'"}' "$SUM"
