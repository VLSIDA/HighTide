# IO pin placement for Gemmini 16x16x2x2 systolic mesh (gt2n)
# Ported from designs/asap7/gemmini/io.tcl: same bus-grouped, evenly-spaced
# pin ordering (keeps each bus's bits contiguous per mesh row/column to
# limit wirelength/congestion), but retargeted to gt2n's IO placer layers
# and pitch instead of asap7's M4/M5. Placed edge_margin inside the die
# boundary rather than -force_to_die_boundary — see designs/gt2n/floonoc/io.tcl,
# which hit GRT-0209 "pin completely outside die" with the boundary-forced form.
#
# ── gt2n layer config (from platforms/gt2n/config.mk + lef/gt2_tech.lef) ──
#
# IO_PLACER_H = M2 (HORIZONTAL layer → left/right edge pins)
#   M2: WIDTH 0.012 um, PITCH 0.024 um
#   hor_offset = WIDTH/2 = 0.006 um
#
# IO_PLACER_V = M3 (VERTICAL layer → top/bottom edge pins)
#   M3: WIDTH 0.014 um, PITCH 0.028 um
#   ver_offset = WIDTH/2 = 0.007 um

set hor_layer  M2
set ver_layer  M3
set hor_offset 0.006
set hor_pitch  0.024
set ver_offset 0.007
set ver_pitch  0.028

set edge_margin 5.0  ;# distance inward from die edge (avoids GRT-0209)
set end_margin  2.0  ;# distance from corner along the edge

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

# ── Assemble pin lists per edge (same bus grouping as asap7) ──

# LEFT (512 pins, M2): in_a(8b x 32), in_d(8b x 32)
set left_pins [concat \
    [bus_pins io_in_a 8] \
    [bus_pins io_in_d 8] \
]

# RIGHT (512 pins, M2): interleave by mesh row (i, j) so high-fanout control
# signals (io_in_id, io_out_id, io_in_valid/last, io_out_valid/last) are
# spread along the full edge instead of clustered in the vertical middle.
set right_pins {}
for {set i 0} {$i < 16} {incr i} {
    for {set j 0} {$j < 2} {incr j} {
        foreach p [expand_port "io_in_b_${i}_${j}"  8] { lappend right_pins $p }
        foreach p [expand_port "io_in_valid_${i}_${j}"  1] { lappend right_pins $p }
        foreach p [expand_port "io_in_last_${i}_${j}"   1] { lappend right_pins $p }
        foreach p [expand_port "io_in_id_${i}_${j}"     2] { lappend right_pins $p }
        foreach p [expand_port "io_out_valid_${i}_${j}" 1] { lappend right_pins $p }
        foreach p [expand_port "io_out_id_${i}_${j}"    2] { lappend right_pins $p }
        foreach p [expand_port "io_out_last_${i}_${j}"  1] { lappend right_pins $p }
    }
}

# TOP (866 pins, M3): out_b(20b x 32), in_control(7b x 32), clock, reset
set top_pins [concat \
    [bus_pins io_out_b 20] \
    [ctrl_pins io_in_control] \
    {clock reset} \
]

# BOTTOM (864 pins, M3): out_c(20b x 32), out_control(7b x 32)
set bottom_pins [concat \
    [bus_pins io_out_c 20] \
    [ctrl_pins io_out_control] \
]

# ── Place all pins ──
puts "Placing [llength $left_pins] pins on LEFT edge ($hor_layer)"
place_edge left $hor_layer $left_pins

puts "Placing [llength $right_pins] pins on RIGHT edge ($hor_layer)"
place_edge right $hor_layer $right_pins

puts "Placing [llength $top_pins] pins on TOP edge ($ver_layer)"
place_edge top $ver_layer $top_pins

puts "Placing [llength $bottom_pins] pins on BOTTOM edge ($ver_layer)"
place_edge bottom $ver_layer $bottom_pins

puts "Total pins placed: [expr {[llength $left_pins] + [llength $right_pins] + [llength $top_pins] + [llength $bottom_pins]}]"
