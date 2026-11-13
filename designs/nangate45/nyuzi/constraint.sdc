current_design NyuziProcessor

set clk_period 4.5
set clk_io_pct 0.25

create_clock -name clk -period $clk_period [get_ports clk]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock clk [all_inputs -no_clocks]
set_output_delay [expr $clk_period * $clk_io_pct] -clock clk [all_outputs]
