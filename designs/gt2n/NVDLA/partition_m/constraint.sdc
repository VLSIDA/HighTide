current_design NV_NVDLA_partition_m

set clk_name nvdla_core_clk
set clk_period 660
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period -waveform [list 0 [expr $clk_period / 2]] $clk_port
set_clock_transition -rise -min 0.1 [get_clocks $clk_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_name]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

set_ideal_network [get_ports direct_reset_]
set_ideal_network [get_ports dla_reset_rstn]
set_ideal_network -no_propagate [get_nets nvdla_core_rstn]
set_ideal_network [get_ports test_mode]

set_false_path -from [get_ports direct_reset_]
set_false_path -from [get_ports dla_reset_rstn]
set_false_path -from [get_ports test_mode]
set_false_path -from [get_ports tmc2slcg_disable_clock_gating]
set_false_path -from [get_ports global_clk_ovr_on]
set_false_path -from [get_ports nvdla_clk_ovr_on]
# async set/reset `-to [get_pin */SETN|/RESETN]` false-paths omitted —
# the OpenSTA write_sdc bug (bazel-orfs 553c1c3 / OpenROAD 299f3015)
# corrupts wildcard-expanded instance names (invalid UTF-8) and Tcl 9
# then hard-fails floorplan. Redundant: reset sources already -from
# false-pathed and reset nets are set_ideal_network. Matches the fix
# already applied on asap7/nangate45/sky130hd partition_m.
