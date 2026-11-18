# Post-route comparison: displacement of the legalized 3_place.odb against the
# LiveHD positions recorded by postroute_prelegal.tcl. Writes JSON to LHD_DISP.
source $::env(SCRIPTS_DIR)/load.tcl
load_design 3_place.odb 3_place.sdc
set block [ord::get_db_block]
set dbu [$block getDbUnitsPerMicron]
set pos [dict create]
set f [open $::env(LHD_POS) r]
while {[gets $f line] >= 0} {
  lassign [split $line "\t"] n x y
  dict set pos $n [list $x $y]
}
close $f
set n 0;set moved 0;set sum 0.0;set mx 0.0;set over1 0;set over5 0
foreach inst [$block getInsts] {
  set name [$inst getName]
  if {![dict exists $pos $name]} {continue}
  lassign [dict get $pos $name] x0 y0
  lassign [$inst getLocation] x y
  set d [expr {double(abs($x-$x0)+abs($y-$y0))/$dbu}]
  incr n
  if {$d > 0} {incr moved}
  if {$d > 1.0} {incr over1}
  if {$d > 5.0} {incr over5}
  set sum [expr {$sum+$d}]
  if {$d > $mx} {set mx $d}
}
set placement_check [expr {[catch {check_placement -verbose}] ? "failed" : "pass"}]
set o [open $::env(LHD_DISP) w]
puts $o [format {{"cells": %d, "moved": %d, "mean_um": %.4f, "max_um": %.3f, "over_1um": %d, "over_5um": %d, "placement_check": "%s"}} \
  $n $moved [expr {$n ? $sum/$n : 0}] $mx $over1 $over5 $placement_check]
close $o
