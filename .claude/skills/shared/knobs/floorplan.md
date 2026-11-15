# Floorplan (init_floorplan, macro placement/RTLMP, PDN, IO) — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

## Command-level knobs NOT in the env list (via RTLMP_ARGS — replaces the WHOLE generated arg list; always re-include -target_util = PLACE_DENSITY[+addon])

- `-halo_width W` / `-halo_height H`: keep-out halo around each macro (um)
- `-min_channel_size C`: minimum spacing between macro clusters (um)
- `-pin_aware_channels`: size channels for macro pin-edge escape demand
- `-tolerance`, `-coarsening_ratio`, `-large_net_threshold`: annealing/clustering tuning
- `-guidance_weight`, `-fence_weight`, `-macro_blockage_weight`, `-soft_blockage_weight`: cost weights
- `-write_macro_placement FILE`: dump the annealed result as place_macro commands (bridge to a frozen MACRO_PLACEMENT_TCL grid)

TRAP (verified 2026-11-15): `RTLMP_MIN_CHANNEL_SIZE` / `RTLMP_PIN_AWARE_CHANNELS`
are NOT plumbed on this pin — silent no-ops. Channel/halo control is RTLMP_ARGS-only.
Even `MACRO_PLACE_HALO` only feeds the blockage file here, not the placer.
Strategy, recipes and the fixed-grid workflow: optimize-ppa skill, macro-placement section.

