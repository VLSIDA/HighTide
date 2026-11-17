# Explicit opt-in pre-CTS handoff helpers for matched LiveHD/OpenROAD studies.
# Source after Liberty, LEF/DEF or ODB, authoritative SDC, and routing tracks.
# No procedure is invoked automatically; existing flow defaults are unchanged.
#
# API (all audit destinations are caller-owned):
#   vslivehd::snap_macro_pins audit.tsv max_shift_um
#   vslivehd::snap_io_pins audit.tsv horizontal_layer vertical_layer max_shift_um
# IO normalization retains interior normal coordinates and snaps preferred
# coordinates to actual tracks; minimum-area boxes are clamped inside the die.
#   vslivehd::protect_clock_roots audit.tsv
#   vslivehd::cleanup_clock_buffers audit_directory
#
# Snapshot the input before cleanup. Buffer removal is destructive to the loaded
# database and returns an error if any structural/clock audit fails; callers must
# not publish the edited database after an error. Macro and IO snapping restore
# their original geometry on error. Re-read saved output before downstream CTS.
namespace eval vslivehd {}

proc vslivehd::snap_macro_pins {audit_path max_shift_um} {
 if {$max_shift_um<0} {error "max_shift_um must be nonnegative"}
 set block [ord::get_db_block];set dbu [$block getDbUnitsPerMicron]
 set before [dict create]
 foreach i [$block getInsts] {
  if {[[$i getMaster] isBlock]} {dict set before [$i getName] [list $i [$i getLocation] [$i getOrient] [$i getPlacementStatus]]}
 }
 set f [open $audit_path w]
 puts $f "name\told_x_dbu\told_y_dbu\tnew_x_dbu\tnew_y_dbu\tdx_dbu\tdy_dbu\torientation"
 set status [catch {
  dict for {name state} $before {
   lassign $state i location orient oldstatus;lassign $location x y
   $i setPlacementStatus PLACED
   # Current OpenROAD overlap detection includes the target itself; independently
   # check every distinct macro pair below instead of accepting that self-match.
   place_macro -macro_name $name -location [list [expr {double($x)/$dbu}] [expr {double($y)/$dbu}]] -orientation $orient -allow_overlap
   $i setPlacementStatus $oldstatus
   lassign [$i getLocation] nx ny
   puts $f [join [list $name $x $y $nx $ny [expr {$nx-$x}] [expr {$ny-$y}] $orient] "\t"]
   if {abs($nx-$x)>$max_shift_um*$dbu || abs($ny-$y)>$max_shift_um*$dbu} {error "Macro $name track snap exceeds caller max_shift_um=$max_shift_um"}
   if {[$i getOrient] ne $orient} {error "Macro $name orientation changed during track snap"}
  }
  set names [dict keys $before];set core [$block getCoreArea]
  for {set a 0} {$a<[llength $names]} {incr a} {
   set i [lindex [dict get $before [lindex $names $a]] 0];set ib [$i getBBox]
   if {[$ib xMin]<[$core xMin] || [$ib xMax]>[$core xMax] || [$ib yMin]<[$core yMin] || [$ib yMax]>[$core yMax]} {error "Macro [$i getName] snapped outside core"}
   for {set b [expr {$a+1}]} {$b<[llength $names]} {incr b} {
    set j [lindex [dict get $before [lindex $names $b]] 0];set jb [$j getBBox]
    if {[$ib xMin]<[$jb xMax] && [$jb xMin]<[$ib xMax] && [$ib yMin]<[$jb yMax] && [$jb yMin]<[$ib yMax]} {error "Macro overlap after track snap: [$i getName] [$j getName]"}
   }
  }
 } reason options]
 close $f
 if {$status} {
  dict for {name state} $before {
   lassign $state i location orient oldstatus
   $i setPlacementStatus PLACED;$i setOrient $orient;$i setLocation {*}$location;$i setPlacementStatus $oldstatus
  }
  return -options $options $reason
 }
 return [dict size $before]
}
proc vslivehd::protect_clock_roots {audit_path} {
 set f [open $audit_path w]
 puts $f "clock\tsource\tkind\tmaster\tnet\tdrivers\tsinks"
 set protected {}
 foreach c [all_clocks] {
  foreach source [get_property $c sources] {
   set kind port;set master ""
   if {![get_property $source is_port]} {
    set kind pin
    foreach cell [get_cells -of_objects $source] {
     if {$cell eq "NULL"} {error "Constrained clock source has no instance"}
     set_dont_touch $cell;lappend protected [get_full_name $cell]
     set master [get_property $cell ref_name]
    }
   }
   set net [vslivehd::source_net $source];set drivers 0;set sinks 0
   foreach t [$net getITerms] {
    if {[$t getIoType] eq "OUTPUT"} {incr drivers}
    if {[$t getIoType] eq "INPUT"} {incr sinks}
   }
   foreach t [$net getBTerms] {
    if {[$t getIoType] eq "INPUT"} {incr drivers}
    if {[$t getIoType] eq "OUTPUT"} {incr sinks}
   }
   puts $f [join [list [get_full_name $c] [get_full_name $source] $kind $master [$net getName] $drivers $sinks] "\t"]
  }
 }
 close $f
 return [lsort -unique $protected]
}

