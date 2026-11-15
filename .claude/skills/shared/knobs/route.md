# Detailed routing (+ antenna repair) — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

## *_ARGS passthroughs (detailed route)

### `DETAILED_ROUTE_ARGS` -> `detailed_route` (appended; mostly debug/limits)

    detailed_route [-output_maze f] [-output_drc f] [-output_guide_coverage f]
       [-drc_report_iter_step s] [-db_process_node name] [-disable_via_gen]
       [-droute_end_iter iter] [-via_in_pin_bottom_layer l]
       [-via_in_pin_top_layer l] [-via_access_layer l] [-or_seed s] [-or_k k]
       [-bottom_routing_layer l] [-top_routing_layer l] [-verbose level]
       [-distributed ...] [-clean_patches] [-no_pin_access]
       [-min_access_points n] [-save_guide_updates] [-repair_pdn_vias l]
       [-single_step_dr]

Key levers: `-droute_end_iter` (cap DRT iterations on divergent designs),
`-output_drc` + `-drc_report_iter_step` (watch violation trajectory).
Refresh with `help detailed_route` on the pinned openroad.

<!-- GENERATED-LIST -->
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`DETAILED_ROUTE_ARGS`**: Add additional arguments for debugging purposes during detail route.
- **`DETAILED_ROUTE_END_ITERATION`** (default: `64`): Maximum number of iterations.
- **`DISABLE_VIA_GEN`**: Passed as -disable_via_gen to detailed_route.
- **`FILL_CELLS`**: Fill cells are used to fill empty sites. If not set or empty, fill cell insertion is skipped.
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`MATCH_CELL_FOOTPRINT`** (default: `0`): Enforce sizing operations to only swap cells that have the same layout boundary.
- **`MAX_REPAIR_ANTENNAS_ITER_DRT`** (default: `5`): Defines the maximum number of iterations post-detailed routing repair antennas will run.
- **`MAX_ROUTING_LAYER`**: The highest metal layer name to be used in routing.
- **`MIN_ROUTING_LAYER`**: The lowest metal layer name to be used in routing.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`OR_K`**: Passed as -or_k to detailed routing.
- **`OR_SEED`**: Passed as -or_seed to detailed routing.
- **`POST_DETAIL_ROUTE_TCL`**: Specifies a Tcl script with commands to run after detailed route.
- **`POST_FILLCELL_TCL`**: Specifies a Tcl script with commands to run after fillcell insertion.
- **`PRE_DETAIL_ROUTE_TCL`**: Specifies a Tcl script with commands to run before detailed route.
- **`PRE_FILLCELL_TCL`**: Specifies a Tcl script with commands to run before fillcell insertion.
- **`REPORT_CLOCK_SKEW`** (default: `1`): Report clock skew as part of reporting metrics, starting at CTS, before which there is no clock skew. This metric can be quite time-consuming, so it can be useful to disable.
- **`ROUTING_LAYER_ADJUSTMENT`** (default: `0.5`): Adjusts routing layer capacities to manage congestion and improve detailed routing. High values ease detailed routing but risk excessive detours and long global routing times, while low values reduce global routing failure but can complicate detailed routing. The global routing running time normally reduces dramatically (entirely design specific, but going from hours to minutes has been observed) when the value is low (such as 0.10). Sometimes, global routing will succeed with lower values and fail with higher values. Exploring results with different values can help shed light on the problem. Start with a too low value, such as 0.10, and bisect to value that works by doing multiple global routing runs. As a last resort, `make global_route_issue` and using the tools/OpenROAD/etc/whittle.py can be useful to debug global routing errors. If there is something specific that is impossible to route, such as a clock line over a macro, global routing will terminate with DRC errors routes that could have been routed were it not for the specific impossible routes. whittle.py should weed out the possible routes and leave a minimal failing case that pinpoints the problem.
- **`SKIP_ANTENNA_REPAIR_POST_DRT`** (default: `0`): Skips antenna repair post-detailed routing.
- **`SKIP_DETAILED_ROUTE`** (default: `0`): Skips detailed route.
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`VIA_IN_PIN_MAX_LAYER`**: Passed as -via_in_pin_top_layer to pin_access and detailed_route.
- **`VIA_IN_PIN_MIN_LAYER`**: Passed as -via_in_pin_bottom_layer to pin_access and detailed_route.
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
