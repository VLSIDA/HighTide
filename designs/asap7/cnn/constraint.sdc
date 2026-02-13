current_design cnn

set clk_name clk
set clk_port_name CLK
set clk_period 1500
set clk_io_pct 0.125

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [all_inputs -no_clocks]
set_input_delay 10 -clock $clk_name $non_clock_inputs
set_output_delay 10 -clock $clk_name [all_outputs]

set_driving_cell -lib_cell DFFHQNx2_ASAP7_75t_R -pin QN $non_clock_inputs
set dff_d_cap 0.683716
set_load [expr 4.0 * $dff_d_cap] [all_outputs]

