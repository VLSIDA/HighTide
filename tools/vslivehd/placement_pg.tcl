# Explicit opt-in for placement experiments; never sourced by default flows.
#
# source tools/vslivehd/placement_pg.tcl
# vslivehd::placement_pg::suspend AUDIT_DIRECTORY
# ... standard-cell placement, with the original netlist/constraints/frame ...
# vslivehd::placement_pg::restore
#
# Suspend before the first estimate_parasitics/STA optimization operation.
# Only declared POWER/GROUND ITerm associations are disconnected. PG nets,
# BTerms, special wires, via geometry, rows, tracks and cells are retained.
# Restore verifies original PG associations and special-wire geometry, applies
# global_connect for new cells, and rejects any missing/wrong-type PG ITerm.
# Callers must also audit their own functional netlist, fixed macro frame and
# constraints around the placement operation. A failed audit requires discarding
# the edited database; the helper does not relax timing or routing constraints.
namespace eval vslivehd::placement_pg {
  variable state {}
}

# Stream C++ DEF output instead of materializing millions of SBoxes in Tcl.
namespace eval vslivehd::placement_pg {
  variable geometry_tool [file join [file dirname [info script]] placement_pg_geometry.py]
}
proc vslivehd::placement_pg::special_snapshot {directory label} {
  variable geometry_tool
  set temporary $directory/.pg_geometry_$label.def
  write_def $temporary
  set digest [exec python3 $geometry_tool $temporary $directory/pg_special_geometry_$label.def.gz $directory/pg_special_geometry_$label.json]
  file delete $temporary
  return $digest
}

proc vslivehd::placement_pg::suspend {audit_directory} {
  variable state
  if {$state ne {}} {error "PG suspension already active"}
  if {[est::have_estimated_parasitics]} {error "Suspend PG before first parasitic estimation/STA optimization"}
  file mkdir $audit_directory
  set geometry [special_snapshot $audit_directory before]
  set nets [dict create];set pairs [dict create];set unconnected 0
  set ports {}
  foreach port [[ord::get_db_block] getBTerms] {
    if {[$port getSigType] ni {POWER GROUND}} {continue}
    set net [$port getNet];set net_name {};if {$net ne "NULL"} {set net_name [$net getName]}
    lappend ports [list [$port getName] [$port getIoType] [$port getSigType] $net_name]
    foreach pin [$port getBPins] {
      foreach box [$pin getBoxes] {lappend ports [list [$port getName] [$pin getPlacementStatus] [[$box getTechLayer] getName] [$box xMin] [$box yMin] [$box xMax] [$box yMax]]}
    }
  }
  set f [open $audit_directory/pg_associations_before.tsv w]
  foreach term [[ord::get_db_block] getITerms] {
    set sig [[$term getMTerm] getSigType]
    if {$sig ni {POWER GROUND}} {continue}
    set net [$term getNet]
    if {$net eq "NULL"} {incr unconnected;continue}
    if {[$net getSigType] ne $sig} {close $f;error "PG terminal attached to wrong supply type"}
    set inst [$term getInst]
    dict set pairs [list [$inst getName] [[$inst getMaster] getName] [[$term getMTerm] getName]] [$net getName]
    dict set nets [$net getName] $net
    puts $f [list [$inst getName] [[$inst getMaster] getName] [[$term getMTerm] getName] [$net getName]]
  }
  close $f
  set state [dict create pairs $pairs nets $nets geometry $geometry audit_directory $audit_directory original_unconnected $unconnected ports [lsort $ports]]
  dict for {key net_name} $pairs {
    lassign $key instance_name master_name term_name
    [[[ord::get_db_block] findInst $instance_name] findITerm $term_name] disconnect
  }
  puts "PLACEMENT_PG_SUSPEND associations=[dict size $pairs] original_unconnected=$unconnected PG_nets_and_special_wires_retained=1"
  return [dict size $pairs]
}

proc vslivehd::placement_pg::restore {} {
  variable state
  if {$state eq {}} {error "No active PG suspension"}
  set block [ord::get_db_block]
  dict for {name net} [dict get $state nets] {
    if {[$block findNet $name] ne $net} {error "Placement replaced original PG net $name"}
  }
  # Restore exact original associations, including protected instances that
  # ordinary global_connect deliberately skips. Only declared PG pins are used.
  dict for {key net_name} [dict get $state pairs] {
    lassign $key instance_name master_name term_name
    set inst [$block findInst $instance_name]
    if {$inst eq "NULL" || [[$inst getMaster] getName] ne $master_name} {error "Placement changed original instance/master $instance_name"}
    set term [$inst findITerm $term_name];set net [$block findNet $net_name]
    if {$term eq "NULL" || $net eq "NULL"} {error "Original PG terminal/net is missing"}
    set current [$term getNet]
    if {$current eq "NULL"} {$term connect $net} elseif {$current ne $net} {error "Placement reassigned an original PG terminal"}
  }
  global_connect
  dict for {key net_name} [dict get $state pairs] {
    lassign $key instance_name master_name term_name
    set term [[$block findInst $instance_name] findITerm $term_name]
    if {[$term getNet] ne [$block findNet $net_name]} {error "Original PG association was not restored"}
  }
  set ports {}
  foreach port [$block getBTerms] {
    if {[$port getSigType] ni {POWER GROUND}} {continue}
    set net [$port getNet];set net_name {};if {$net ne "NULL"} {set net_name [$net getName]}
    lappend ports [list [$port getName] [$port getIoType] [$port getSigType] $net_name]
    foreach pin [$port getBPins] {
      foreach box [$pin getBoxes] {lappend ports [list [$port getName] [$pin getPlacementStatus] [[$box getTechLayer] getName] [$box xMin] [$box yMin] [$box xMax] [$box yMax]]}
    }
  }
  if {[lsort $ports] ne [dict get $state ports]} {error "PG port geometry or connectivity changed"}
  set count 0;set missing 0;set wrong 0
  foreach term [$block getITerms] {
    set sig [[$term getMTerm] getSigType]
    if {$sig ni {POWER GROUND}} {continue}
    incr count;set net [$term getNet]
    if {$net eq "NULL"} {incr missing} elseif {[$net getSigType] ne $sig} {incr wrong}
  }
  set directory [dict get $state audit_directory]
  set geometry [special_snapshot $directory restored]
  if {$geometry ne [dict get $state geometry]} {error "Placement/PG restoration changed PG special-wire geometry or PG ports"}
  set f [open $directory/restore_summary.json w]
  puts $f "\{\"original_connected_pg_iterms\":[dict size [dict get $state pairs]],\"original_unconnected_pg_iterms\":[dict get $state original_unconnected],\"final_pg_iterms\":$count,\"missing_pg_iterms\":$missing,\"wrong_supply_type_pg_iterms\":$wrong,\"original_pg_associations_restored\":true,\"pg_net_identity_and_special_geometry_preserved\":true\}"
  close $f
  if {$missing || $wrong} {error "Restored placement has $missing missing and $wrong wrong-type PG terminals"}
  puts "PLACEMENT_PG_RESTORE PG_iterms=$count missing=$missing wrong_type=$wrong geometry_unchanged=1"
  set state {}
}
