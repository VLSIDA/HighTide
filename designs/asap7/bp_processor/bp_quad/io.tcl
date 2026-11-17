# IO Pin Constraints for bp_quad (bp_processor) on ASAP7
#
# Each bus is a -group -order so bits stay contiguous and ordered; the
# pin placer picks each group's edge and position from the connected
# logic. The original hand-assigned side regions (DMA out -> top,
# mem_fwd -> left, mem_rev -> right) were dropped 2026-11-17: placement
# ignored the assumption and every pin trailed mm-scale wire to its
# assigned edge (39 m total wirelength on the 3000x3000 first close).

# Helper: generate bus pin names in order
proc bus_pins {name high {low 0}} {
    set pins {}
    for {set i $low} {$i <= $high} {incr i} {
        lappend pins "${name}\[${i}\]"
    }
    return $pins
}

# ============================================================
# Control + DMA data inputs
# ============================================================
# Group each bus so bits stay ordered together
set_io_pin_constraint -group -order -pin_names [bus_pins my_did_i 2]
set_io_pin_constraint -group -order -pin_names [bus_pins host_did_i 2]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_v_i 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_ready_and_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_i 255]

# ============================================================
# DMA data outputs + DMA packet outputs
# ============================================================
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_o 255]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_v_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_data_ready_and_i 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_o 75]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_v_o 1]
set_io_pin_constraint -group -order -pin_names [bus_pins dma_pkt_ready_and_i 1]

# ============================================================
# Memory Forward interface
# ============================================================
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_header_i 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_data_i 127]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_header_o 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_fwd_data_o 127]

# ============================================================
# Memory Reverse interface
# ============================================================
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_header_i 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_data_i 127]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_header_o 64]
set_io_pin_constraint -group -order -pin_names [bus_pins mem_rev_data_o 127]
