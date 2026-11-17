current_design NyuziProcessor

set clk_period 2841
set clk_io_pct 0.2

create_clock -name clk -period $clk_period [get_ports clk]

set_input_delay  [expr $clk_period * $clk_io_pct] -clock clk [all_inputs -no_clocks]
set_output_delay [expr $clk_period * $clk_io_pct] -clock clk [all_outputs]

set_false_path -from [get_ports reset]

# m_aclk forwards the CPU clock to the external AXI interface.
# Model it as a clock network, preserving the CPU period and all data delays.
create_generated_clock -name m_aclk_fwd -source [get_ports clk] \
    -divide_by 1 [get_ports m_aclk]

# The upstream TAP samples these asynchronous JTAG inputs through a three-stage
# synchronizer. Exclude only the external-input-to-first-stage checks. Raw TDI
# also feeds debug shift registers; those paths and later sync stages stay timed.
foreach {hightide_jtag_port hightide_jtag_bit} {
    jtag_tck 3 jtag_tms 2 jtag_tdi 1 jtag_trst_n 0
} {
    set hightide_jtag_pin [get_pins -hierarchical -regexp [format \
        {^u_nyuzi\.on_chip_debugger\.jtag_tap_controller\.synchronizer\.sync0\[%d\]\$_DFF_PP0_/D$} \
        $hightide_jtag_bit]]
    if {[llength $hightide_jtag_pin] != 1} {
        error "Expected one first-stage synchronizer pin for $hightide_jtag_port"
    }
    set_false_path -from [get_ports $hightide_jtag_port] -to $hightide_jtag_pin
}
unset hightide_jtag_port hightide_jtag_bit hightide_jtag_pin