proc vslivehd::clock_membership {} {
 # Generated clock periods are lazy immediately after read_sdc. Refresh only
 # generated-clock relationships before taking a source/period/sink snapshot.
 sta::update_generated_clks
 set result [dict create]
 foreach c [all_clocks] {
  set sources {};foreach pin [get_property $c sources] {lappend sources [get_full_name $pin]}
  set sinks {};foreach pin [all_registers -clock $c -clock_pins] {lappend sinks [get_full_name $pin]}
  dict set result [get_full_name $c] [list [get_property $c period] [get_property $c is_generated] [lsort $sources] [lsort $sinks]]
 }
 return $result
}
proc vslivehd::source_net {source} {
 if {[get_property $source is_port]} {
  set term [[ord::get_db_block] findBTerm [get_full_name $source]]
 } else {set term [sta::sta_to_db_pin $source]}
 if {$term eq "NULL"} {error "Clock source [get_full_name $source] is missing in OpenDB"}
 set net [$term getNet]
 if {$net eq "NULL"} {error "Clock source [get_full_name $source] is unconnected"}
 return $net
}
proc vslivehd::clock_inventory {sources} {
 set buffers [dict create];set leaves [dict create];set inversions [dict create]
 dict for {name source} $sources {
  set queue [list [list [vslivehd::source_net $source] 0]];set seen [dict create]
  for {set k 0} {$k<[llength $queue]} {incr k} {
   lassign [lindex $queue $k] net phase
   set key "[$net getName]|$phase"
   if {[dict exists $seen $key]} {continue};dict set seen $key 1
   foreach term [$net getITerms] {
    if {[$term getIoType] ne "INPUT"} {continue}
    set inst [$term getInst];set master [$inst getMaster];set cell [sta::find_liberty_cell [$master getName]]
    if {$cell eq "NULL"} {error "Missing Liberty model for [$master getName]"}
    if {[$cell is_buffer] || [$cell is_inverter]} {
     set nextphase $phase
     if {[$cell is_buffer]} {dict set buffers [$inst getName] [$master getName]} else {
      set nextphase [expr {!$phase}];dict set inversions [$inst getName] [$master getName]
     }
     set outcount 0
     foreach pin [$inst getITerms] {
      if {[$pin getIoType] eq "OUTPUT"} {
       incr outcount;set outnet [$pin getNet]
       if {$outnet eq "NULL"} {error "Unconnected clock BUF/INV output"}
       lappend queue [list $outnet $nextphase]
      }
     }
     if {$outcount!=1} {error "Clock BUF/INV is not single-output"}
    } else {
     # Boundaries include true sequential clocks, clock-gate inputs and any
     # data uses of clock values; preserve every reachable terminal and phase.
     dict set leaves "$name|[$inst getName]/[[$term getMTerm] getName]|$phase" [$master getName]
    }
   }
   foreach port [$net getBTerms] {
    if {[$port getIoType] eq "OUTPUT"} {dict set leaves "$name|PORT:[$port getName]|$phase" OUTPUT}
   }
  }
 }
 return [dict create buffers $buffers inverters $inversions leaves $leaves]
}
proc vslivehd::cleanup_clock_buffers {audit_dir} {
 file mkdir $audit_dir
 set block [ord::get_db_block];set sources [dict create];set protected [dict create]
 foreach c [all_clocks] {
  foreach source [get_property $c sources] {
   dict set sources [get_full_name $source] $source
   if {![get_property $source is_port]} {
    foreach inst [get_cells -of_objects $source] {if {$inst ne "NULL"} {dict set protected [get_full_name $inst] 1}}
   }
  }
 }
 # OpenSTA clock tags certify gated-clock boundaries beyond primary roots.
 # Keep every non-BUF/INV cell intact; only traverse its clock-tagged outputs.
 foreach inst [get_cells -hierarchical *] {
  if {[get_property $inst is_buffer] || [get_property $inst is_inverter]} {continue}
  foreach pin [get_pins -of_objects $inst] {
   if {[get_property $pin direction] eq "output" && [llength [get_property $pin clocks]]} {dict set sources [get_full_name $pin] $pin}
  }
 }
 set before_members [vslivehd::clock_membership]
 report_clock_properties [all_clocks] > $audit_dir/clock_properties_before.rpt
 set before [vslivehd::clock_inventory $sources];set selected [dict get $before buffers]
 foreach name [dict keys $protected] {if {[dict exists $selected $name]} {dict unset selected $name}}
 set all_before [dict create]
 foreach inst [$block getInsts] {dict set all_before [$inst getName] [list [[$inst getMaster] getName] [$inst getLocation] [$inst getOrient] [$inst getPlacementStatus]]}
 set selected_sta {}
 foreach cell [get_cells -hierarchical *] {if {[dict exists $selected [get_full_name $cell]]} {lappend selected_sta $cell}}
 if {[llength $selected_sta]!=[dict size $selected]} {error "Clock cleanup could not resolve exact selected instances"}
 set f [open $audit_dir/selected.tsv w]
 foreach name [lsort [dict keys $selected]] {puts $f "$name\t[dict get $selected $name]"};close $f
 set f [open $audit_dir/protected_sources.tsv w]
 foreach name [lsort [dict keys $protected]] {puts $f $name};close $f
 # Public remove_buffers uses this same operation; pointers avoid glob parsing
 # of synthesized names containing [], backslashes, or hierarchy separators.
 if {[llength $selected_sta]} {rsz::remove_buffers_cmd $selected_sta}
 # Invalidate all clock tags and generated-clock search state explicitly.
 sta::delays_invalid
 sta::arrivals_invalid
 set after_members [vslivehd::clock_membership]
 if {[lsort [dict keys $before_members]] ne [lsort [dict keys $after_members]]} {error "Clock cleanup lost clock definitions"}
 dict for {clock members} $before_members {if {$members ne [dict get $after_members $clock]} {error "Clock cleanup changed $clock membership, sources or period"}}
 report_clock_properties [all_clocks] > $audit_dir/clock_properties_after.rpt
 set f [open $audit_dir/clock_properties_before.rpt];set props [read $f];close $f
 set f [open $audit_dir/clock_properties_after.rpt];set afterprops [read $f];close $f
 if {$props ne $afterprops} {error "Clock cleanup changed declared waveforms"}
 set after [vslivehd::clock_inventory $sources]
 foreach field {leaves inverters} {
  set a [dict get $before $field];set b [dict get $after $field]
  if {[lsort [dict keys $a]] ne [lsort [dict keys $b]]} {error "Clock cleanup changed $field reachability or phase"}
  dict for {key value} $a {if {$value ne [dict get $b $key]} {error "Clock cleanup changed $field identity"}}
 }
 set all_after [dict create];set removed 0
 foreach inst [$block getInsts] {
  set name [$inst getName];dict set all_after $name 1
  set state [list [[$inst getMaster] getName] [$inst getLocation] [$inst getOrient] [$inst getPlacementStatus]]
  if {![dict exists $all_before $name] || [dict get $all_before $name] ne $state} {error "Clock cleanup modified surviving instance $name"}
 }
 foreach name [dict keys $all_before] {
  if {![dict exists $all_after $name]} {
   if {![dict exists $selected $name]} {error "Clock cleanup removed nonselected instance $name"}
   incr removed
  }
 }
 foreach name [dict keys $protected] {if {![dict exists $all_after $name]} {error "Clock cleanup deleted constrained source $name"}}
 set f [open $audit_dir/membership.tsv w]
 dict for {name data} $before_members {puts $f "$name\t$data"};close $f
 set f [open $audit_dir/audit.json w]
 puts $f [format {{"certified_clock_boundaries":%d,"declared_source_instances_protected":%d,"selected_identity_buffers":%d,"removed_buffers":%d,"preserved_inverters":%d,"clock_boundary_leaves":%d,"clocks":%d,"per_clock_membership_identical":true,"per_clock_sources_period_waveform_identical":true,"leaf_reachability_and_polarity_identical":true,"all_surviving_instance_geometry_identical":true,"only_selected_buffers_removed":true,"sta_clock_tags_forcibly_invalidated":true}} [dict size $sources] [dict size $protected] [dict size $selected] $removed [dict size [dict get $after inverters]] [dict size [dict get $after leaves]] [dict size $before_members]]
 close $f
 puts "CLOCK_BUFFER_CLEANUP_PASS selected[dict size $selected] removed$removed clocks[dict size $before_members]"
}

