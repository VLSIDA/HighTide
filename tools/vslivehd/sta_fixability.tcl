# Fixability bound for failing setup endpoints (resize study, measurement C).
#
# MODE=rc     placement RC (estimate_parasitics -placement), as the common scorer.
# MODE=ideal  no parasitics: ideal (zero-RC) wires, real pin capacitances.
#
# For every endpoint: worst setup slack (E lines). For the selected endpoints
# (the TOPN worst in rc mode, or the names in SELECT_FILE): iteratively set every
# cell on the endpoint's current worst path to its strongest same-function drive
# (STRONG_MAP tsv: master<TAB>strongest), re-time (re-estimating RC in rc mode),
# up to ROUNDS times; report the slack after each round (S lines) and revert.
# LIST_PATHS=M prints the instances on the worst path of the M worst failing
# endpoints (I lines) for cell attribution.
#
# Inputs: INPUT (.odb or .def), TECH_LEF SC_LEF ADDITIONAL_LEFS (def only), LIB_FILES,
# SDC_FILE, SET_RC_TCL, OUT (tsv output). Times are in ps.
foreach lib $::env(LIB_FILES) {read_liberty $lib}
set input $::env(INPUT)
if {[file extension $input] eq ".odb"} {
  read_db $input
} else {
  read_lef $::env(TECH_LEF)
  read_lef $::env(SC_LEF)
  if {[info exists ::env(ADDITIONAL_LEFS)]} {foreach lef $::env(ADDITIONAL_LEFS) {read_lef $lef}}
  read_def $input
}
set_cmd_units -time ps -capacitance fF -resistance kOhm -power mW -distance um
read_sdc $::env(SDC_FILE)
set mode $::env(MODE)
proc reestimate {} {
  global mode
  if {$mode eq "rc"} {estimate_parasitics -placement}
}
if {$mode eq "rc"} {
  source $::env(SET_RC_TCL)
  estimate_parasitics -placement
}
set out [open $::env(OUT) w]
set strong [dict create]
set f [open $::env(STRONG_MAP)]
while {[gets $f line] >= 0} {
  lassign [split $line "\t"] a b
  dict set strong $a $b
}
close $f
set topn [expr {[info exists ::env(TOPN)] ? $::env(TOPN) : 20}]
set rounds [expr {[info exists ::env(ROUNDS)] ? $::env(ROUNDS) : 3}]
set list_paths [expr {[info exists ::env(LIST_PATHS)] ? $::env(LIST_PATHS) : 0}]

set t0 [clock milliseconds]
set all [find_timing_paths -path_delay max -group_path_count 10000000 -endpoint_path_count 1 -sort_by_slack]
set pins [dict create]
set failing {}
foreach p $all {
  set ep [get_property $p endpoint]
  set name [get_full_name $ep]
  set s [get_property $p slack]
  if {[dict exists $pins $name]} {continue}
  dict set pins $name $ep
  puts $out "E\t$name\t$s"
  if {$s < 0} {lappend failing [list $name $s $p]}
}
puts $out "T\tendpoint_search_ms\t[expr {[clock milliseconds]-$t0}]"

proc path_cells {p} {
  set cells {}
  foreach pt [get_property $p points] {
    set pin [get_property $pt pin]
    set c [get_cells -quiet -of_objects $pin]
    if {$c ne "" && [lsearch -exact $cells $c] < 0} {lappend cells $c}
  }
  return $cells
}
proc worst_path {ep} {
  return [lindex [find_timing_paths -path_delay max -to $ep -group_path_count 1 -endpoint_path_count 1] 0]
}

set i 0
foreach item $failing {
  if {$i >= $list_paths} {break}
  lassign $item name s p
  if {[catch {
    set desc {}
    foreach c [path_cells $p] {lappend desc "[get_full_name $c]:[get_property $c ref_name]"}
    puts $out "I\t$name\t$s\t[join $desc { }]"
  } err]} {
    puts $out "X\t$name\t$err"
  }
  incr i
}

if {[info exists ::env(SELECT_FILE)]} {
  set selected {}
  set f [open $::env(SELECT_FILE)]
  while {[gets $f line] >= 0} {if {$line ne ""} {lappend selected $line}}
  close $f
} else {
  set selected {}
  foreach item [lrange $failing 0 [expr {$topn-1}]] {lappend selected [lindex $item 0]}
}
foreach name $selected {
  if {![dict exists $pins $name]} {puts $out "S\t$name\tmissing"; continue}
  set ep [dict get $pins $name]
  set p [worst_path $ep]
  set base [get_property $p slack]
  set desc {}
  foreach c [path_cells $p] {lappend desc "[get_full_name $c]:[get_property $c ref_name]"}
  puts $out "P\t$name\t$base\t[get_full_name [get_property $p startpoint]]\t[join $desc { }]"
  set changed {}
  set results {}
  for {set r 0} {$r < $rounds} {incr r} {
    set n 0
    foreach c [path_cells $p] {
      set ref [get_property $c ref_name]
      if {[dict exists $strong $ref] && [dict get $strong $ref] ne $ref} {
        lappend changed [list $c $ref]
        replace_cell $c [dict get $strong $ref]
        incr n
      }
    }
    if {$n == 0} {break}
    reestimate
    set p [worst_path $ep]
    lappend results [get_property $p slack]
  }
  puts $out "S\t$name\t$base\t[join $results ,]\t[llength $changed]"
  foreach ch [lreverse $changed] {lassign $ch c ref; replace_cell $c $ref}
  if {[llength $changed]} {reestimate}
  flush $out
}
puts $out "T\ttotal_ms\t[expr {[clock milliseconds]-$t0}]"
close $out
