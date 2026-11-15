# Global routing (+ post-GRT repair) — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

<!-- GENERATED-LIST -->
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`CELL_PAD_IN_SITES_DETAIL_PLACEMENT`** (default: `0`): Cell padding on both sides in site widths to ease routability in detail placement.
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`DETAILED_METRICS`** (default: `0`): If set, then calls report_metrics prior to repair operations in the CTS and global route stages
- **`ENABLE_RESISTANCE_AWARE`**: Passed as -resistance_aware to global_route.
- **`GLOBAL_ROUTE_ARGS`** (default: `-congestion_report_iter_step 5 -verbose`): Replaces default arguments for global route. The -congestion_iterations default is set by the flow (30 for FastRoute, 10 for CUGR); add -congestion_iterations here to override it.
- **`GLOBAL_ROUTE_USE_CUGR`** (default: `0`): Passed as -use_cugr to global_route. Uses CUGR as the global routing solver instead of the default FastRoute solver. NOTE: CUGR is not ready for production.
- **`HOLD_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing hold violations. This option allows you to overfix or underfix (negative value, terminate retiming before 0 or positive slack). floorplan.tcl uses min of HOLD_SLACK_MARGIN and 0 (default hold slack margin). This avoids overrepair in floorplan for hold by default, but allows skipping hold repair using a negative HOLD_SLACK_MARGIN. Exiting timing repair early is useful in exploration where the .sdc has a fixed clock period at the design's target clock period and where HOLD/SETUP_SLACK_MARGIN is used to avoid overrepair (extremely long running times) when exploring different parameter settings. When an ideal clock is used, that is before CTS, a clock insertion delay of 0 is used in timing paths. This creates a mismatch between macros that have a .lib file from after CTS, when the clock is propagated. To mitigate this, OpenSTA will use subtract the clock insertion delay of macros when calculating timing with ideal clock. Provided that min_clock_tree_path and max_clock_tree_path are in the .lib file, which is the case for macros built with OpenROAD. This is less accurate than if OpenROAD had created a placeholder clock tree for timing estimation purposes prior to CTS. There will inevitably be inaccuracies in the timing calculation prior to CTS. Use a slack margin that is low enough, even negative, to avoid overrepair. Inaccuracies in the timing prior to CTS can also lead to underrepair, but there no obvious and simple way to avoid underrapir in these cases. Overrepair can lead to excessive runtimes in repair or too much buffering being added, which can present itself as congestion of hold cells or buffer cells. Another use of SETUP/HOLD_SLACK_MARGIN is design parameter exploration when trying to find the minimum clock period for a design. The SDC_FILE for a design can be quite complicated and instead of modifying the clock period in the SDC_FILE, which can be non-trivial, the clock period can be fixed at the target frequency and the SETUP/HOLD_SLACK_MARGIN can be swept to find a plausible current minimum clock period.
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`MAX_REPAIR_ANTENNAS_ITER_GRT`** (default: `5`): Defines the maximum number of iterations post global routing repair antennas will run.
- **`MAX_REPAIR_TIMING_ITER`**: Maximum number of iterations for repair setup and repair hold.
- **`MAX_ROUTING_LAYER`**: The highest metal layer name to be used in routing.
- **`MIN_ROUTING_LAYER`**: The lowest metal layer name to be used in routing.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`POST_GLOBAL_ROUTE_TCL`**: Specifies a Tcl script with commands to run after global route.
- **`PRE_GLOBAL_ROUTE_TCL`**: Specifies a Tcl script with commands to run before global route.
- **`REPORT_CLOCK_SKEW`** (default: `1`): Report clock skew as part of reporting metrics, starting at CTS, before which there is no clock skew. This metric can be quite time-consuming, so it can be useful to disable.
- **`ROUTING_LAYER_ADJUSTMENT`** (default: `0.5`): Adjusts routing layer capacities to manage congestion and improve detailed routing. High values ease detailed routing but risk excessive detours and long global routing times, while low values reduce global routing failure but can complicate detailed routing. The global routing running time normally reduces dramatically (entirely design specific, but going from hours to minutes has been observed) when the value is low (such as 0.10). Sometimes, global routing will succeed with lower values and fail with higher values. Exploring results with different values can help shed light on the problem. Start with a too low value, such as 0.10, and bisect to value that works by doing multiple global routing runs. As a last resort, `make global_route_issue` and using the tools/OpenROAD/etc/whittle.py can be useful to debug global routing errors. If there is something specific that is impossible to route, such as a clock line over a macro, global routing will terminate with DRC errors routes that could have been routed were it not for the specific impossible routes. whittle.py should weed out the possible routes and leave a minimal failing case that pinpoints the problem.
- **`SETUP_MOVE_SEQUENCE`**: Passed as -sequence to repair_timing. This should be a string of move keywords separated by commas.
- **`SETUP_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing setup violations. This option allows you to overfix or underfix(negative value, terminate retiming before 0 or positive slack). See HOLD_SLACK_MARGIN for more details.
- **`SKIP_ANTENNA_REPAIR`** (default: `0`): Skips antenna repair entirely.
- **`SKIP_ANTENNA_REPAIR_PRE_GRT`** (default: `0`): Skips antenna repair pre-global routing.
- **`SKIP_BUFFER_REMOVAL`**: Passed as -skip_buffer_removal to repair_timing. Do not remove buffers as a transform to fix timing violations (default: allow buffer removal).
- **`SKIP_CRIT_VT_SWAP`**: Do not perform VT swap on critical cells to improve QoR (default: do critical VT swap). This is an additional VT swap on critical cells that remain near the end of setup fixing. If SKIP_VT_SWAP is set to 1, this also disables critical cell VT swap.
- **`SKIP_GATE_CLONING`**: Do not use gate cloning transform to fix timing violations (default: use gate cloning).
- **`SKIP_INCREMENTAL_REPAIR`** (default: `0`): Skip incremental repair in global route.
- **`SKIP_LAST_GASP`**: Do not use last gasp optimization to fix timing violations (default: use gate last gasp).
- **`SKIP_PIN_SWAP`**: Do not use pin swapping as a transform to fix timing violations (default: use pin swapping).
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SKIP_VT_SWAP`**: Do not perform VT swap to improve QoR (default: do VT swap).
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`TNS_END_PERCENT`** (default: `100`): Default TNS_END_PERCENT value for post CTS timing repair. Try fixing all violating endpoints by default (reduce to 5% for runtime). Specifies how many percent of violating paths to fix [0-100]. Worst path will always be fixed.
- **`VIA_IN_PIN_MAX_LAYER`**: Passed as -via_in_pin_top_layer to pin_access and detailed_route.
- **`VIA_IN_PIN_MIN_LAYER`**: Passed as -via_in_pin_bottom_layer to pin_access and detailed_route.
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
