# ===================================================================
# NVDLA partition_o — gt2n timing constraints
# clk_period tuned to close setup (period_min * 1.10, per the HighTide
# clock-loosening convention — see CLAUDE.md "Pushing clock frequency").
# clk_falcon_period tracks clk_period at the NVIDIA reference falcon:core
# ratio (2500/2000 = 1.25, from asap7's unmodified reference constraint.sdc).
# ===================================================================
current_design NV_NVDLA_partition_o

set clk_name nvdla_core_clk
set clk_falcon_name nvdla_falcon_clk
set clk_period 2270
set clk_falcon_period 2838
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]
set clk_falcon_port [get_ports $clk_falcon_name]

create_clock -name $clk_name -period $clk_period -waveform [list 0 [expr $clk_period / 2]] $clk_port
set_clock_transition -rise -min 0.1 [get_clocks $clk_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_name]

create_clock -name $clk_falcon_name -period $clk_falcon_period -waveform [list 0 [expr $clk_falcon_period / 2]] $clk_falcon_port
set_clock_transition -rise -min 0.1 [get_clocks $clk_falcon_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_falcon_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_falcon_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_falcon_name]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set non_clock_inputs [lsearch -inline -all -not -exact $non_clock_inputs $clk_falcon_port]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

# Scoped hold fixes: sdp2csb_resp_valid and cmac_b2csb_resp_valid are zero-logic passthrough
# primary inputs from sibling gt2n partitions, with no on-chip source register to model skew
# against, so the blanket -min under-budgets their minimum arrival. -max set equal to -min
# (same zero-window assumption the blanket delay above uses) so setup stays min<=max.
set_input_delay -min 494 -clock $clk_name [get_ports {sdp2csb_resp_*}]
set_input_delay -max 494 -clock $clk_name [get_ports {sdp2csb_resp_*}]
set_input_delay -min 469 -clock $clk_name [get_ports {cmac_b2csb_resp_*}]
set_input_delay -max 469 -clock $clk_name [get_ports {cmac_b2csb_resp_*}]

set_ideal_network [get_ports test_mode]
set_ideal_network [get_ports direct_reset_]
set_ideal_network [get_ports dla_reset_rstn]
set_ideal_network [get_nets nvdla_core_rstn]

set_false_path -from [get_ports direct_reset_]
set_false_path -from [get_ports dla_reset_rstn]
set_false_path -from [get_ports test_mode]
set_false_path -from [get_ports pwrbus_ram_pd*]
set_false_path -from [get_ports tmc2slcg_disable_clock_gating]
set_false_path -from [get_ports global_clk_ovr_on]
set_false_path -from [get_clocks nvdla_core_clk] -to [get_clocks nvdla_falcon_clk]
set_false_path -from [get_clocks nvdla_falcon_clk] -to [get_clocks nvdla_core_clk]
