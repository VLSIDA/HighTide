# 2026-11 toolchain upgrade workaround (OpenROAD 687848dd): on this
# netlist `repair_clock_inverters` SEGVs inside
# rsz::Resizer::cloneClkInverter -> odb::dbNet::destroy (deterministic,
# reproducible with just load_design + repair_clock_inverters; the same
# netlist passed this step on the 2026-07 pin, and partition_a
# asap7/sky130hd pass it on the new pin). Shadow the command to a no-op
# so CTS runs; CTS then buffers the inverted clock as-is.
# See designs/src/NVDLA/DECISIONS.md (2026-11 section) for the stack.
rename repair_clock_inverters orig_repair_clock_inverters
proc repair_clock_inverters {args} {
  utl::warn FLW 9901 "repair_clock_inverters skipped: upstream SEGV workaround (DECISIONS.md 2026-11)"
}
