#!/usr/bin/env bash
set -euo pipefail

DEV_DIR="$(dirname $(readlink -f $0))"
cd "$DEV_DIR"

cd ..
VORTEX_DIR="$DEV_DIR/repo"
OUT_FILE="vortex.v"
HW="${VORTEX_DIR}/hw/rtl"

cp -r "$HW" "$(pwd)"
cp "${VORTEX_DIR}/hw/dpi/float_dpi.vh" "${VORTEX_DIR}/hw/dpi/util_dpi.vh" "$(pwd)/rtl/"
cp "$DEV_DIR/VX_dp_ram_REPLACE.sv" "$(pwd)/rtl/libs/VX_dp_ram.sv"
cp "$DEV_DIR/VX_sp_ram_REPLACE.sv" "$(pwd)/rtl/libs/VX_sp_ram.sv"
