current_design litepcie_core

# See designs/asap7/litepci/constraint.sdc for the SDC story.  Single user
# clock on `pcie_us/user_clk`; `clk` is the user clock forwarded off-chip
# and modeled as a generated clock to avoid the spurious WNS from
# `set_output_delay` timing the CTS buffer tree as data.

set clk_name      sys_clk
set clk_period    20
set clk_io_pct    0.2

# 20 ns / 50 MHz — sky130hd baseline.  Real critical path is FakeRAM
# clk-to-Q + DMA datapath.
# Earlier 20000 ps and 10000 ps values were used for the user and reference
# clocks. Those values were written in picoseconds in this nanosecond-unit file.
# The user clock is now 20 ns and the 100 MHz PCIe reference clock is 10 ns.
# This design still does not route on the new GRT (issue #204), independent of
# the clock.

create_clock -name $clk_name -period $clk_period [get_pins pcie_us/user_clk]
create_clock -name pcie_refclk -period 10 [get_ports pcie_clk_p]
set_clock_groups -asynchronous \
    -group [get_clocks $clk_name] \
    -group [get_clocks pcie_refclk]

# Same forwarded-clock-feedthrough fix as asap7 / designs/asap7/litedram.
create_generated_clock -name clk_fwd -source [get_pins pcie_us/user_clk] \
    -divide_by 1 [get_ports clk]

set non_clock_inputs [lsearch -inline -all -not \
    [lsearch -inline -all -not [all_inputs] pcie_clk_p] pcie_clk_n]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
