# IO Pin Constraints for bp_quad (bp_processor) on ASAP7
#
# Pin distribution across 4 sides:
#   BOTTOM (269 pins): Control signals + DMA data inputs
#   TOP    (340 pins): DMA data outputs + DMA packet outputs
#   LEFT   (390 pins): Memory Forward interface (in + out)
#   RIGHT  (390 pins): Memory Reverse interface (in + out)
#
# Each bus is a separate -group to keep bits ordered together.
# min_distance 40 tracks (1.92um) in PLACE_PINS_ARGS spreads
# pins across <75% of each side.

# Helper: generate bus pin names in order
proc bus_pins {name high {low 0}} {
    set pins {}
    for {set i $low} {$i <= $high} {incr i} {
        lappend pins "${name}\[${i}\]"
    }
    return $pins
}

# ============================================================
# BOTTOM: Control + DMA data inputs
# ============================================================
# Side assignment for all bottom pins
set_io_pin_constraint -region bottom:* -pin_names [list \
    clk_i rt_clk_i reset_i \
    {*}[bus_pins my_did_i 2] \
    {*}[bus_pins host_did_i 2] \
    {*}[bus_pins dma_data_v_i 1] \
    {*}[bus_pins dma_data_ready_and_o 1] \
    {*}[bus_pins dma_data_i 255] \
]
# Group each bus so bits stay ordered together
set_io_pin_constraint -group -order -pin_names [bus_pins my_did_i 2]
set_io_pin_constraint -group -order -pin_names [bus_pins host_did_i 2]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_v_i 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_ready_and_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_i 255]

# ============================================================
# TOP: DMA data outputs + DMA packet outputs
# ============================================================
set_io_pin_constraint -region top:* -pin_names [list \
    {*}[bus_pins dma_data_o 255] \
    {*}[bus_pins dma_data_v_o 1] \
    {*}[bus_pins dma_data_ready_and_i 1] \
    {*}[bus_pins dma_pkt_o 75] \
    {*}[bus_pins dma_pkt_v_o 1] \
    {*}[bus_pins dma_pkt_ready_and_i 1] \
]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_o 255]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_v_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_ready_and_i 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_o 75]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_v_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_ready_and_i 1]

# ============================================================
# LEFT: Memory Forward interface
# ============================================================
set_io_pin_constraint -region left:* -pin_names [list \
    mem_fwd_v_i mem_fwd_ready_and_o \
    {*}[bus_pins mem_fwd_header_i 64] \
    {*}[bus_pins mem_fwd_data_i 127] \
    mem_fwd_v_o mem_fwd_ready_and_i \
    {*}[bus_pins mem_fwd_header_o 64] \
    {*}[bus_pins mem_fwd_data_o 127] \
]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_header_i 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_data_i 127]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_header_o 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_data_o 127]

# ============================================================
# RIGHT: Memory Reverse interface
# ============================================================
set_io_pin_constraint -region right:* -pin_names [list \
    mem_rev_v_i mem_rev_ready_and_o \
    {*}[bus_pins mem_rev_header_i 64] \
    {*}[bus_pins mem_rev_data_i 127] \
    mem_rev_v_o mem_rev_ready_and_i \
    {*}[bus_pins mem_rev_header_o 64] \
    {*}[bus_pins mem_rev_data_o 127] \
]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_header_i 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_data_i 127]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_header_o 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_data_o 127]
