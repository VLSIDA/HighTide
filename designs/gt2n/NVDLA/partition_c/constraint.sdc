current_design NV_NVDLA_partition_c

set clk_name nvdla_core_clk
set clk_period 1300

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period -waveform [list 0 [expr $clk_period / 2]] $clk_port

set_clock_transition -rise -min 0.1 [get_clocks $clk_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_name]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

# Delay credit more realistically models the capture-side clock insertion latency of whatever
# receives this partition's boundary outputs, since all partitions are intended as a single die.
# The delay was chosen to be approximately half of the worst clock network latency seen 
# within this partition, while stile being expressed relative to the clock period.
set_output_delay [expr -$clk_period * 1.5] -clock $clk_name [all_outputs]

set_ideal_network [get_ports global_clk_ovr_on]
set_ideal_network [get_ports test_mode]
set_ideal_network [get_ports direct_reset_]
set_ideal_network [get_ports dla_reset_rstn]
set_ideal_network [get_ports nvdla_core_clk]
set_ideal_network [get_ports nvdla_clk_ovr_on]
set_ideal_network [get_ports tmc2slcg_disable_clock_gating]
set_ideal_network [get_ports pwrbus_ram_pd*]
set_ideal_network [get_nets nvdla_core_rstn]

set_false_path -from [get_ports direct_reset_]
set_false_path -from [get_ports dla_reset_rstn]
set_false_path -from [get_ports test_mode]
set_false_path -from [get_ports pwrbus_ram_pd*]
set_false_path -from [get_ports tmc2slcg_disable_clock_gating]
set_false_path -from [get_ports global_clk_ovr_on]
set_false_path -from [get_ports nvdla_clk_ovr_on]

# -through (not -to */SETN|RESETN) works around an OpenSTA write_sdc
# instance-name corruption bug on the wildcard form; see CLAUDE.md.
set_false_path -through [get_pins {u_partition_c_reset.sync_reset_synced_rstn.NV_GENERIC_CELL.q$_DFF_PN0_/Q}]
set_false_path -through [get_pins {u_partition_c_reset.sync_reset_synced_rstn.NV_GENERIC_CELL.d0$_DFF_PN0_/Q}]

set_max_fanout 128 [current_design]

set_wire_load_mode enclosed
