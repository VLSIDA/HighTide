current_design CoreMiniAxi

set clk_name  io_aclk
set clk_port_name io_aclk
set clk_period 31.5
# Relaxed 5% from 30 on the 2026-11 pin: synth netlist grew to ~148k cells
# (old routed total was 149k) on a design that closed with marginal setup,
# and GRT fails with congestion; less timing pressure means less repair
# buffering and less wire. (Keep the assignment above this note: ORFS's
# clock parsing takes the first matching token in the file.)
set clk_io_pct 0.2

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set non_clock_outputs [lsearch -inline -all -not -exact [all_outputs] $clk_port]

set_input_delay [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

set_false_path -from [get_ports io_aresetn]
