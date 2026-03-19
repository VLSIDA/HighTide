current_design Vortex

set clk_name clk
set clk_port_name clk
set clk_period 1100
set clk_io_pct 0.1

set clk_port [get_ports $clk_name]

create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]

set_input_delay [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]

set_false_path -from [get_ports reset]
set_false_path -from [get_ports dcr_wr_valid]
set_false_path -from [get_ports dcr_wr_addr]
set_false_path -from [get_ports dcr_wr_data]

# ── Fanout limiting ────────────────────────────────────────────────────────
# DESIGN-WIDE max fanout.  Without this, only clk/reset were constrained
# and synthesis was free to leave internal nets with 400+ sinks unbuffered.
# This forces synthesis (ABC) and repair_design to insert buffer trees on
# high-fanout decoded signals in the commit arbiter, cache banks, etc.
set_max_fanout 32 [current_design]

set non_clock_inputs [all_inputs -no_clocks]
set_input_delay 10 -clock $clk_name $non_clock_inputs
set_output_delay 10 -clock $clk_name [all_outputs]

set_driving_cell -lib_cell DFFHQNx2_ASAP7_75t_R -pin QN $non_clock_inputs
set_load [expr 4.0 * 0.683716] [all_outputs]