# Check final proposed rectangles, including stationary pins. Shapes on the same
# electrical net may coincide; different nets must not overlap or touch. This is
# short/contact prevention, not a complete technology spacing-DRC check.
proc vslivehd::check_io_pin_rectangles {rectangles} {
 set layers [dict create]
 foreach rectangle $rectangles {
  lassign $rectangle layer net name bbox
  lassign $bbox xl yl xh yh
  dict lappend layers $layer [list $xl $xh $yl $yh $net $name]
 }
 dict for {layer rectangles} $layers {
  set active {}
  foreach rectangle [lsort -integer -index 0 $rectangles] {
   lassign $rectangle xl xh yl yh net name
   set remaining {}
   foreach previous $active {
    lassign $previous pxl pxh pyl pyh pnet pname
    if {$pxh<$xl} {continue}
    lappend remaining $previous
    if {$name ne $pname && $net ne $pnet && $xl<=$pxh && $pxl<=$xh && $yl<=$pyh && $pyl<=$yh} {
     error "IO pin overlap/contact on $layer between distinct port nets: $pname and $name"
    }
   }
   lappend remaining $rectangle;set active $remaining
  }
 }
}

# Opt-in boundary pin legalization on the caller's horizontal/vertical IO layers.
# Validate every proposal before changing BPins. BTerm identities, connectivity,
# directions and placement statuses remain exact. Roll back staged BPin changes
# on errors; callers should still preserve the input checkpoint and failure log.
proc vslivehd::snap_io_pins {audit_path horizontal_layer vertical_layer max_shift_um} {
 if {$max_shift_um<0} {error "max_shift_um must be nonnegative"}
 set block [ord::get_db_block];set tech [[ord::get_db] getTech];set dbu [$block getDbUnitsPerMicron]
 set hlayer [$tech findLayer $horizontal_layer];set vlayer [$tech findLayer $vertical_layer]
 if {$hlayer eq "NULL" || [$hlayer getDirection] ne "HORIZONTAL" || $vlayer eq "NULL" || [$vlayer getDirection] ne "VERTICAL"} {error "IO layers must have matching horizontal/vertical preferred directions"}
 set die [$block getDieArea];set plans {};set rectangles {}
 set moved 0;set changed 0
 foreach bt [$block getBTerms] {
  set net [$bt getNet];set netkey $net
  if {$net eq "NULL"} {set netkey [list unconnected [$bt getName]]}
  if {[$bt getSigType] in {POWER GROUND}} {
   foreach bp [$bt getBPins] {
    foreach box [$bp getBoxes] {
     if {[$box isVia]} {error "IO collision audit requires rectangular PG BPin geometry"}
     lappend rectangles [list [[$box getTechLayer] getName] $netkey [$bt getName] [list [$box xMin] [$box yMin] [$box xMax] [$box yMax]]]
    }
   }
   continue
  }
  set pins [$bt getBPins]
  if {[llength $pins]!=1 || [llength [[lindex $pins 0] getBoxes]]!=1} {error "IO legalization requires one rectangular BPin for [$bt getName]"}
  set bp [lindex $pins 0];set box [lindex [$bp getBoxes] 0]
  if {[$box isVia]} {error "IO legalization refuses via-only port [$bt getName]"}
  set oldlayer [$box getTechLayer];set oldbox [list [$box xMin] [$box yMin] [$box xMax] [$box yMax]]
  set x [expr {([$box xMin]+[$box xMax])/2}];set y [expr {([$box yMin]+[$box yMax])/2}]
  set distances [list [list [expr {abs($x-[$die xMin])}] left] [list [expr {abs($x-[$die xMax])}] right] [list [expr {abs($y-[$die yMin])}] bottom] [list [expr {abs($y-[$die yMax])}] top]]
  set edge [lindex [lindex [lsort -integer -index 0 $distances] 0] 1]
  set horizontal [expr {$edge in {left right}}];set layer [expr {$horizontal ? $hlayer : $vlayer}]
  set grid [$block findTrackGrid $layer]
  if {$grid eq "NULL"} {error "No IO routing tracks on [$layer getName]"}
  set tracks [expr {$horizontal ? [$grid getGridY] : [$grid getGridX]}]
  set coord [expr {$horizontal ? $y : $x}]
  set direction [$bt getIoType];set sigtype [$bt getSigType];set status [$bp getPlacementStatus]
  set width [expr {[$box xMax]-[$box xMin]}];set height [expr {[$box yMax]-[$box yMin]}]
  set legal [expr {$oldlayer eq $layer && $coord in $tracks && $width>=[$layer getMinWidth] && $height>=[$layer getMinWidth] && double($width)*$height>=[$layer getArea] && [$box xMin]>=[$die xMin] && [$box xMax]<=[$die xMax] && [$box yMin]>=[$die yMin] && [$box yMax]<=[$die yMax]}]
  set newbox $oldbox
  if {!$legal} {
   # Retain the original normal coordinate: interior BTerms are legal.
   # Snap only the preferred coordinate and clamp minimum-area geometry inside
   # the die. Avoid moving ports to an expanded die edge unnecessarily.
   set w [$layer getMinWidth];set h $w
   if {$horizontal} {set w [expr {int(ceil(max(double($w),[$layer getArea]/$h)))}]} else {set h [expr {int(ceil(max(double($h),[$layer getArea]/$w)))}]}
   set mfg [$tech getManufacturingGrid]
   if {$mfg<=0} {error "IO normalization requires a positive manufacturing grid"}
   set w [expr {int(ceil(double($w)/(2*$mfg)))*2*$mfg}]
   set h [expr {int(ceil(double($h)/(2*$mfg)))*2*$mfg}]
   set low [expr {$horizontal ? [$die yMin]+$h/2 : [$die xMin]+$w/2}]
   set high [expr {$horizontal ? [$die yMax]-$h/2 : [$die xMax]-$w/2}]
   set best {};set bestdist Inf
   foreach track $tracks {
    if {$track<$low || $track>$high} {continue}
    set d [expr {abs($track-$coord)}]
    if {$d<$bestdist} {set bestdist $d;set best $track}
   }
   if {$best eq ""} {error "No legal preferred routing track for [$bt getName]"}
   set px [expr {$horizontal ? max([$die xMin]+$w/2,min($x,[$die xMax]-$w/2)) : $best}]
   set py [expr {$horizontal ? $best : max([$die yMin]+$h/2,min($y,[$die yMax]-$h/2))}]
   set newbox [list [expr {$px-$w/2}] [expr {$py-$h/2}] [expr {$px+$w/2}] [expr {$py+$h/2}]]
  }
  lassign $newbox xl yl xh yh
  set nx [expr {($xl+$xh)/2}];set ny [expr {($yl+$yh)/2}]
  set dx [expr {$nx-$x}];set dy [expr {$ny-$y}]
  if {abs($dx)>$max_shift_um*$dbu || abs($dy)>$max_shift_um*$dbu} {error "Port [$bt getName] movement exceeds max_shift_um=$max_shift_um"}
  set coord [expr {$horizontal ? $ny : $nx}]
  if {$coord ni $tracks} {error "Port [$bt getName] did not land on routing track"}
  if {$xl<[$die xMin] || $xh>[$die xMax] || $yl<[$die yMin] || $yh>[$die yMax]} {error "Port [$bt getName] shape left die"}
  if {$xh-$xl<[$layer getMinWidth] || $yh-$yl<[$layer getMinWidth] || double($xh-$xl)*($yh-$yl)<[$layer getArea]} {error "Port [$bt getName] proposed shape violates minimum width/area"}
  set didchange [expr {$oldbox ne $newbox || $oldlayer ne $layer}]
  incr changed $didchange;if {$dx!=0 || $dy!=0} {incr moved}
  lappend rectangles [list [$layer getName] $netkey [$bt getName] $newbox]
  lappend plans [list $bt $bp $oldlayer $oldbox $layer $newbox $status $net $direction $sigtype $edge $dx $dy $didchange]
 }
 vslivehd::check_io_pin_rectangles $rectangles
 # Create all proposed BPins before destroying any original BPin, so allocation,
 # geometry and audit-destination failures leave the original ports untouched.
 set created {};set removed {};set f {}
 try {
  set f [open $audit_path w]
  foreach plan $plans {
   lassign $plan bt bp oldlayer oldbox layer newbox status net direction sigtype edge dx dy didchange
   if {!$didchange} {continue}
   set fresh [odb::dbBPin_create $bt]
   lappend created [list $bt $fresh]
   $fresh setPlacementStatus $status
   set box [odb::dbBox_create $fresh $layer {*}$newbox]
   if {[list [$box xMin] [$box yMin] [$box xMax] [$box yMax]] ne $newbox} {error "IO rectangle creation changed the staged geometry"}
  }
  foreach plan $plans {
   lassign $plan bt bp oldlayer oldbox layer newbox status net direction sigtype edge dx dy didchange
   if {$didchange} {odb::dbBPin_destroy $bp;lappend removed $plan}
   if {[$bt getNet] ne $net || [$bt getIoType] ne $direction || [$bt getSigType] ne $sigtype} {error "IO legalization changed logical port identity"}
   set pins [$bt getBPins]
   if {[llength $pins]!=1 || [llength [[lindex $pins 0] getBoxes]]!=1} {error "IO legalization produced nonrectangular port"}
   set actual [lindex [[lindex $pins 0] getBoxes] 0]
   if {[$actual getTechLayer] ne $layer || [list [$actual xMin] [$actual yMin] [$actual xMax] [$actual yMax]] ne $newbox || [[lindex $pins 0] getPlacementStatus] ne $status} {error "IO legalization did not preserve the staged shape/status"}
  }
  puts $f "name\tedge\told_layer\told_bbox_dbu\tnew_layer\tnew_bbox_dbu\tdx_dbu\tdy_dbu\tchanged"
  foreach plan $plans {
   lassign $plan bt bp oldlayer oldbox layer newbox status net direction sigtype edge dx dy didchange
   puts $f [join [list [$bt getName] $edge [$oldlayer getName] $oldbox [$layer getName] $newbox $dx $dy $didchange] "\t"]
  }
  close $f;set f {}
 } on error {reason options} {
  if {$f ne {}} {catch {close $f}}
  foreach entry $created {lassign $entry bt fresh;odb::dbBPin_destroy $fresh}
  foreach plan $removed {
   lassign $plan bt bp oldlayer oldbox layer newbox status
   set restored [odb::dbBPin_create $bt];$restored setPlacementStatus $status
   odb::dbBox_create $restored $oldlayer {*}$oldbox
  }
  return -options $options $reason
 }
 puts "IO_PIN_SNAP_PASS changed$changed moved$moved"
 return $changed
}

