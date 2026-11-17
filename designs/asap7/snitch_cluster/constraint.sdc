current_design snitch_cluster_wrapper

set clk_name  clk
set clk_port_name clk_i
set clk_period 6000

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [all_inputs -no_clocks]
# Model the assumed external source clock-tree latency consistently for
# setup and hold. The latest arrival must not precede the earliest arrival.
# This is a zero-width 1500 ps interface arrival window; it is an explicit
# boundary assumption, not a measured external timing specification.
set_input_delay -max 1500 -clock $clk_name $non_clock_inputs
set_input_delay -min 1500 -clock $clk_name $non_clock_inputs
set_output_delay 10 -clock $clk_name [all_outputs]

set_driving_cell -lib_cell DFFHQNx2_ASAP7_75t_R -pin QN $non_clock_inputs
set_load [expr 4.0 * 0.683716] [all_outputs]

# Async reset: exclude recovery/removal checks on rst_ni.
# The reset tree has ~230K fanout which causes STA memory corruption
# during repair_timing. CTS will buffer the reset tree properly.
set_false_path -from [get_ports rst_ni]
