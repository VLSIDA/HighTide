# OpenROAD reference setup repair on a frozen placement (resize study, measurement B).
# Pre-CTS: repair_design, then repair_timing -setup only (default margins), then
# detailed placement. No hold repair, no logic resynthesis.
#   INPUT_ODB    3_place.odb
#   LIB_FILES    space-separated Liberty files (reference info.json lib_files)
#   SDC_FILE     3_place.sdc
#   SET_RC_TCL   platform setRC.tcl
#   DONT_USE     space-separated dont_use patterns
#   OUT          output directory (repaired.odb, repaired.def, runtime.json, edits.json)
foreach lib $::env(LIB_FILES) {read_liberty $lib}
read_db $::env(INPUT_ODB)
set_cmd_units -time ps -capacitance fF -resistance kOhm -power mW -distance um
read_sdc $::env(SDC_FILE)
source $::env(SET_RC_TCL)
set_dont_use $::env(DONT_USE)
estimate_parasitics -placement
set out $::env(OUT)
file mkdir $out
set block [ord::get_db_block]

proc snapshot {block} {
  set m [dict create]
  foreach inst [$block getInsts] {
    dict set m [$inst getName] [[$inst getMaster] getName]
  }
  return $m
}
proc metrics {} {
  return [list [sta::worst_slack -max] [sta::total_negative_slack -max] [sta::worst_slack -min]]
}
set before [snapshot $block]
set m0 [metrics]
set t [clock milliseconds]
repair_design
set design_ms [expr {[clock milliseconds]-$t}]
set m1 [metrics]
set after_design [snapshot $block]
set t [clock milliseconds]
repair_timing -setup
set timing_ms [expr {[clock milliseconds]-$t}]
set m2 [metrics]
set after_timing [snapshot $block]
set t [clock milliseconds]
set_placement_padding -global -left 0 -right 0
detailed_placement
check_placement -verbose
set dp_ms [expr {[clock milliseconds]-$t}]
estimate_parasitics -placement
set m3 [metrics]
write_db $out/repaired.odb
write_def $out/repaired.def

proc diff_counts {a b} {
  set added 0; set removed 0; set resized 0; set buf_added 0
  dict for {name master} $b {
    if {![dict exists $a $name]} {
      incr added
      if {[string match -nocase "BUF*" $master] || [string match -nocase "HB*" $master]} {incr buf_added}
    } elseif {[dict get $a $name] ne $master} {incr resized}
  }
  dict for {name master} $a {if {![dict exists $b $name]} {incr removed}}
  return [format {{"added":%d,"added_buffers":%d,"removed":%d,"resized":%d}} $added $buf_added $removed $resized]
}
set f [open $out/runtime.json w]
puts $f [format {{"repair_design_s":%.3f,"repair_timing_s":%.3f,"detailed_placement_s":%.3f,"instances_before":%d,"instances_after":%d,"repair_design_edits":%s,"repair_timing_edits":%s,"total_edits":%s,"wns_tns_hold":{"input":[%s],"after_repair_design":[%s],"after_repair_timing":[%s],"after_detailed_placement":[%s]}}} \
  [expr {$design_ms/1000.0}] [expr {$timing_ms/1000.0}] [expr {$dp_ms/1000.0}] [dict size $before] [dict size $after_timing] \
  [diff_counts $before $after_design] [diff_counts $after_design $after_timing] [diff_counts $before $after_timing] \
  [join $m0 ,] [join $m1 ,] [join $m2 ,] [join $m3 ,]]
close $f