# Opt-in single-power-domain association for protected generated-clock roots.
# global_connect deliberately skips dont_touch instances. Clear that flag only
# for declared non-port roots, associate validated PG ITerms, then restore it.
proc vslivehd::pg_signal_state {} {
 set rows {}
 foreach inst [[ord::get_db_block] getInsts] {
  lappend rows [list instance [$inst getName] [[$inst getMaster] getName] [$inst getLocation] [$inst getOrient] [$inst getPlacementStatus] [$inst isDoNotTouch]]
  foreach it [$inst getITerms] {
   if {[[$it getMTerm] getSigType] in {POWER GROUND}} {continue}
   set net [$it getNet];set name "NULL";if {$net ne "NULL"} {set name [$net getName]}
   lappend rows [list signal [$inst getName] [[$it getMTerm] getName] $name]
  }
 }
 foreach bt [[ord::get_db_block] getBTerms] {
  set net [$bt getNet];set name "NULL";if {$net ne "NULL"} {set name [$net getName]}
  lappend rows [list port [$bt getName] [$bt getIoType] [$bt getSigType] $name]
  foreach bp [$bt getBPins] {
   lappend rows [list port_status [$bt getName] [$bp getPlacementStatus]]
   foreach box [$bp getBoxes] {
    if {[$box isVia]} {error "PG association audit requires rectangular BPin geometry"}
    lappend rows [list port_shape [$bt getName] [[$box getTechLayer] getName] [$box xMin] [$box yMin] [$box xMax] [$box yMax]]
   }
  }
 }
 return [lsort $rows]
}
proc vslivehd::audit_single_domain_pg {path power ground allowed_null_roots} {
 set f [open $path w];puts $f "instance\tmaster\tpin\tsigtype\tnet"
 set total 0;set missing 0;set nonspecial 0
 try {
  foreach inst [[ord::get_db_block] getInsts] {
   foreach it [$inst getITerms] {
    set mt [$it getMTerm];set type [$mt getSigType]
    if {$type ni {POWER GROUND}} {continue}
    incr total;set net [$it getNet];set name "NULL"
    if {$net ne "NULL"} {set name [$net getName]}
    puts $f [join [list [$inst getName] [[$inst getMaster] getName] [$mt getName] $type $name] "\t"]
    set target [expr {$type eq "POWER" ? $power : $ground}]
    if {$net eq "NULL"} {
     incr missing
     if {![dict exists $allowed_null_roots [$inst getName]]} {error "Unconnected non-root PG ITerm [$inst getName]/[$mt getName]"}
    } elseif {$net ne $target} {error "Noncanonical PG net on [$inst getName]/[$mt getName]: $name"}
    if {![$it isSpecial]} {incr nonspecial;if {![dict exists $allowed_null_roots [$inst getName]]} {error "Non-special non-root PG ITerm [$inst getName]/[$mt getName]"}}
   }
  }
 } finally {close $f}
 return [list $total $missing $nonspecial]
}
proc vslivehd::associate_clock_root_pg {audit_dir power_net ground_net} {
 file mkdir $audit_dir
 set block [ord::get_db_block]
 set power [$block findNet $power_net];set ground [$block findNet $ground_net]
 if {$power eq "NULL" || $ground eq "NULL" || $power eq $ground} {error "PG association requires distinct existing power and ground nets"}
 if {[$power getSigType] ne "POWER" || [$ground getSigType] ne "GROUND"} {error "Canonical PG nets have incorrect signal types"}
 set members [vslivehd::clock_membership];set state [vslivehd::pg_signal_state]
 set roots [dict create];set actions {};set special_actions {};set root_rows {}
 foreach clock [all_clocks] {
  foreach source [get_property $clock sources] {
   if {[get_property $source is_port]} {continue}
   set it [sta::sta_to_db_pin $source]
   if {$it eq "NULL"} {error "Declared clock source has no OpenDB ITerm"}
   set inst [$it getInst];set name [$inst getName]
   if {[dict exists $roots $name]} {continue}
   dict set roots $name [list $inst [$inst isDoNotTouch]]
   set count 0
   foreach pin [$inst getITerms] {
    set mt [$pin getMTerm];set type [$mt getSigType]
    if {$type ni {POWER GROUND}} {continue}
    incr count;set pinname [$mt getName]
    if {($type eq "POWER" && $pinname ni {VDD VDDPE VDDCE}) || ($type eq "GROUND" && $pinname ni {VSS VSSE})} {error "Unrecognized canonical root PG pin $name/$pinname"}
    set target [expr {$type eq "POWER" ? $power : $ground}]
    set old [$pin getNet]
    if {$old ne "NULL" && $old ne $target} {error "Root PG pin already connected to another net: $name/$pinname"}
    if {$old eq "NULL"} {lappend actions [list $pin $target]}
    if {![$pin isSpecial]} {lappend special_actions $pin}
    lappend root_rows [list $name [[$inst getMaster] getName] $pinname $type [expr {$old eq "NULL" ? "NULL" : [$old getName]}] [$target getName] [$inst isDoNotTouch] [$pin isSpecial] 1]
   }
   if {!$count} {error "Clock source instance $name has no modeled PG ITerms"}
  }
 }
 lassign [vslivehd::audit_single_domain_pg $audit_dir/all_pg_before.tsv $power $ground $roots] total missing nonspecial
 set applied {};set marked {}
 try {
  dict for {name data} $roots {lassign $data inst flag;if {$flag} {$inst setDoNotTouch false}}
  try {
   foreach action $actions {lassign $action pin target;$pin connect $target;lappend applied $pin}
   foreach pin $special_actions {$pin setSpecial;lappend marked $pin}
  } finally {
   dict for {name data} $roots {lassign $data inst flag;$inst setDoNotTouch $flag}
  }
  if {[vslivehd::pg_signal_state] ne $state} {error "Root PG association changed signal connectivity, masters, geometry or protection"}
  if {[vslivehd::clock_membership] ne $members} {error "Root PG association changed declared clocks"}
  lassign [vslivehd::audit_single_domain_pg $audit_dir/all_pg_after.tsv $power $ground [dict create]] after_total after_missing after_nonspecial
  if {$after_total!=$total || $after_missing || $after_nonspecial} {error "Incomplete PG association"}
 } on error {reason options} {
  # Restore the original missing-root PG state on any failed postcondition.
  dict for {name data} $roots {lassign $data inst flag;if {$flag} {$inst setDoNotTouch false}}
  foreach pin $marked {$pin clearSpecial}
  foreach pin $applied {$pin disconnect}
  dict for {name data} $roots {lassign $data inst flag;$inst setDoNotTouch $flag}
  return -options $options $reason
 }
 set f [open $audit_dir/root_pg.tsv w]
 puts $f "instance\tmaster\tpin\tsigtype\tbefore_net\tafter_net\tdont_touch_restored\tspecial_before\tspecial_after"
 foreach row $root_rows {puts $f [join $row "\t"]};close $f
 set f [open $audit_dir/audit.json w]
 puts $f [format {{"declared_nonport_root_instances":%d,"new_pg_associations":%d,"all_instance_pg_iterms":%d,"missing_pg_before":%d,"missing_pg_after":0,"marked_special_pg_iterms":%d,"non_special_pg_before":%d,"non_special_pg_after":0,"canonical_single_power_domain":true,"signal_connectivity_master_geometry_protection_exact":true,"clock_membership_sources_periods_exact":true}} [dict size $roots] [llength $actions] $total $missing [llength $special_actions] $nonspecial]
 close $f
 puts "CLOCK_ROOT_PG_ASSOCIATION_PASS roots[dict size $roots] associated[llength $actions] totalPG$total missing0"
}

