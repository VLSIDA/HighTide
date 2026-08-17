# input_delay applied here (post-CTS) instead of in constraint.sdc because
# the need to more realistically model the interpartitional signals (that would share a clock as one die)
# calls for an input delay greater than the period. 
# While more realistic in this particular scenario, this produces poor placement and cts results unless applied post-CTS.

set clk_name nvdla_core_clk
set clk_port [get_ports $clk_name]
set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set_input_delay 1950 -clock [get_clocks $clk_name] $non_clock_inputs

# Incremental hold repair disabled, needs 18 or more hours to complete. 
# May be able to resolve remaining hold violations if allowed to run to completion.
rename repair_timing_helper repair_timing_helper_orig
proc repair_timing_helper { args } {
  repair_timing_helper_orig {*}$args -setup
}
