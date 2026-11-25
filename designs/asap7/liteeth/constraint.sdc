current_design liteeth_udp_usp_gth_sgmii

set clk_name clk
set clk_port_name sys_clock
set clk_period 810
set clk_io_pct 0.2

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
# The off-chip GTH interface (gth_* ports) is constrained to its own clocks below.
set sys_inputs {}
foreach p $non_clock_inputs { if {![string match gth_* [get_full_name $p]]} { lappend sys_inputs $p } }
set sys_outputs {}
foreach p [all_outputs] { if {![string match gth_* [get_full_name $p]]} { lappend sys_outputs $p } }

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $sys_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name $sys_outputs

# sys_reset feeds a reset synchronizer; the template set_input_delay makes its
# hold check the worst min path at finish (-336 ps on asap7, a constraint
# artifact, not silicon). Exclude it like any asynchronous reset input.
set_false_path -from [get_ports sys_reset]

# --- GTH transceiver, off chip (designs/src/liteeth/dev/gth_offchip.py) ------
# Its recovered clocks drive the PCS TX/RX domains: full rate straight through
# BUFG_GT (DIV 0) and half rate through BUFG_GT's divider (DIV 1). Standard
# gigabit Ethernet (1000BASE-X, 1.25 Gbaud): 125 MHz full rate = 8000 ps (8 ns),
# 62.5 MHz half rate. Independent of the system clock (asynchronous).
set gth_period 8000
create_clock -name gth_tx -period $gth_period [get_ports gth_txoutclk]
create_clock -name gth_rx -period $gth_period [get_ports gth_rxoutclk]
create_generated_clock -name gth_tx_half -source [get_ports gth_txoutclk] -divide_by 2 \
  [get_pins -hierarchical {*BUFG_GT_1*clk_and_gate/Y}]
create_generated_clock -name gth_rx_half -source [get_ports gth_rxoutclk] -divide_by 2 \
  [get_pins -hierarchical {*BUFG_GT_3*clk_and_gate/Y}]
set_clock_groups -asynchronous -group {clk} -group {gth_tx gth_tx_half} -group {gth_rx gth_rx_half}

# Parallel data: RXDATA/RXCTRL are captured on the RX half clock (RXUSRCLK2),
# TXDATA/TXCTRL launched on the TX half clock (TXUSRCLK2).
set gth_io [expr 2 * $gth_period * $clk_io_pct]
set_input_delay  $gth_io -clock gth_rx_half [get_ports {gth_rxdata* gth_rxctrl*}]
set_output_delay $gth_io -clock gth_tx_half [get_ports {gth_txdata* gth_txctrl*}]
# Resets, power-down, comma-align enables and status are quasi-static.
set_false_path -to   [get_ports {gth_cpllpd gth_gtrxreset gth_gttxreset gth_rxmcommaalignen gth_rxpcommaalignen}]
set_false_path -from [get_ports {gth_cplllock gth_gtpowergood gth_rxresetdone gth_txresetdone}]
