source $::env(SCRIPTS_DIR)/load.tcl
source_env_var_if_exists PLATFORM_TCL
source $::env(SCRIPTS_DIR)/read_liberty.tcl
read_db $::env(OUTPUT)/control.odb
set_cmd_units -time ps -capacitance fF -resistance kOhm -power mW -distance um
read_sdc $::env(SDC_FILE)
source $::env(SET_RC_TCL)
set_dont_use $::env(DONT_USE_CELLS)
estimate_parasitics -placement
set t [clock milliseconds]
repair_design_helper
set repair_ms [expr {[clock milliseconds]-$t}]
set t [clock milliseconds]
set_placement_padding -global -left 0 -right 0
detailed_placement
optimize_mirroring
check_placement -verbose
set legal_ms [expr {[clock milliseconds]-$t}]
write_def $::env(OUTPUT)/control_repaired.def
write_db $::env(OUTPUT)/control_repaired.odb
set f [open $::env(OUTPUT)/control_repair_runtime.json w]
puts $f "{\"repair_s\":[expr {$repair_ms/1000.0}],\"legalize_mirror_s\":[expr {$legal_ms/1000.0}]}"
close $f
