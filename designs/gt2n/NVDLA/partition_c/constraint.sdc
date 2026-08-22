current_design NV_NVDLA_partition_c

set clk_name nvdla_core_clk
set clk_period 1300
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period -waveform [list 0 [expr $clk_period / 2]] $clk_port

set_clock_transition -rise -min 0.1 [get_clocks $clk_name]
set_clock_transition -rise -max 0.1 [get_clocks $clk_name]
set_clock_transition -fall -min 0.1 [get_clocks $clk_name]
set_clock_transition -fall -max 0.1 [get_clocks $clk_name]

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

# Blanket delay so synth/floorplan/place/CTS see a real input constraint; pre_grt.tcl
# overrides this post-CTS with the true (period-exceeding) cross-partition delay.
set_input_delay [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs

# Delay credit more realistically models the capture-side clock insertion latency of whatever
# receives this partition's boundary outputs, since all partitions are intended as a single die.
# Fixed at -1950 ps -- approximately half of the worst clock network latency observed in this
# partition.
set_output_delay -1950 -clock $clk_name [all_outputs]

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

# -through [get_nets ...] on q/d0 -- regs declared directly in NVDLA's p_SSYNC2DO_C_PP.v
# primitive, not synthesis-tool-internal names, so this stays valid across yosys versions.
# Errors loudly if a toolchain change ever makes either net disappear, instead of silently
# dropping the false-path and reintroducing recovery/removal violations on this reset's fanout.
foreach reset_sync_net {
    u_partition_c_reset.sync_reset_synced_rstn.NV_GENERIC_CELL.q
    u_partition_c_reset.sync_reset_synced_rstn.NV_GENERIC_CELL.d0
} {
  set net [get_nets $reset_sync_net]
  if {[llength $net] == 0} {
    error "constraint.sdc: reset synchronizer net $reset_sync_net not found -- update this false-path"
  }
  set_false_path -through $net
}

set_max_fanout 128 [current_design]

set_wire_load_mode enclosed
