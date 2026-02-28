# IO pin placement for Gemmini 16x16x2x2 systolic mesh
# Manually places every pin at evenly-spaced, track-snapped positions
# to ensure uniform distribution and ordered placement.
#
# Layer convention (from ASAP7 IO_PLACER_H/V):
#   Left/Right edges: M4 (horizontal layer), pins spaced along y
#   Top/Bottom edges: M5 (vertical layer), pins spaced along x

# ── Die dimensions ──
lassign [ord::get_die_area] die_lx die_ly die_ux die_uy
puts "Die area: ($die_lx, $die_ly) to ($die_ux, $die_uy)"

# ── Track parameters (from ASAP7 make_tracks.tcl) ──
# M4: y_offset=0.012, y_pitch=0.048 (for left/right edge pin spacing)
# M5: x_offset=0.012, x_pitch=0.048 (for top/bottom edge pin spacing)
set m4_y_offset 0.012
set m4_y_pitch  0.048
set m5_x_offset 0.012
set m5_x_pitch  0.048

# ── Expand a port name into physical pin names ──
proc expand_port {name width} {
    set pins {}
    if {$width == 1} {
        lappend pins $name
    } else {
        for {set b 0} {$b < $width} {incr b} {
            lappend pins "${name}\[${b}\]"
        }
    }
    return $pins
}

# ── Build ordered list of physical pin names for a 16x2 bus ──
proc bus_pins {prefix width} {
    set pins {}
    for {set i 0} {$i < 16} {incr i} {
        for {set j 0} {$j < 2} {incr j} {
            foreach p [expand_port "${prefix}_${i}_${j}" $width] {
                lappend pins $p
            }
        }
    }
    return $pins
}

# ── Build ordered list for control signals (dataflow:1, propagate:1, shift:5) ──
proc ctrl_pins {prefix} {
    set pins {}
    for {set i 0} {$i < 16} {incr i} {
        for {set j 0} {$j < 2} {incr j} {
            foreach p [expand_port "${prefix}_${i}_${j}_dataflow" 1] {
                lappend pins $p
            }
            foreach p [expand_port "${prefix}_${i}_${j}_propagate" 1] {
                lappend pins $p
            }
            foreach p [expand_port "${prefix}_${i}_${j}_shift" 5] {
                lappend pins $p
            }
        }
    }
    return $pins
}

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

    switch $edge {
        left {
            # M4 pins along y-axis, x = die_lx
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
            # M5 pins along x-axis, y = die_uy
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

# ── Assemble pin lists per edge ──

# LEFT (512 pins): in_a(8b x 32), in_d(8b x 32)
set left_pins [concat \
    [bus_pins io_in_a 8] \
    [bus_pins io_in_d 8] \
]

# RIGHT (512 pins): in_b(8b x 32), in_valid(1b x 32), in_last(1b x 32),
#   in_id(2b x 32), out_valid(1b x 32), out_id(2b x 32), out_last(1b x 32)
set right_pins [concat \
    [bus_pins io_in_b 8] \
    [bus_pins io_in_valid 1] \
    [bus_pins io_in_last 1] \
    [bus_pins io_in_id 2] \
    [bus_pins io_out_valid 1] \
    [bus_pins io_out_id 2] \
    [bus_pins io_out_last 1] \
]

# TOP (866 pins): out_b(20b x 32), in_control(7b x 32), clock, reset
set top_pins [concat \
    [bus_pins io_out_b 20] \
    [ctrl_pins io_in_control] \
    {clock reset} \
]

# BOTTOM (864 pins): out_c(20b x 32), out_control(7b x 32)
set bottom_pins [concat \
    [bus_pins io_out_c 20] \
    [ctrl_pins io_out_control] \
]

# ── Place all pins ──
puts "Placing [llength $left_pins] pins on LEFT edge (M4)"
place_edge left M4 $left_pins

puts "Placing [llength $right_pins] pins on RIGHT edge (M4)"
place_edge right M4 $right_pins

puts "Placing [llength $top_pins] pins on TOP edge (M5)"
place_edge top M5 $top_pins

puts "Placing [llength $bottom_pins] pins on BOTTOM edge (M5)"
place_edge bottom M5 $bottom_pins

puts "Total pins placed: [expr {[llength $left_pins] + [llength $right_pins] + [llength $top_pins] + [llength $bottom_pins]}]"
