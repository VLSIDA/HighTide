# ===================================================================
# Using Contents of File: syn/cons/NV_NVDLA_partition_o.sdc
# NVDLA Open Source Project
#
# Copyright (c) 2016 – 2017 NVIDIA Corporation. Licensed under the
# NVDLA Open Hardware License; see the "LICENSE.txt" file that came
# with this distribution for more information.
# ===================================================================
current_design NV_NVDLA_partition_o

set clk_name nvdla_core_clk
set clk_falcon_name nvdla_falcon_clk
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]
set clk_falcon_port [get_ports $clk_falcon_name]

create_clock -name $clk_name  -period 1800  -waveform {0 900}  $clk_port
set_clock_transition -max -rise 50 [get_clocks nvdla_core_clk]
set_clock_transition -max -fall 50 [get_clocks nvdla_core_clk]
set_clock_transition -min -rise 50 [get_clocks nvdla_core_clk]
set_clock_transition -min -fall 50 [get_clocks nvdla_core_clk]

create_clock -name $clk_falcon_name  -period 3032  -waveform {0 1516}  $clk_falcon_port
set_clock_transition -max -rise 50 [get_clocks nvdla_falcon_clk]
set_clock_transition -max -fall 50 [get_clocks nvdla_falcon_clk]
set_clock_transition -min -rise 50 [get_clocks nvdla_falcon_clk]
set_clock_transition -min -fall 50 [get_clocks nvdla_falcon_clk]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] "^($clk_port|$clk_falcon_port)$"]

set_input_delay [expr 3032 * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr 3032 * $clk_io_pct] -clock $clk_name [all_outputs]

set_ideal_network [get_ports test_mode]
set_ideal_network [get_ports direct_reset_]
set_ideal_network [get_ports dla_reset_rstn]
set_ideal_network -no_propagate [get_nets nvdla_core_rstn]

set_false_path   -from [get_ports direct_reset_]
set_false_path   -from [get_ports dla_reset_rstn]
set_false_path   -from [get_ports test_mode]
set_false_path   -from [get_ports pwrbus_ram_pd*]
set_false_path   -from [get_ports tmc2slcg_disable_clock_gating]
set_false_path   -from [get_ports global_clk_ovr_on]
set_false_path   -from [get_clocks nvdla_core_clk] -to [get_clocks nvdla_falcon_clk]
set_false_path   -from [get_clocks nvdla_falcon_clk] -to [get_clocks nvdla_core_clk]