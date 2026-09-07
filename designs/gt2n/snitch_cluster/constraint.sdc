current_design snitch_cluster_wrapper

set clk_name  clk
set clk_port_name clk_i
set clk_period 6000

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [all_inputs -no_clocks]
# Split -min/-max input delay: same reasoning as the asap7/nangate45 SDCs
# (see their constraint.sdc). Basically simulating launch side network latency for IO paths.

set_input_delay -max 10   -clock $clk_name $non_clock_inputs
set_input_delay -min 1500 -clock $clk_name $non_clock_inputs
set_output_delay 10 -clock $clk_name [all_outputs]

# Async reset: exclude recovery/removal checks on rst_ni.
set_false_path -from [get_ports rst_ni]
