source $::env(SCRIPTS_DIR)/load.tcl
source_env_var_if_exists PLATFORM_TCL
source $::env(SCRIPTS_DIR)/read_liberty.tcl
read_lef $::env(TECH_LEF)
read_lef $::env(SC_LEF)
foreach lef $::env(ADDITIONAL_LEFS) {read_lef $lef}
read_def $::env(OUTPUT)/input.def
set_cmd_units -time ps -capacitance fF -resistance kOhm -power mW -distance um
read_sdc $::env(SDC_FILE)
source $::env(SET_RC_TCL)
set_dont_use $::env(DONT_USE_CELLS)
# All resizer changes remain virtual; this isolates placement on an unchanged
# netlist. Port buffering and remove_buffers are intentionally not invoked.
set t [clock milliseconds]
global_placement -density 0.5 -routability_driven -timing_driven -keep_resize_below_overflow 0 -force_center_initial_place -min_phi_coef 0.95 -max_phi_coef 1.05 -pad_left 0 -pad_right 0
set gp_ms [expr {[clock milliseconds]-$t}]
write_def $::env(OUTPUT)/control_gp.def
set t [clock milliseconds]
set_placement_padding -global -left 0 -right 0
detailed_placement
optimize_mirroring
check_placement -verbose
set lg_ms [expr {[clock milliseconds]-$t}]
write_def $::env(OUTPUT)/control.def
write_db $::env(OUTPUT)/control.odb
set f [open $::env(OUTPUT)/control_runtime.json w]
puts $f "{\"gp_s\":[expr {$gp_ms/1000.0}],\"legalize_mirror_s\":[expr {$lg_ms/1000.0}]}"
close $f