# Explicit opt-in CTS policy: keep declared logical clock roots in place.
# protect_clock_roots must run first; this intentionally changes only placement
# status to FIRM. The returned snapshot is reusable for checks after CTS/repair.
proc vslivehd::freeze_clock_roots {audit_path} {
 set snapshot [dict create]
 foreach clock [all_clocks] {
  foreach pin [get_property $clock sources] {
   if {[get_property $pin is_port]} {continue}
   set term [sta::sta_to_db_pin $pin]
   if {$term eq "NULL"} {error "Clock source [get_full_name $pin] has no physical ITerm"}
   set inst [$term getInst];set name [$inst getName]
   if {[dict exists $snapshot $name]} {continue}
   if {![$inst isPlaced] || ![$inst isDoNotTouch]} {error "Clock root $name must be placed and protected before freezing"}
   dict set snapshot $name [list [[$inst getMaster] getName] [$inst getLocation] [$inst getOrient] [$inst getPlacementStatus] [$inst isDoNotTouch]]
  }
 }
 # Validate every root before changing any placement status.
 dict for {name data} $snapshot {[[ord::get_db_block] findInst $name] setPlacementStatus FIRM}
 set f [open $audit_path w]
 puts $f "instance\tmaster\torigin_dbu\torientation\tstatus_before\tstatus_after\tdont_touch"
 dict for {name data} $snapshot {puts $f [join [list $name [lindex $data 0] [lindex $data 1] [lindex $data 2] [lindex $data 3] FIRM [lindex $data 4]] "\t"]}
 close $f
 vslivehd::verify_clock_roots $snapshot ${audit_path}.fixed.tsv
 return $snapshot
}
proc vslivehd::verify_clock_roots {snapshot audit_path} {
 set actual [dict create]
 foreach clock [all_clocks] {
  foreach pin [get_property $clock sources] {
   if {[get_property $pin is_port]} {continue}
   set term [sta::sta_to_db_pin $pin]
   if {$term eq "NULL"} {error "Clock source [get_full_name $pin] has no physical ITerm"}
   dict set actual [[$term getInst] getName] 1
  }
 }
 if {[lsort [dict keys $actual]] ne [lsort [dict keys $snapshot]]} {error "Declared clock-root identities changed"}
 set rows {}
 dict for {name data} $snapshot {
  set inst [[ord::get_db_block] findInst $name]
  if {$inst eq "NULL"} {error "Declared clock root $name is missing"}
  set after [list [[$inst getMaster] getName] [$inst getLocation] [$inst getOrient]]
  if {$after ne [lrange $data 0 2]} {error "Clock root master/location/orientation changed: $name"}
  if {[$inst getPlacementStatus] ne "FIRM" || [$inst isDoNotTouch] != [lindex $data 4]} {error "Clock root placement/protection changed: $name"}
  lappend rows [concat [list $name] $after [list FIRM [$inst isDoNotTouch]]]
 }
 set f [open $audit_path w]
 puts $f "instance\tmaster\torigin_dbu\torientation\tstatus\tdont_touch"
 foreach row $rows {puts $f [join $row "\t"]};close $f
 puts "CLOCK_ROOT_GEOMETRY_PASS roots[dict size $snapshot] exactmasterxyorientation FIRM protected"
}
