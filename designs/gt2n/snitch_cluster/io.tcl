# IO pin placement for snitch_cluster_wrapper (gt2n)
# Distributes all pins evenly across all four die edges in port order.
# Same generic approach as the asap7/nangate45 io.tcl (query the design for
# ports rather than hardcoding names), retargeted to gt2n's IO placer layers
# and pitch. Uses edge_margin inward from the die boundary rather than
# -force_to_die_boundary -- see designs/gt2n/floonoc/io.tcl and
# designs/gt2n/gemmini/io.tcl, which hit GRT-0209 "pin completely outside
# die" with the boundary-forced form.
#
# ── gt2n layer config (from platforms/gt2n/config.mk + lef/gt2_tech.lef) ──
# IO_PLACER_H = M2 (HORIZONTAL layer -> left/right edge pins), pitch 0.024, width 0.012
# IO_PLACER_V = M3 (VERTICAL layer -> top/bottom edge pins), pitch 0.028, width 0.014

set hor_layer  M2
set ver_layer  M3
set hor_offset 0.006
set hor_pitch  0.024
set ver_offset 0.007
set ver_pitch  0.028

set edge_margin 5.0  ;# distance inward from die edge (avoids GRT-0209)
set end_margin  2.0  ;# distance from corner along the edge

proc snap_track {val offset pitch} {
    set n [expr {round(($val - $offset) / $pitch)}]
    return [expr {$offset + $n * $pitch}]
}

# ── Place pins evenly along an edge, edge_margin inside the die boundary ──
proc place_edge {edge layer pins} {
    upvar edge_margin em end_margin sm
    upvar hor_offset ho hor_pitch hp ver_offset vo ver_pitch vp

    set n [llength $pins]
    if {$n == 0} return
    lassign [ord::get_die_area] lx ly ux uy

    switch $edge {
        left - right {
            set fixed_x [expr {$edge eq "left" ? $lx + $em : $ux - $em}]
            set lo [expr {$ly + $sm}]
            set hi [expr {$uy - $sm}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_y [expr {$lo + $frac * ($hi - $lo)}]
                set y [snap_track $raw_y $ho $hp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $fixed_x $y]
            }
        }
        top - bottom {
            set fixed_y [expr {$edge eq "top" ? $uy - $em : $ly + $em}]
            set lo [expr {$lx + $sm}]
            set hi [expr {$ux - $sm}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_x [expr {$lo + $frac * ($hi - $lo)}]
                set x [snap_track $raw_x $vo $vp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $x $fixed_y]
            }
        }
    }
}

# ── Collect all pins by querying the design ──
set all_inputs {}
set all_outputs {}

foreach pin [lsort [get_ports -filter "direction == input"]] {
    set name [get_name $pin]
    if {$name eq "clk_i" || $name eq "rst_ni"} continue
    lappend all_inputs $name
}

foreach pin [lsort [get_ports -filter "direction == output"]] {
    lappend all_outputs [get_name $pin]
}

# ── Distribute pins across 4 edges ──
# Strategy: inputs on left + bottom, outputs on right + top, clock/reset on top.
set n_in [llength $all_inputs]
set n_out [llength $all_outputs]

set in_half [expr {$n_in / 2}]
set left_pins [lrange $all_inputs 0 [expr {$in_half - 1}]]
set bottom_pins [lrange $all_inputs $in_half end]

set out_half [expr {$n_out / 2}]
set right_pins [lrange $all_outputs 0 [expr {$out_half - 1}]]
set top_pins [concat [lrange $all_outputs $out_half end] {clk_i rst_ni}]

puts "Placing [llength $left_pins] pins on LEFT edge ($hor_layer)"
place_edge left $hor_layer $left_pins

puts "Placing [llength $right_pins] pins on RIGHT edge ($hor_layer)"
place_edge right $hor_layer $right_pins

puts "Placing [llength $top_pins] pins on TOP edge ($ver_layer)"
place_edge top $ver_layer $top_pins

puts "Placing [llength $bottom_pins] pins on BOTTOM edge ($ver_layer)"
place_edge bottom $ver_layer $bottom_pins

set total [expr {[llength $left_pins] + [llength $right_pins] + [llength $top_pins] + [llength $bottom_pins]}]
puts "Total pins placed: $total"
