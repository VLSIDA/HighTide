#!/bin/bash
# Generates a summary table of all completed Bazel ORFS builds.
# Usage: ./tools/summary.sh [bazel-bin path]

set -e

BIN_DIR="${1:-bazel-bin}"

if [ ! -d "$BIN_DIR" ]; then
    echo "Error: $BIN_DIR not found. Run 'bazel build //designs/...' first." >&2
    exit 1
fi

# Print commit version
COMMIT=$(git -C "$(dirname "$0")/.." rev-parse --short HEAD 2>/dev/null || echo "unknown")
echo "HighTide commit: $COMMIT"
echo ""

# Header
printf "%-12s %-25s %10s %10s %10s %8s %8s %6s %5s %10s %10s %12s %12s %6s\n" \
    "Platform" "Design" "Die Area" "Core Area" "Inst Area" "Util%" "Cells" "Macr" "IOs" "WNS" "TNS" "Fmax(GHz)" "Power(mW)" "DRCs"
printf "%s\n" "$(printf '=%.0s' {1..160})"

# Find all 6_report.json files (indicates a completed final stage)
# Deduplicate by platform/design since multiple targets may share the same output
find "$BIN_DIR/designs" -path "*/logs/*/base/6_report.json" -not -path "*.runfiles*" 2>/dev/null | sort -u | while read -r json; do
    # Extract platform/design from the logs path inside the output
    # Path: .../logs/<platform>/<design>/base/6_report.json
    logs_rel="${json##*/logs/}"
    platform="${logs_rel%%/*}"
    logs_rel="${logs_rel#*/}"
    design="${logs_rel%%/*}"

    # Parse metrics from 6_report.json using grep+sed (no jq dependency)
    get_metric() {
        grep -o "\"$1\":[^,}]*" "$json" 2>/dev/null | head -1 | sed 's/.*://' | tr -d ' "'
    }

    die_area=$(get_metric "finish__design__die__area")
    core_area=$(get_metric "finish__design__core__area")
    inst_area=$(get_metric "finish__design__instance__area__stdcell")
    util=$(get_metric "finish__design__instance__utilization")
    wns=$(get_metric "finish__timing__setup__ws")
    tns=$(get_metric "finish__timing__setup__tns")
    cells=$(get_metric "finish__design__instance__count__stdcell")
    macros=$(get_metric "finish__design__instance__count__macros")
    ios=$(get_metric "finish__design__io")
    fmax=$(get_metric "finish__timing__fmax")
    power=$(get_metric "finish__power__total")
    errors=$(get_metric "finish__flow__errors__count")

    # Format utilization as percentage
    if [ -n "$util" ]; then
        util=$(awk "BEGIN {printf \"%.1f\", $util * 100}")
    fi

    # Format areas to 1 decimal
    if [ -n "$die_area" ]; then
        die_area=$(awk "BEGIN {printf \"%.1f\", $die_area}")
    fi
    if [ -n "$core_area" ]; then
        core_area=$(awk "BEGIN {printf \"%.1f\", $core_area}")
    fi
    if [ -n "$inst_area" ]; then
        inst_area=$(awk "BEGIN {printf \"%.1f\", $inst_area}")
    fi

    # Format timing to 2 decimals
    if [ -n "$wns" ]; then
        wns=$(awk "BEGIN {printf \"%.2f\", $wns}")
    fi
    if [ -n "$tns" ]; then
        tns=$(awk "BEGIN {printf \"%.2f\", $tns}")
    fi

    # Format fmax to GHz with 2 decimals
    if [ -n "$fmax" ]; then
        fmax=$(awk "BEGIN {printf \"%.2f\", $fmax / 1e9}")
    fi

    # Format power to mW with 3 decimals
    if [ -n "$power" ]; then
        power=$(awk "BEGIN {printf \"%.3f\", $power * 1000}")
    fi

    printf "%-12s %-25s %10s %10s %10s %8s %8s %6s %5s %10s %10s %12s %12s %6s\n" \
        "${platform:-?}" "${design:-?}" \
        "${die_area:--}" "${core_area:--}" "${inst_area:--}" "${util:--}" \
        "${cells:--}" "${macros:--}" "${ios:--}" \
        "${wns:--}" "${tns:--}" "${fmax:--}" "${power:--}" "${errors:--}"
done

# Show designs that failed (have synth but no final report)
echo ""
echo "Incomplete builds:"
find "$BIN_DIR/designs" -path "*/results/*/1_synth.odb" -not -path "*.runfiles*" 2>/dev/null | sort -u | while read -r synth; do
    dir=$(dirname "$synth")
    if [ ! -f "${dir}/6_final.gds" ] && [ ! -f "${dir}/6_final.odb" ]; then
        rel="${synth#$BIN_DIR/designs/}"
        platform="${rel%%/*}"
        rel="${rel#*/}"
        design="${rel%%/*}"
        # Find which stage completed last
        last_stage=$(ls "$dir"/*.odb 2>/dev/null | sort | tail -1 | grep -oP '\d+_\w+' | head -1)
        echo "  ${platform}/${design} — stopped at ${last_stage:-synth}"
    fi
done
