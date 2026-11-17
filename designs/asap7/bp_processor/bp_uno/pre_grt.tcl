# Preserve the setup-repair workaround and the original CTS settings. At
# global route, repair hold with a 20 ps guard (the observed GRT-to-final
# shift was only 2.38 ps; the original GRT hold violation was unrepaired).
set ::env(HOLD_SLACK_MARGIN) 20
rename repair_timing_helper hightide_bp_uno_repair_timing_helper
proc repair_timing_helper {args} {
  return [hightide_bp_uno_repair_timing_helper -hold {*}$args]
}
