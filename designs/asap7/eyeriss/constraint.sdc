# Preserve active paths through constant-controlled routing cycles. The
# physical stage hooks repeat this after normalized SDC serialization.
set ::sta_dynamic_loop_breaking 1

current_design TOP

set clk_name  clock
set clk_port_name clock
set clk_period 2500
set clk_io_pct 0.2

set clk_port [get_ports $clk_port_name]
create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

# Reset is treated as an asynchronous control input
set_false_path -from [get_ports reset]
