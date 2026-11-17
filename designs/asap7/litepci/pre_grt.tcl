# Repair the measured register-to-memory hold paths with routed parasitics,
# retaining the workaround for non-converging forwarded-clock setup repair.
# No clock, I/O delay or timing exceptions are changed here.
rename repair_timing_helper hightide_litepci_repair_timing_helper
proc repair_timing_helper {args} {
  return [hightide_litepci_repair_timing_helper -hold {*}$args]
}
