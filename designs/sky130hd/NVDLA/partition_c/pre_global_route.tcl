# Runs inside the grt stage just before global_route (PRE_GLOBAL_ROUTE_TCL,
# grt-scoped — cached pre-GRT stages survive, unlike FASTROUTE_TCL which is
# unscoped and would rebuild from synth).
#
# 2026-11 pin (OpenROAD 687848dd): GRT fails GRT-0116 with 87 gcells each
# exactly 1 track over capacity (capacity:20 usage:21) in the cbuf/cdma
# macro escape regions, and prints
#   [WARNING GRT-0704] Try reduce the layer adjustment from 20% to 11%
# The same config closed clean on the 2026-07 pin (b65c274c), so the
# platform fastroute.tcl's 20% reserve is now too conservative for this
# design's macro channels. 0.10 sits just under GRT's own 11% fit
# estimate; detailed route keeps the full physical capacity either way.
set_global_routing_layer_adjustment $::env(MIN_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER) 0.10
