#################################################################### Design 
current_design service_ihp_chip

#################################################################### Clock del sistema 
set clk_name  wb_clk
set clk_port_name wb_clk
set clk_period 8
set clk_port [get_ports $clk_port_name]
create_clock -name $clk_name -period $clk_period $clk_port

#################################################################### Clock del timer responsabile gating 
set clk_name  timer_clk
set clk_port_name timer_clk
set clk_period 100000
set clk_port [get_ports $clk_port_name]
create_clock -name $clk_name -period $clk_period $clk_port

set_max_fanout 8 [current_design]

set_false_path -from [get_ports wb_rst]
set_false_path -from [get_ports enb_debug]