set begin [clock milliseconds]
source $::env(SCRIPTS_DIR)/load.tcl
source_env_var_if_exists PLATFORM_TCL
source $::env(SCRIPTS_DIR)/read_liberty.tcl

if {[file extension $::env(SCORE_INPUT)] eq ".odb"} {
  read_db $::env(SCORE_INPUT)
} else {
  read_lef $::env(TECH_LEF)
  read_lef $::env(SC_LEF)
  foreach lef $::env(ADDITIONAL_LEFS) {read_lef $lef}
  read_def $::env(SCORE_INPUT)
}
set_cmd_units -time ps -capacitance fF -resistance kOhm -power mW -distance um
read_sdc $::env(SDC_FILE)
source $::env(SET_RC_TCL)
set block [ord::get_db_block]
if {[info exists ::env(SCORE_COORDS)]} {
  set f [open $::env(SCORE_COORDS)]
  while {[gets $f line] >= 0} {
    lassign [split $line "\t"] name x y orientation
    set inst [$block findInst $name]
    if {$inst eq "NULL" || $inst eq ""} {error "Missing snapshot instance $name"}
    set status [$inst getPlacementStatus]
    $inst setPlacementStatus PLACED
    $inst setOrient $orientation
    $inst setLocation $x $y
    $inst setPlacementStatus $status
  }
  close $f
}
set stage $::env(SCORE_STAGE)
if {$stage eq "route"} {
  set_propagated_clock [all_clocks]
  read_spef $::env(SCORE_SPEF)
} elseif {$stage ne "synth"} {
  if {$stage in {cts grt detail}} {set_propagated_clock [all_clocks]}
  estimate_parasitics -placement
}
if {$stage ni {gp synth}} {check_placement -verbose}
set hpwl 0.0;set measured 0
set units [$block getDbUnitsPerMicron]
foreach net [$block getNets] {
  if {[$net getSigType] in {POWER GROUND}} {continue}
  set xs {};set ys {}
  foreach term [$net getITerms] {
    lassign [$term getAvgXY] ok x y
    if {$ok} {lappend xs $x;lappend ys $y}
  }
  foreach term [$net getBTerms] {
    lassign [$term getFirstPinLocation] ok x y
    if {$ok} {lappend xs $x;lappend ys $y}
  }
  if {[llength $xs]<2} {continue}
  set hpwl [expr {$hpwl+double([tcl::mathfunc::max {*}$xs]-[tcl::mathfunc::min {*}$xs]+[tcl::mathfunc::max {*}$ys]-[tcl::mathfunc::min {*}$ys])/$units}]
  incr measured
}
set area 0.0;set macros 0;set logical 0;set physical 0
set boxes [open $::env(SCORE_OUT)/boxes.tsv w]
foreach inst [$block getInsts] {
  set master [$inst getMaster]
  set phys [expr {[$master isFiller] || [$master isEndCap] || [$master getType] eq "CORE_WELLTAP"}]
  if {$phys} {incr physical} else {incr logical;set area [expr {$area+double([$master getWidth])*[$master getHeight]/($units*$units)}]}
  incr macros [$master isBlock]
  lassign [$inst getLocation] x y
  puts $boxes [join [list [$inst getName] [$master getName] $x $y [$master getWidth] [$master getHeight] [$master isBlock] $phys [$inst getOrient] [$inst getPlacementStatus]] "\t"]
}
close $boxes
set out $::env(SCORE_OUT)
report_units
report_clock_properties [all_clocks]
check_setup -verbose > $out/coverage.rpt
report_checks -path_delay max -group_path_count 10 -fields {slew cap input net fanout} -digits 6 -format full_clock_expanded > $out/setup_paths.rpt
report_checks -path_delay min -group_path_count 3 -fields {slew cap input net fanout} -digits 6 -format full_clock_expanded > $out/hold_paths.rpt
report_power -digits 6 > $out/power.rpt
set rect [$block getDieArea];set core [$block getCoreArea]
set f [open $out/score.json w]
puts $f [format { {"hpwl_um":%.9f,"measured_nets":%d,"setup_wns_ps":%.9f,"setup_tns_ps":%.9f,"hold_wns_ps":%.9f,"hold_tns_ps":%.9f,"instances":%d,"logical_cells":%d,"physical_cells":%d,"macros":%d,"instance_area_um2":%.9f,"die_um":[%.6f,%.6f,%.6f,%.6f],"core_um":[%.6f,%.6f,%.6f,%.6f],"scoring_seconds":%.6f} } \
 $hpwl $measured [sta::worst_slack -max] [sta::total_negative_slack -max] [sta::worst_slack -min] [sta::total_negative_slack -min] \
 [llength [$block getInsts]] $logical $physical $macros $area \
 [expr {double([$rect xMin])/$units}] [expr {double([$rect yMin])/$units}] [expr {double([$rect xMax])/$units}] [expr {double([$rect yMax])/$units}] \
 [expr {double([$core xMin])/$units}] [expr {double([$core yMin])/$units}] [expr {double([$core xMax])/$units}] [expr {double([$core yMax])/$units}] [expr {([clock milliseconds]-$begin)/1000.0}]]
close $f
if {$stage ne "synth"} {write_def $out/layout.def}
write_sdc -no_timestamp $out/normalized.sdc

source $::env(OUTPUT)/audit.tcl
