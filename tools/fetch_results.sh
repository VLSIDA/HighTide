#!/bin/bash
# Fetch a design's published reports (6_report.json, *_final_report.{json,rpt}, gallery
# png) straight from the R2 results index — no bazel, no credentials.
# Jobs publish these at results/<platform>/<design-path>/<git-sha>/ with a
# `latest` pointer; see k8s/job-template.yaml.
#
# Usage: ./tools/fetch_results.sh <platform> <design-path> [out-dir]
#   e.g. ./tools/fetch_results.sh asap7 sha3
#        ./tools/fetch_results.sh gt2n NVDLA/partition_o /tmp/po
set -euo pipefail
BASE="${RESULTS_BASE:-https://cache.hightide-benchmarks.dev}"
plat=$1; des=$2; out=${3:-./results-fetch/$1-$(basename $2)}
sha=$(curl -fsS "$BASE/results/$plat/$des/latest" | tr -d '[:space:]')
[ -n "$sha" ] || { echo "no published results for $plat/$des" >&2; exit 1; }
mkdir -p "$out"
ok=0
for f in 6_report.json "$(basename $des)_final_report.json" "$(basename $des)_final_report.rpt" bp_processor_final_report.json bp_processor_final_report.rpt "$(basename $des)_grt_report.json" bp_processor_grt_report.json; do
  curl -fsS "$BASE/results/$plat/$des/$sha/$f" -o "$out/$f" 2>/dev/null && ok=$((ok+1)) || true
done
# gallery name varies; try common pattern
for g in $(basename $des)_gallery.png bp_processor_gallery.png; do
  curl -fsS "$BASE/results/$plat/$des/$sha/$g" -o "$out/$g" 2>/dev/null && { ok=$((ok+1)); break; } || rm -f "$out/$g"
done
echo "fetched $ok files for $plat/$des @ $sha -> $out"
