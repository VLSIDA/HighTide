current_design liteeth_udp_usp_gth_sgmii

set clk_name clk
set clk_port_name sys_clock
set clk_period 1022
set clk_io_pct 0.2

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port

# The synthesizable GTH stub forwards its selected CPLL reference 1:1;
# analog PLL multiplication and serial recovery are outside this model.
# Match the generated configuration's 156.25 MHz reference input.
set phy_clk_port [get_ports sgmii_refclk]
create_clock -name phy_ref_clk -period 6400 $phy_clk_port

# BUFG_GT DIV=1 produces a divide-by-two fabric clock. Synthesis removes
# the top-level wire aliases; the explicit primitive output pins survive.
set phy_clocks [get_clocks phy_ref_clk]
foreach {domain buffer} {tx BUFG_GT_1 rx BUFG_GT_3} {
    # Match the original top-level or LiveHD-flattened buffer. CTS inverter clones
    # can share its suffix, but they are not additional clock definitions.
    set pin ${buffer}.clk_buf/Y
    set driver [get_pins -quiet [list $pin __flat_*.$pin]]
    if {[llength $driver] > 1} {
        error "Ambiguous LiteEth $domain half-clock driver: $pin"
    }
    if {[llength $driver] == 1} {
        create_generated_clock -name phy_${domain}_half_clk -source $phy_clk_port \
            -divide_by 2 $driver
        lappend phy_clocks [get_clocks phy_${domain}_half_clk]
    } elseif {$domain eq "tx"} {
        error "LiteEth transmit half-clock driver is missing"
    }
}
# Separate external oscillators feed the system and PHY CDC domains.
set_clock_groups -asynchronous -group [get_clocks $clk_name] -group $phy_clocks

set non_clock_inputs [all_inputs]
foreach clock_port [concat $clk_port $phy_clk_port] {
    set non_clock_inputs [lsearch -inline -all -not -exact $non_clock_inputs $clock_port]
}
set phy_inputs [get_ports {sgmii_rxn sgmii_rxp}]
set phy_outputs [get_ports {sgmii_txn sgmii_txp}]
foreach port $phy_inputs {
    set non_clock_inputs [lsearch -inline -all -not -exact $non_clock_inputs $port]
}
set sys_outputs [all_outputs]
foreach port $phy_outputs {
    set sys_outputs [lsearch -inline -all -not -exact $sys_outputs $port]
}

set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name $sys_outputs
# Keep the original numerical I/O budget, referenced to the PHY domain for
# PHY data pins. These are benchmark boundary assumptions, not SerDes signoff.
set_input_delay  [expr $clk_period * $clk_io_pct] -clock phy_ref_clk $phy_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock phy_ref_clk $phy_outputs
