# Post-route comparison: turn a LiveHD placement DEF into the ORFS floorplan
# checkpoint 2_2_floorplan_macro.odb, so the ORFS tapcell, PDN, detailed
# placement, CTS and routing stages run on it with the reference's variables.
#
# Run through the deployed ORFS environment (full ORFS env):
#   ./make run RUN_SCRIPT=<this> RUN_LOG_NAME_STEM=lhd_import \
#     LHD_DEF=<out.def> LHD_SDC=<sdc>
#
# Keeps LiveHD's netlist, cell and macro locations and IO pins. Macros become
# FIRM (tapcell/PDN treat them as fixed); standard cells stay PLACED so the
# later ORFS detailed placement may legalize them around taps and PDN.
source $::env(SCRIPTS_DIR)/util.tcl
source $::env(SCRIPTS_DIR)/read_liberty.tcl
read_lef $::env(TECH_LEF)
read_lef $::env(SC_LEF)
if {[env_var_exists_and_non_empty ADDITIONAL_LEFS]} {
  foreach lef $::env(ADDITIONAL_LEFS) {read_lef $lef}
}
read_def $::env(LHD_DEF)
set block [ord::get_db_block]
set macros 0;set cells 0;set unplaced 0
foreach inst [$block getInsts] {
  if {[[$inst getMaster] isBlock]} {
    $inst setPlacementStatus FIRM
    incr macros
  } else {
    if {[$inst getPlacementStatus] eq "NONE" || [$inst getPlacementStatus] eq "UNPLACED"} {incr unplaced}
    incr cells
  }
}
puts "lhd_import: macros=$macros cells=$cells unplaced=$unplaced"
# What ORFS floorplan.tcl stores in the database besides the floorplan itself:
# the global-route layer range and per-layer capacity adjustment (FASTROUTE_TCL),
# and the dont-use list. Without these GRT/DRT route up to the top metal with no
# capacity derate (the reference is capped at MAX_ROUTING_LAYER with 25% adjust).
# LiveHD's track grids already match ORFS make_tracks (same origin/pitch).
if {[env_var_exists_and_non_empty FASTROUTE_TCL]} {
  source $::env(FASTROUTE_TCL)
} else {
  set_global_routing_layer_adjustment $::env(MIN_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER) $::env(ROUTING_LAYER_ADJUSTMENT)
  set_routing_layers -signal $::env(MIN_ROUTING_LAYER)-$::env(MAX_ROUTING_LAYER)
}
set_dont_use $::env(DONT_USE_CELLS)
read_sdc $::env(LHD_SDC)
write_db $::env(RESULTS_DIR)/2_2_floorplan_macro.odb
write_sdc -no_timestamp $::env(RESULTS_DIR)/2_1_floorplan.sdc
