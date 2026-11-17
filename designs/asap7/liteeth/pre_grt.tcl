# Keep the setup-repair workaround while repairing hold with global-route
# parasitics. CTS placement estimates caused excessive delay buffering and
# final setup regressions in the baseline audit. The normal incremental
# global-route flow legalizes and reroutes the inserted cells.
rename repair_timing_helper hightide_liteeth_repair_timing_helper
proc repair_timing_helper {args} {
  return [hightide_liteeth_repair_timing_helper -hold {*}$args]
}
