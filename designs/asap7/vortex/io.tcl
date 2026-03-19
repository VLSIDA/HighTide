# io.tcl — Explicit pin placement for Vortex on ASAP7
#
# Uses place_pin (not set_io_pin_constraint) for deterministic placement.
# Pins are evenly distributed and snapped to metal tracks.
#
# Edge assignment based on data flow:
#   Right : mem_req_* (output request bus to external memory)
#   Left  : mem_rsp_* (input response bus from external memory)
#   Top   : clk, reset
#   Bottom: dcr_*, busy (low-bandwidth config/status)
 
# ── Die dimensions ──
lassign [ord::get_die_area] die_lx die_ly die_ux die_uy
puts "INFO(io.tcl): Die area: ($die_lx, $die_ly) to ($die_ux, $die_uy)"
 
# ── ASAP7 track parameters (from make_tracks.tcl) ──
# M4 (horizontal): pins on left/right edges, spaced along y
# M5 (vertical):   pins on top/bottom edges, spaced along x
set m4_y_offset 0.012
set m4_y_pitch  0.048
set m5_x_offset 0.012
set m5_x_pitch  0.048
 
# ── Helper: collect and sort port names matching a glob ──
proc get_port_list {pattern} {
    set pins {}
    foreach p [get_ports -quiet $pattern] {
        lappend pins [get_property $p name]
    }
    return [lsort $pins]
}
 
# ── Snap to nearest track ──
proc snap_track {val offset pitch} {
    set n [expr {round(($val - $offset) / $pitch)}]
    return [expr {$offset + $n * $pitch}]
}
 
# ── Place pins evenly along an edge with track snapping ──
proc place_edge {edge layer pins} {
    upvar die_lx lx die_ly ly die_ux ux die_uy uy
    upvar m4_y_offset m4yo m4_y_pitch m4yp
    upvar m5_x_offset m5xo m5_x_pitch m5xp
 
    set n [llength $pins]
    if {$n == 0} return
 
    switch $edge {
        left {
            set margin 2.0
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
            set margin 2.0
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
            set margin 2.0
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
            set margin 2.0
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
 
# ══════════════════════════════════════════════════════════════════════════
# Assemble pin lists per edge
# ══════════════════════════════════════════════════════════════════════════
 
# ── RIGHT edge: memory request bus (outputs + ready input) ──
# Group by signal type so related bits are physically adjacent
set right_pins [concat \
    [get_port_list "mem_req_valid*"] \
    [get_port_list "mem_req_rw*"] \
    [get_port_list "mem_req_ready*"] \
    [get_port_list "mem_req_addr*"] \
    [get_port_list "mem_req_byteen*"] \
    [get_port_list "mem_req_data*"] \
    [get_port_list "mem_req_tag*"] \
]
 
# ── LEFT edge: memory response bus (inputs + ready output) ──
set left_pins [concat \
    [get_port_list "mem_rsp_valid*"] \
    [get_port_list "mem_rsp_ready*"] \
    [get_port_list "mem_rsp_data*"] \
    [get_port_list "mem_rsp_tag*"] \
]
 
# ── TOP edge: clock and reset ──
set top_pins {clk reset}
 
# ── BOTTOM edge: DCR config + busy status ──
set bottom_pins [concat \
    [get_port_list "dcr_wr_valid*"] \
    [get_port_list "dcr_wr_addr*"] \
    [get_port_list "dcr_wr_data*"] \
    [get_port_list "busy*"] \
]
 
# ══════════════════════════════════════════════════════════════════════════
# Verify all signal pins are accounted for (exclude VDD/VSS)
# ══════════════════════════════════════════════════════════════════════════
set all_placed [concat $left_pins $right_pins $top_pins $bottom_pins]
set all_ports [get_port_list "*"]
 
set signal_ports {}
foreach p $all_ports {
    if {$p ne "VDD" && $p ne "VSS"} {
        lappend signal_ports $p
    }
}
 
set placed_count [llength $all_placed]
set total_count [llength $signal_ports]
 
if {$placed_count != $total_count} {
    puts "WARNING(io.tcl): $placed_count pins assigned but $total_count signal ports exist!"
    set placed_set [lsort -unique $all_placed]
    foreach p $signal_ports {
        if {[lsearch -exact $placed_set $p] < 0} {
            puts "  UNASSIGNED: $p"
        }
    }
} else {
    puts "INFO(io.tcl): All $total_count signal pins assigned to edges."
}
 
# ══════════════════════════════════════════════════════════════════════════
# Place all pins
# ══════════════════════════════════════════════════════════════════════════
puts "INFO(io.tcl): Placing [llength $left_pins] pins on LEFT edge (M4)"
place_edge left M4 $left_pins
 
puts "INFO(io.tcl): Placing [llength $right_pins] pins on RIGHT edge (M4)"
place_edge right M4 $right_pins
 
puts "INFO(io.tcl): Placing [llength $top_pins] pins on TOP edge (M5)"
place_edge top M5 $top_pins
 
puts "INFO(io.tcl): Placing [llength $bottom_pins] pins on BOTTOM edge (M5)"
place_edge bottom M5 $bottom_pins
 
set total_placed [expr {[llength $left_pins] + [llength $right_pins] + [llength $top_pins] + [llength $bottom_pins]}]
puts "INFO(io.tcl): Total pins placed: $total_placed"