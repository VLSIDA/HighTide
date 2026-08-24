# Overrides constraint.sdc's blanket clk_io_pct input delay: the interpartitional signals
# (that would share a clock as one die) need a more realistic delay that exceeds the clock
# period, which produces poor placement and CTS results unless applied post-CTS instead.

set clk_name nvdla_core_clk
set clk_port [get_ports $clk_name]
set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set_input_delay 1950 -clock [get_clocks $clk_name] $non_clock_inputs

# Incremental hold repair disabled, needs 18 or more hours to complete.
# May be able to resolve remaining hold violations if allowed to run to completion.
# Proc override (not SKIP_INCREMENTAL_REPAIR) because we want setup repair to still
# run here, just not hold -- SKIP_INCREMENTAL_REPAIR would drop both.
# Guarded: PRE GLOBAL_ROUTE can be sourced more than once per process.
if {[info procs repair_timing_helper_orig] eq {}} {
  rename repair_timing_helper repair_timing_helper_orig
  proc repair_timing_helper { args } {
    repair_timing_helper_orig {*}$args -setup
  }
}
