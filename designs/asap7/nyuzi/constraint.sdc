current_design NyuziProcessor

set clk_period 2841
set clk_io_pct 0.2

create_clock -name clk -period $clk_period [get_ports clk]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock clk [all_inputs -no_clocks]
set_output_delay [expr $clk_period * $clk_io_pct] -clock clk [all_outputs]

set_false_path -from [get_ports reset]
