# Post-route comparison: after ORFS tapcell + PDN on a LiveHD placement,
# record each standard cell's LiveHD location (positions.tsv) and hand the
# design to ORFS detailed placement as 3_4_place_resized.odb (ORFS's own
# 3_5_place_dp then legalizes around taps/PDN exactly as for the reference).
#   ./make run RUN_SCRIPT=<this> RUN_LOG_NAME_STEM=lhd_prelegal LHD_POS=<positions.tsv>
source $::env(SCRIPTS_DIR)/load.tcl
load_design 2_floorplan.odb 2_floorplan.sdc
set block [ord::get_db_block]
set f [open $::env(LHD_POS) w]
foreach inst [$block getInsts] {
  set m [$inst getMaster]
  if {[$m isBlock] || [$m isEndCap] || [$m getType] eq "CORE_WELLTAP"} {continue}
  lassign [$inst getLocation] x y
  puts $f "[$inst getName]\t$x\t$y"
}
close $f
write_db $::env(RESULTS_DIR)/3_4_place_resized.odb
