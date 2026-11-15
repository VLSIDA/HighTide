# Placement (GPL global + DPL detailed) — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

## Command-level knobs NOT in the env list (via GLOBAL_PLACEMENT_ARGS — appended, does not replace)

Routability-driven mode (GPL_ROUTABILITY_DRIVEN=1 by default) estimates GRT
congestion during placement and inflates cells in hot GCells — the LOCAL
density mechanism. When a logic hotspot survives the defaults, strengthen it:

- `-routability_check_overflow`: engage the routability phase earlier (while cells are still mobile)
- `-routability_inflation_ratio_coef`: inflate congested-region cells harder per round
- `-routability_max_inflation_ratio`: per-cell inflation cap (raise when a blob persists)
- `-routability_max_inflation_total`: total inflation budget
- `-routability_max_density`: how dense inflated regions may remain (lower = more spread)
- `-routability_min_congestion_for_inflation`: lower threshold = milder hotspots also spread
- `-routability_congested_nets_percentage`, `-routability_net_weight_max`: congested-net up-weighting
- `-routability_rc_coefficients`: congestion-estimate RC model

Uniform (global) spreading instead: `PLACE_DENSITY_LB_ADDON` (raises the density
lower bound suite-wide). Prefer the routability knobs for localized hotspots.

<!-- GENERATED-LIST -->
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`BALANCE_ROWS`** (default: `0`): Balance rows during placement.
- **`BUFFER_PORTS_ARGS`**: Specify arguments to the buffer_ports call during placement. Only used if DONT_BUFFER_PORTS=0.
- **`CELL_PAD_IN_SITES_DETAIL_PLACEMENT`** (default: `0`): Cell padding on both sides in site widths to ease routability in detail placement.
- **`CELL_PAD_IN_SITES_GLOBAL_PLACEMENT`** (default: `0`): Cell padding on both sides in site widths to ease routability during global placement.
- **`CLUSTER_FLOPS`** (default: `0`): Enable clustering of flip-flops into multi-bit flip-flops, if the platform PDK includes multi-bit flip-flops
- **`CLUSTER_FLOPS_ARGS`**: Additional arguments passed to the cluster_flops command. Only used when CLUSTER_FLOPS is set.
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`DETAIL_PLACEMENT_ARGS`**: Specify arguments to the detailed_placement call during placement.
- **`DONT_BUFFER_PORTS`** (default: `0`): Do not buffer input/output ports during floorplanning.
- **`EARLY_SIZING_CAP_RATIO`**: Ratio between the input pin capacitance and the output pin load during initial gate sizing.
- **`ENABLE_PLACE_REPAIR_TIMING`** (default: `0`): Run repair_timing during the placement resize stage using placement parasitics. Disabled by default; pre-CTS setup/hold repair is skipped unless this is set to 1.
- **`FLOORPLAN_DEF`**: Use the DEF file to initialize floorplan. Mutually exclusive with FOOTPRINT or DIE_AREA/CORE_AREA or CORE_UTILIZATION.
- **`GLOBAL_PLACEMENT_ARGS`**: Use additional tuning parameters during global placement other than default args defined in global_place.tcl.
- **`GPL_KEEP_OVERFLOW`**: Passed as -keep_resize_below_overflow to global_placement. Only used when GPL_TIMING_DRIVEN is enabled.
- **`GPL_RANDOM_SEED`**: Specifies a random seed for global placement. Useful for perturbation studies.
- **`GPL_ROUTABILITY_DRIVEN`** (default: `1`): Specifies whether the placer should use routability driven placement.
- **`GPL_TIMING_DRIVEN`** (default: `1`): Specifies whether the placer should use timing driven placement.
- **`IO_PLACER_H`**: A list of metal layers on which the I/O pins are placed horizontally (top and bottom of the die).
- **`IO_PLACER_V`**: A list of metal layers on which the I/O pins are placed vertically (sides of the die).
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`MATCH_CELL_FOOTPRINT`** (default: `0`): Enforce sizing operations to only swap cells that have the same layout boundary.
- **`MAX_PLACE_STEP_COEF`** (default: `1.05`): Sets the maximum phi coefficient (pcof_max / µ_k Upper Bound) for global placement optimization. This parameter controls the step size upper bound in the RePlAce Nesterov optimization algorithm. Higher values allow more aggressive optimization but may risk divergence. Valid range: 1.00-1.20
- **`MAX_REPAIR_TIMING_ITER`**: Maximum number of iterations for repair setup and repair hold.
- **`MAX_ROUTING_LAYER`**: The highest metal layer name to be used in routing.
- **`MIN_PLACE_STEP_COEF`** (default: `0.95`): Sets the minimum phi coefficient (pcof_min / µ_k Lower Bound) for global placement optimization. This parameter controls the step size lower bound in the RePlAce Nesterov optimization algorithm. Lower values may improve convergence but can increase runtime. Valid range: 0.95-1.05
- **`MIN_ROUTING_LAYER`**: The lowest metal layer name to be used in routing.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`PLACE_DENSITY`**: The desired average placement density of cells: 1.0 = dense, 0.0 = widely spread. The intended effort is also communicated by this parameter. Use a low value for faster builds and higher value for better quality of results. If a too low value is used, the placer will not be able to place all cells and a recommended minimum placement density can be found in the logs. A too high value can lead to excessive runtimes, even timeouts and subtle failures in the flow after placement, such as in CTS or global routing when timing repair fails. The default is platform specific.
- **`PLACE_DENSITY_LB_ADDON`**: Check the lower boundary of the PLACE_DENSITY and add PLACE_DENSITY_LB_ADDON if it exists.
- **`PLACE_PINS_ARGS`**: Arguments to place_pins
- **`POST_DETAIL_PLACE_TCL`**: Specifies a Tcl script with commands to run after detailed placement.
- **`POST_GLOBAL_PLACE_SKIP_IO_TCL`**: Specifies a Tcl script with commands to run after global placement (skip IO).
- **`POST_GLOBAL_PLACE_TCL`**: Specifies a Tcl script with commands to run after global placement.
- **`POST_IO_PLACEMENT_TCL`**: Specifies a Tcl script with commands to run after IO placement.
- **`POST_RESIZE_TCL`**: Specifies a Tcl script with commands to run after resize.
- **`PRE_DETAIL_PLACE_TCL`**: Specifies a Tcl script with commands to run before detailed placement.
- **`PRE_GLOBAL_PLACE_SKIP_IO_TCL`**: Specifies a Tcl script with commands to run before global placement (skip IO).
- **`PRE_GLOBAL_PLACE_TCL`**: Specifies a Tcl script with commands to run before global placement.
- **`PRE_IO_PLACEMENT_TCL`**: Specifies a Tcl script with commands to run before IO placement.
- **`PRE_RESIZE_TCL`**: Specifies a Tcl script with commands to run before resize.
- **`ROUTING_LAYER_ADJUSTMENT`** (default: `0.5`): Adjusts routing layer capacities to manage congestion and improve detailed routing. High values ease detailed routing but risk excessive detours and long global routing times, while low values reduce global routing failure but can complicate detailed routing. The global routing running time normally reduces dramatically (entirely design specific, but going from hours to minutes has been observed) when the value is low (such as 0.10). Sometimes, global routing will succeed with lower values and fail with higher values. Exploring results with different values can help shed light on the problem. Start with a too low value, such as 0.10, and bisect to value that works by doing multiple global routing runs. As a last resort, `make global_route_issue` and using the tools/OpenROAD/etc/whittle.py can be useful to debug global routing errors. If there is something specific that is impossible to route, such as a clock line over a macro, global routing will terminate with DRC errors routes that could have been routed were it not for the specific impossible routes. whittle.py should weed out the possible routes and leave a minimal failing case that pinpoints the problem.
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`TNS_END_PERCENT`** (default: `100`): Default TNS_END_PERCENT value for post CTS timing repair. Try fixing all violating endpoints by default (reduce to 5% for runtime). Specifies how many percent of violating paths to fix [0-100]. Worst path will always be fixed.
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
