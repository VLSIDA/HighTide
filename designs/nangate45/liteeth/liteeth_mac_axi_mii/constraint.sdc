current_design liteeth_mac_axi_mii

create_clock -name sys_clk -period 10.0 [get_ports sys_clock]
create_clock -name mii_clocks_rx -period 40.0 [get_ports mii_clocks_rx]
create_clock -name mii_clocks_tx -period 40.0 [get_ports mii_clocks_tx]

set_clock_groups -group [get_clocks sys_clk] -group [get_clocks mii_clocks_rx] -asynchronous
set_clock_groups -group [get_clocks sys_clk] -group [get_clocks mii_clocks_tx] -asynchronous  
set_clock_groups -group [get_clocks mii_clocks_rx] -group [get_clocks mii_clocks_tx] -asynchronous

set_input_delay  2.0 -clock sys_clk [get_ports sys_reset]
set_input_delay  2.0 -clock sys_clk [get_ports bus_*]
set_output_delay 2.0 -clock sys_clk [get_ports bus_*]

set_input_delay  4.0 -clock mii_clocks_rx [get_ports mii_rx_*]
set_output_delay 4.0 -clock mii_clocks_tx [get_ports mii_tx_*]

set_output_delay 2.0 -clock sys_clk [get_ports interrupt]
