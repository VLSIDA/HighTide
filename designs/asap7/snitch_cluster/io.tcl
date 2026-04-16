# IO pin placement for snitch_cluster_wrapper
# Distributes all pins evenly across all four die edges in port order.
# Uses the same approach as gemmini: track-snapped, evenly-spaced placement.
#
# Layer convention (from ASAP7 IO_PLACER_H/V):
#   Left/Right edges: M4 (horizontal layer), pins spaced along y
#   Top/Bottom edges: M5 (vertical layer), pins spaced along x

# ── Die dimensions ──
lassign [ord::get_die_area] die_lx die_ly die_ux die_uy
puts "Die area: ($die_lx, $die_ly) to ($die_ux, $die_uy)"

# ── Track parameters (from ASAP7 make_tracks.tcl) ──
set m4_y_offset 0.012
set m4_y_pitch  0.048
set m5_x_offset 0.012
set m5_x_pitch  0.048

# ── Snap to nearest track ──
proc snap_track {val offset pitch} {
    set n [expr {round(($val - $offset) / $pitch)}]
    return [expr {$offset + $n * $pitch}]
}

# ── Place pins evenly along an edge ──
proc place_edge {edge layer pins} {
    upvar die_lx lx die_ly ly die_ux ux die_uy uy
    upvar m4_y_offset m4yo m4_y_pitch m4yp
    upvar m5_x_offset m5xo m5_x_pitch m5xp

    set n [llength $pins]
    if {$n == 0} return

    set margin 2.0

    switch $edge {
        left {
            set lo [expr {$ly + $margin}]
            set hi [expr {$uy - $margin}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_y [expr {$lo + $frac * ($hi - $lo)}]
                set y [snap_track $raw_y $m4yo $m4yp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $lx $y] -force_to_die_boundary
            }
        }
        right {
            set lo [expr {$ly + $margin}]
            set hi [expr {$uy - $margin}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_y [expr {$lo + $frac * ($hi - $lo)}]
                set y [snap_track $raw_y $m4yo $m4yp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $ux $y] -force_to_die_boundary
            }
        }
        top {
            set lo [expr {$lx + $margin}]
            set hi [expr {$ux - $margin}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_x [expr {$lo + $frac * ($hi - $lo)}]
                set x [snap_track $raw_x $m5xo $m5xp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $x $uy] -force_to_die_boundary
            }
        }
        bottom {
            set lo [expr {$lx + $margin}]
            set hi [expr {$ux - $margin}]
            for {set i 0} {$i < $n} {incr i} {
                set frac [expr {($i + 0.5) / double($n)}]
                set raw_x [expr {$lo + $frac * ($hi - $lo)}]
                set x [snap_track $raw_x $m5xo $m5xp]
                place_pin -pin_name [lindex $pins $i] -layer $layer \
                    -location [list $x $ly] -force_to_die_boundary
            }
        }
    }
}

# ── Collect all pins by querying the design ──
# Get all pins sorted by name to ensure bus bits are adjacent
set all_inputs {}
set all_outputs {}

foreach pin [lsort [get_ports -filter "direction == input"]] {
    set name [get_name $pin]
    # Skip clock and reset - they go on top
    if {$name eq "clk_i" || $name eq "rst_ni"} continue
    lappend all_inputs $name
}

foreach pin [lsort [get_ports -filter "direction == output"]] {
    lappend all_outputs [get_name $pin]
}

# ── Distribute pins across 4 edges ──
# Strategy: inputs on left + bottom, outputs on right + top
# Clock and reset on top edge
set n_in [llength $all_inputs]
set n_out [llength $all_outputs]

# Split inputs: first half on left, second half on bottom
set in_half [expr {$n_in / 2}]
set left_pins [lrange $all_inputs 0 [expr {$in_half - 1}]]
set bottom_pins [lrange $all_inputs $in_half end]

# Split outputs: first half on right, second half on top
set out_half [expr {$n_out / 2}]
set right_pins [lrange $all_outputs 0 [expr {$out_half - 1}]]
set top_pins [concat [lrange $all_outputs $out_half end] {clk_i rst_ni}]

puts "Placing [llength $left_pins] pins on LEFT edge (M4)"
place_edge left M4 $left_pins

puts "Placing [llength $right_pins] pins on RIGHT edge (M4)"
place_edge right M4 $right_pins

puts "Placing [llength $top_pins] pins on TOP edge (M5)"
place_edge top M5 $top_pins

puts "Placing [llength $bottom_pins] pins on BOTTOM edge (M5)"
place_edge bottom M5 $bottom_pins

set total [expr {[llength $left_pins] + [llength $right_pins] + [llength $top_pins] + [llength $bottom_pins]}]
puts "Total pins placed: $total"
