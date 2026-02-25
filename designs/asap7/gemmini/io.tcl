# IO pin constraints for Gemmini 16x16x2x2 systolic mesh
# 546 total pins distributed across 4 edges

proc gen_pins {prefix} {
    set pins {}
    for {set i 0} {$i < 16} {incr i} {
        for {set j 0} {$j < 2} {incr j} {
            lappend pins "${prefix}_${i}_${j}"
        }
    }
    return $pins
}

proc gen_control_pins {prefix} {
    set pins {}
    for {set i 0} {$i < 16} {incr i} {
        for {set j 0} {$j < 2} {incr j} {
            lappend pins "${prefix}_${i}_${j}_dataflow"
            lappend pins "${prefix}_${i}_${j}_propagate"
            lappend pins "${prefix}_${i}_${j}_shift"
        }
    }
    return $pins
}

# LEFT (128 pins): in_a, in_d, in_valid, in_last
set_io_pin_constraint -region left:* -pin_names [concat \
    [gen_pins io_in_a] \
    [gen_pins io_in_d] \
    [gen_pins io_in_valid] \
    [gen_pins io_in_last] \
]

# RIGHT (128 pins): in_b, out_b, out_c, out_valid
set_io_pin_constraint -region right:* -pin_names [concat \
    [gen_pins io_in_b] \
    [gen_pins io_out_b] \
    [gen_pins io_out_c] \
    [gen_pins io_out_valid] \
]

# TOP (130 pins): in_control, in_id, clock, reset
set_io_pin_constraint -region top:* -pin_names [concat \
    [gen_control_pins io_in_control] \
    [gen_pins io_in_id] \
    {clock reset} \
]

# BOTTOM (160 pins): out_control, out_id, out_last
set_io_pin_constraint -region bottom:* -pin_names [concat \
    [gen_control_pins io_out_control] \
    [gen_pins io_out_id] \
    [gen_pins io_out_last] \
]
