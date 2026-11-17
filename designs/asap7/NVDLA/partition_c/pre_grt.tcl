# Retain the setup-repair workaround and the original CTS settings. Use
# routed parasitics for hold repair, with a guard for final extraction.
set ::env(HOLD_SLACK_MARGIN) 20
rename repair_timing_helper hightide_partition_c_repair_timing_helper
proc repair_timing_helper {args} {
  return [hightide_partition_c_repair_timing_helper -hold {*}$args]
}