<!-- GENERATED-LIST -->
- **`ADDITIONAL_SITES`**: Passed as -additional_sites to initialize_floorplan.
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`CELL_PAD_IN_SITES_GLOBAL_PLACEMENT`** (default: `0`): Cell padding on both sides in site widths to ease routability during global placement.
- **`CORE_AREA`**: The core area specified as a list of lower-left and upper-right corners in microns (X1 Y1 X2 Y2).
- **`CORE_ASPECT_RATIO`** (default: `1.0`): The core aspect ratio (height / width). This variable is only used when `CORE_UTILIZATION` is set.
- **`CORE_MARGIN`** (default: `1.0`): The margin between the core area and die area, specified in microns. Allowed values are either one value for all margins or a set of four values, one for each margin. The order of the four values are: `{bottom top left right}`. This variable is only used when `CORE_UTILIZATION` is set.
- **`CORE_UTILIZATION`**: The core utilization percentage (0-100).
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`DIE_AREA`**: The die area specified as a list of lower-left and upper-right corners in microns (X1 Y1 X2 Y2).
- **`FLOORPLAN_DEF`**: Use the DEF file to initialize floorplan. Mutually exclusive with FOOTPRINT or DIE_AREA/CORE_AREA or CORE_UTILIZATION.
- **`FOOTPRINT`**: Custom footprint definition file for ICeWall-based floorplan initialization. Mutually exclusive with FLOORPLAN_DEF or DIE_AREA/CORE_AREA or CORE_UTILIZATION.
- **`FOOTPRINT_TCL`**: Specifies a Tcl script with custom footprint-related commands for floorplan setup.
- **`HOLD_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing hold violations. This option allows you to overfix or underfix (negative value, terminate retiming before 0 or positive slack). floorplan.tcl uses min of HOLD_SLACK_MARGIN and 0 (default hold slack margin). This avoids overrepair in floorplan for hold by default, but allows skipping hold repair using a negative HOLD_SLACK_MARGIN. Exiting timing repair early is useful in exploration where the .sdc has a fixed clock period at the design's target clock period and where HOLD/SETUP_SLACK_MARGIN is used to avoid overrepair (extremely long running times) when exploring different parameter settings. When an ideal clock is used, that is before CTS, a clock insertion delay of 0 is used in timing paths. This creates a mismatch between macros that have a .lib file from after CTS, when the clock is propagated. To mitigate this, OpenSTA will use subtract the clock insertion delay of macros when calculating timing with ideal clock. Provided that min_clock_tree_path and max_clock_tree_path are in the .lib file, which is the case for macros built with OpenROAD. This is less accurate than if OpenROAD had created a placeholder clock tree for timing estimation purposes prior to CTS. There will inevitably be inaccuracies in the timing calculation prior to CTS. Use a slack margin that is low enough, even negative, to avoid overrepair. Inaccuracies in the timing prior to CTS can also lead to underrepair, but there no obvious and simple way to avoid underrapir in these cases. Overrepair can lead to excessive runtimes in repair or too much buffering being added, which can present itself as congestion of hold cells or buffer cells. Another use of SETUP/HOLD_SLACK_MARGIN is design parameter exploration when trying to find the minimum clock period for a design. The SDC_FILE for a design can be quite complicated and instead of modifying the clock period in the SDC_FILE, which can be non-trivial, the clock period can be fixed at the target frequency and the SETUP/HOLD_SLACK_MARGIN can be swept to find a plausible current minimum clock period.
- **`IO_CONSTRAINTS`**: File path to the IO constraints .tcl file. Also used for manual placement.
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`MACRO_BLOCKAGE_HALO`**: Distance beyond the edges of a macro that will also be covered by the blockage generated for that macro. Note that the default macro blockage halo comes from the largest of the specified MACRO_PLACE_HALO x or y values. This variable overrides that calculation.
- **`MACRO_PLACEMENT_TCL`**: Specifies the path of a TCL file on how to place macros manually. The user may choose to place just some of the macros in the design. The macro placer will handle the remaining unplaced macros.
- **`MACRO_PLACE_HALO`**: Horizontal/vertical halo around macros (microns). Used by automatic macro placement.
- **`MACRO_ROWS_HALO_X`**: Horizontal distance between the edge of the macro and the beginning of the rows created by tapcell. Only available for ASAP7 PDK and GF180/uart-blocks design.
- **`MACRO_ROWS_HALO_Y`**: Vertical distance between the edge of the macro and the beginning of the rows created by tapcell. Only available for ASAP7 PDK and GF180/uart-blocks design.
- **`MACRO_WRAPPERS`**: The wrapper file that replaces existing macros with their wrapped version.
- **`MAKE_TRACKS`**: Tcl file that defines add routing tracks to a floorplan.
- **`MATCH_CELL_FOOTPRINT`** (default: `0`): Enforce sizing operations to only swap cells that have the same layout boundary.
- **`MAX_REPAIR_TIMING_ITER`**: Maximum number of iterations for repair setup and repair hold.
- **`MAX_ROUTING_LAYER`**: The highest metal layer name to be used in routing.
- **`MIN_ROUTING_LAYER`**: The lowest metal layer name to be used in routing.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`PDN_TCL`**: File path which has a set of power grid policies used by pdn to be applied to the design, such as layers to use, stripe width and spacing to generate the actual metal straps.
- **`PLACE_DENSITY`**: The desired average placement density of cells: 1.0 = dense, 0.0 = widely spread. The intended effort is also communicated by this parameter. Use a low value for faster builds and higher value for better quality of results. If a too low value is used, the placer will not be able to place all cells and a recommended minimum placement density can be found in the logs. A too high value can lead to excessive runtimes, even timeouts and subtle failures in the flow after placement, such as in CTS or global routing when timing repair fails. The default is platform specific.
- **`PLACE_DENSITY_LB_ADDON`**: Check the lower boundary of the PLACE_DENSITY and add PLACE_DENSITY_LB_ADDON if it exists.
- **`PLACE_SITE`**: Placement site for core cells defined in the technology LEF file.
- **`POST_FLOORPLAN_TCL`**: Specifies a Tcl script with commands to run after floorplan is completed.
- **`POST_MACRO_PLACE_TCL`**: Specifies a Tcl script with commands to run after macro placement.
- **`POST_PDN_TCL`**: Specifies a Tcl script with commands to run after PDN generation.
- **`POST_TAPCELL_TCL`**: Specifies a Tcl script with commands to run after tapcell.
- **`PRE_FLOORPLAN_TCL`**: Specifies a Tcl script with commands to run before floorplan.
- **`PRE_MACRO_PLACE_TCL`**: Specifies a Tcl script with commands to run before macro placement.
- **`PRE_PDN_TCL`**: Specifies a Tcl script with commands to run before PDN generation.
- **`PRE_TAPCELL_TCL`**: Specifies a Tcl script with commands to run before tapcell.
- **`REMOVE_ABC_BUFFERS`** (default: `0`): Remove abc buffers from the netlist. If timing repair in floorplanning is taking too long, use a SETUP/HOLD_SLACK_MARGIN to terminate timing repair early instead of using REMOVE_ABC_BUFFERS or set SKIP_LAST_GASP=1.
- **`ROUTING_LAYER_ADJUSTMENT`** (default: `0.5`): Adjusts routing layer capacities to manage congestion and improve detailed routing. High values ease detailed routing but risk excessive detours and long global routing times, while low values reduce global routing failure but can complicate detailed routing. The global routing running time normally reduces dramatically (entirely design specific, but going from hours to minutes has been observed) when the value is low (such as 0.10). Sometimes, global routing will succeed with lower values and fail with higher values. Exploring results with different values can help shed light on the problem. Start with a too low value, such as 0.10, and bisect to value that works by doing multiple global routing runs. As a last resort, `make global_route_issue` and using the tools/OpenROAD/etc/whittle.py can be useful to debug global routing errors. If there is something specific that is impossible to route, such as a clock line over a macro, global routing will terminate with DRC errors routes that could have been routed were it not for the specific impossible routes. whittle.py should weed out the possible routes and leave a minimal failing case that pinpoints the problem.
- **`RTLMP_AREA_WT`** (default: `0.1`): Weight for the area of the current floorplan.
- **`RTLMP_ARGS`**: Overrides all other RTL macro placer arguments.
- **`RTLMP_BOUNDARY_WT`** (default: `50.0`): Weight for the boundary or how far the hard macro clusters are from boundaries.
- **`RTLMP_FENCE_LX`** (default: `0.0`): Defines the lower left X coordinate for the global fence bounding box in microns.
- **`RTLMP_FENCE_LY`** (default: `0.0`): Defines the lower left Y coordinate for the global fence bounding box in microns.
- **`RTLMP_FENCE_UX`** (default: `0.0`): Defines the upper right X coordinate for the global fence bounding box in microns.
- **`RTLMP_FENCE_UY`** (default: `0.0`): Defines the upper right Y coordinate for the global fence bounding box in microns.
- **`RTLMP_MAX_INST`**: Maximum number of standard cells in a cluster. If unset, rtl_macro_placer will calculate a value based on the design attributes.
- **`RTLMP_MAX_LEVEL`** (default: `2`): Maximum depth of the physical hierarchy tree.
- **`RTLMP_MAX_MACRO`**: Maximum number of macros in a cluster. If unset, rtl_macro_placer will calculate a value based on the design attributes.
- **`RTLMP_MIN_AR`** (default: `0.33`): Specifies the minimum aspect ratio (height/width).
- **`RTLMP_MIN_INST`**: Minimum number of standard cells in a cluster. If unset, rtl_macro_placer will calculate a value based on the design attributes.
- **`RTLMP_MIN_MACRO`**: Minimum number of macros in a cluster. If unset, rtl_macro_placer will calculate a value based on the design attributes.
- **`RTLMP_NOTCH_WT`** (default: `50.0`): Weight for the notch, or the existence of dead space that cannot be used for placement and routing.
- **`RTLMP_OUTLINE_WT`** (default: `100.0`): Weight for violating the fixed outline constraint, meaning that all clusters should be placed within the shape of their parent cluster.
- **`RTLMP_RPT_DIR`**: Path to the directory where reports are saved.
- **`RTLMP_WIRELENGTH_WT`** (default: `100.0`): Weight for half-perimiter wirelength.
- **`SETUP_MOVE_SEQUENCE`**: Passed as -sequence to repair_timing. This should be a string of move keywords separated by commas.
- **`SETUP_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing setup violations. This option allows you to overfix or underfix(negative value, terminate retiming before 0 or positive slack). See HOLD_SLACK_MARGIN for more details.
- **`SKIP_BUFFER_REMOVAL`**: Passed as -skip_buffer_removal to repair_timing. Do not remove buffers as a transform to fix timing violations (default: allow buffer removal).
- **`SKIP_CRIT_VT_SWAP`**: Do not perform VT swap on critical cells to improve QoR (default: do critical VT swap). This is an additional VT swap on critical cells that remain near the end of setup fixing. If SKIP_VT_SWAP is set to 1, this also disables critical cell VT swap.
- **`SKIP_GATE_CLONING`**: Do not use gate cloning transform to fix timing violations (default: use gate cloning).
- **`SKIP_LAST_GASP`**: Do not use last gasp optimization to fix timing violations (default: use gate last gasp).
- **`SKIP_PIN_SWAP`**: Do not use pin swapping as a transform to fix timing violations (default: use pin swapping).
- **`SKIP_REPAIR_TIE_FANOUT`** (default: `0`): Skip repair_tie_fanout at floorplan step.
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SKIP_VT_SWAP`**: Do not perform VT swap to improve QoR (default: do VT swap).
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`TAPCELL_TCL`**: Path to Endcap and Welltie cells file.
- **`TIEHI_CELL_AND_PORT`**: Tie high cells used in Yosys synthesis to replace a logical 1 in the Netlist.
- **`TIELO_CELL_AND_PORT`**: Tie low cells used in Yosys synthesis to replace a logical 0 in the Netlist.
- **`TIE_SEPARATION`** (default: `0`): Distance separating tie high/low instances from the load.
- **`TNS_END_PERCENT`** (default: `100`): Default TNS_END_PERCENT value for post CTS timing repair. Try fixing all violating endpoints by default (reduce to 5% for runtime). Specifies how many percent of violating paths to fix [0-100]. Worst path will always be fixed.
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
