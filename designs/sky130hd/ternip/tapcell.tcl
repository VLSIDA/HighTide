# Platform tapcell.tcl plus a 30 um macro halo: tapcell cuts the standard-cell
# rows 30 um back from each fakeram so no cells (taps included) land against
# the macro pins. sky130 fakeram pins sit on all four edges (see macros.tcl).
tapcell \
  -distance 14 \
  -tapcell_master "$::env(TAP_CELL_NAME)" \
  -halo_width_x 30 \
  -halo_width_y 30
