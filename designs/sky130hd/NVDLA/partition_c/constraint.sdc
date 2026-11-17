# NVDLA partition_c — sky130hd timing constraints (scaled ~10x from asap7 1500 ps)
# GRT stage: period_min 14.888 ns < 15 ns constraint; reg2reg closes.
# WNS −0.671 ns is io feedthrough (clk_io_pct=0.2 artifact), not reg2reg.
current_design NV_NVDLA_partition_c

set clk_name nvdla_core_clk
set clk_period 15.0
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period -waveform [list 0 [expr $clk_period / 2]] $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

set_clock_transition -rise -min 0.1 [get_clocks $clk_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_name]

set_ideal_network [get_ports {global_clk_ovr_on}]
set_ideal_network [get_ports {test_mode}]
set_ideal_network [get_ports {direct_reset_}]
set_ideal_network [get_ports {dla_reset_rstn}]
set_ideal_network [get_ports {nvdla_core_clk}]
set_ideal_network [get_ports {nvdla_clk_ovr_on}]
set_ideal_network [get_ports {tmc2slcg_disable_clock_gating}]
set_ideal_network [get_ports {pwrbus_ram_pd*}]

# Extend ideal_network from reset input ports to the internal reset net so CTS
# does not insert NDR buffers into the reset fanout tree.
set_ideal_network [get_nets {nvdla_core_rstn}]

# False-path from reset input ports so repair_timing ignores async-reset paths.
# Using -from (port-level) rather than -to */RESET_B (pin-level) to avoid the
# OpenSTA write_sdc wildcard-expansion UTF-8 corruption bug.
set_false_path -from [get_ports {direct_reset_}]
set_false_path -from [get_ports {dla_reset_rstn}]

# Quasi-static DFT / clock-override controls — false-pathed in NVDLA's
# upstream constraints and in partition_m/a and the gt2n partition_c SDC.
set_false_path -from [get_ports {test_mode}]
set_false_path -from [get_ports {tmc2slcg_disable_clock_gating}]
set_false_path -from [get_ports {global_clk_ovr_on}]
set_false_path -from [get_ports {nvdla_clk_ovr_on}]

# Removed: set_false_path -to [get_pin */RESETN] and */SETN — those are asap7
# pin names; on sky130hd the equivalent pins are RESET_B/SET_B so they matched
# nothing and were silent no-ops.

set_max_fanout 128 [current_design]
set_wire_load_mode enclosed
