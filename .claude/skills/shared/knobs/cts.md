# Clock tree synthesis — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

## *_ARGS passthroughs (CTS)

### `CTS_ARGS` -> `clock_tree_synthesis` (OVERRIDES the ORFS-generated arguments — restate what you still need)

    clock_tree_synthesis [-wire_unit u] [-buf_list l] [-root_buf b]
       [-clk_nets nets] [-tree_buf b] [-distance_between_buffers]
       [-branching_point_buffers_distance] [-clustering_exponent]
       [-clustering_unbalance_ratio] [-sink_clustering_size]
       [-sink_clustering_max_diameter] [-macro_clustering_size]
       [-macro_clustering_max_diameter] [-sink_clustering_enable]
       [-balance_levels] [-sink_clustering_levels n] [-num_static_layers]
       [-sink_clustering_buffer] [-obstruction_aware] [-no_obstruction_aware]
       [-apply_ndr strategy] [-sink_buffer_max_cap_derate]
       [-dont_use_dummy_load] [-delay_buffer_derate] [-library]
       [-repair_clock_nets] [-no_insertion_delay] [-useful_skew]

Key levers: sink/macro clustering size+diameter (tree depth vs skew),
`-useful_skew`, `-apply_ndr` (wider/spaced clock wires), `-obstruction_aware`.
Refresh with `help clock_tree_synthesis` on the pinned openroad.

<!-- GENERATED-LIST -->
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`CELL_PAD_IN_SITES_DETAIL_PLACEMENT`** (default: `0`): Cell padding on both sides in site widths to ease routability in detail placement.
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`CTS_ARGS`**: Override `clock_tree_synthesis` arguments.
- **`CTS_BUF_DISTANCE`**: Distance (in microns) between buffers.
- **`CTS_BUF_LIST`**: List of cells used to construct the clock tree. Overrides buffer inference.
- **`CTS_CLUSTER_DIAMETER`**: Maximum diameter (in microns) of sink cluster.
- **`CTS_CLUSTER_SIZE`**: Maximum number of sinks per cluster.
- **`CTS_LIB_NAME`**: Name of the Liberty library to use in selecting the clock buffers.
- **`CTS_SNAPSHOT`**: Creates ODB/SDC files prior to clock net and setup/hold repair.
- **`CTS_SNAPSHOTS`** (default: `0`): Create ODB/SDC files at different stages of CTS.
- **`DETAILED_METRICS`** (default: `0`): If set, then calls report_metrics prior to repair operations in the CTS and global route stages
- **`HOLD_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing hold violations. This option allows you to overfix or underfix (negative value, terminate retiming before 0 or positive slack). floorplan.tcl uses min of HOLD_SLACK_MARGIN and 0 (default hold slack margin). This avoids overrepair in floorplan for hold by default, but allows skipping hold repair using a negative HOLD_SLACK_MARGIN. Exiting timing repair early is useful in exploration where the .sdc has a fixed clock period at the design's target clock period and where HOLD/SETUP_SLACK_MARGIN is used to avoid overrepair (extremely long running times) when exploring different parameter settings. When an ideal clock is used, that is before CTS, a clock insertion delay of 0 is used in timing paths. This creates a mismatch between macros that have a .lib file from after CTS, when the clock is propagated. To mitigate this, OpenSTA will use subtract the clock insertion delay of macros when calculating timing with ideal clock. Provided that min_clock_tree_path and max_clock_tree_path are in the .lib file, which is the case for macros built with OpenROAD. This is less accurate than if OpenROAD had created a placeholder clock tree for timing estimation purposes prior to CTS. There will inevitably be inaccuracies in the timing calculation prior to CTS. Use a slack margin that is low enough, even negative, to avoid overrepair. Inaccuracies in the timing prior to CTS can also lead to underrepair, but there no obvious and simple way to avoid underrapir in these cases. Overrepair can lead to excessive runtimes in repair or too much buffering being added, which can present itself as congestion of hold cells or buffer cells. Another use of SETUP/HOLD_SLACK_MARGIN is design parameter exploration when trying to find the minimum clock period for a design. The SDC_FILE for a design can be quite complicated and instead of modifying the clock period in the SDC_FILE, which can be non-trivial, the clock period can be fixed at the target frequency and the SETUP/HOLD_SLACK_MARGIN can be swept to find a plausible current minimum clock period.
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`LEC_AUX_VERILOG_FILES`**: Additional Verilog files (e.g. blackbox stubs) to include in LEC equivalence checks. Appended to the generated Verilog netlist before running the formal equivalence check.
- **`LEC_CHECK`** (default: `0`): Perform a formal equivalence check between before and after netlists. If this fails, report an issue to OpenROAD.
- **`MATCH_CELL_FOOTPRINT`** (default: `0`): Enforce sizing operations to only swap cells that have the same layout boundary.
- **`MAX_REPAIR_TIMING_ITER`**: Maximum number of iterations for repair setup and repair hold.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`POST_CTS_TCL`**: Specifies a Tcl script with commands to run after CTS is completed.
- **`PRE_CTS_TCL`**: Specifies a Tcl script with commands to run before CTS.
- **`REPORT_CLOCK_SKEW`** (default: `1`): Report clock skew as part of reporting metrics, starting at CTS, before which there is no clock skew. This metric can be quite time-consuming, so it can be useful to disable.
- **`SETUP_MOVE_SEQUENCE`**: Passed as -sequence to repair_timing. This should be a string of move keywords separated by commas.
- **`SETUP_SLACK_MARGIN`** (default: `0`): Specifies a time margin for the slack when fixing setup violations. This option allows you to overfix or underfix(negative value, terminate retiming before 0 or positive slack). See HOLD_SLACK_MARGIN for more details.
- **`SKIP_BUFFER_REMOVAL`**: Passed as -skip_buffer_removal to repair_timing. Do not remove buffers as a transform to fix timing violations (default: allow buffer removal).
- **`SKIP_CRIT_VT_SWAP`**: Do not perform VT swap on critical cells to improve QoR (default: do critical VT swap). This is an additional VT swap on critical cells that remain near the end of setup fixing. If SKIP_VT_SWAP is set to 1, this also disables critical cell VT swap.
- **`SKIP_CTS_REPAIR_TIMING`** (default: `0`): Skipping CTS repair, which can take a long time, can be useful in architectural exploration or when getting CI up and running.
- **`SKIP_GATE_CLONING`**: Do not use gate cloning transform to fix timing violations (default: use gate cloning).
- **`SKIP_LAST_GASP`**: Do not use last gasp optimization to fix timing violations (default: use gate last gasp).
- **`SKIP_PIN_SWAP`**: Do not use pin swapping as a transform to fix timing violations (default: use pin swapping).
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SKIP_VT_SWAP`**: Do not perform VT swap to improve QoR (default: do VT swap).
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`TNS_END_PERCENT`** (default: `100`): Default TNS_END_PERCENT value for post CTS timing repair. Try fixing all violating endpoints by default (reduce to 5% for runtime). Specifies how many percent of violating paths to fix [0-100]. Worst path will always be fixed.
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
