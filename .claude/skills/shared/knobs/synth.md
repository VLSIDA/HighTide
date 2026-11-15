# Synthesis (yosys/abc) — ORFS knobs

<!-- GENERATED from ORFS variables.json (pin: ORFS 3f8ab4eb / 2026-11 toolchain).
     Regenerate on each toolchain bump:
       python3 .claude/skills/shared/knobs/generate.py <output_base>/external/orfs+/flow/scripts/variables.json
     Hand-curated sections above the marker are preserved by the generator. -->

Set these in `hightide_design(arguments = {...})`. Unknown/misspelled vars are SILENT NO-OPS — verify against this list.

<!-- GENERATED-LIST -->
- **`ABC_AREA`** (default: `0`): Strategies for Yosys ABC synthesis: Area/Speed. Default ABC_SPEED.
- **`ABC_CLOCK_PERIOD_IN_PS`**: Clock period to be used by STA during synthesis. Default value read from `constraint.sdc`.
- **`ABC_DRIVER_CELL`**: Default driver cell used during ABC synthesis.
- **`ABC_LOAD_IN_FF`**: During synthesis set_load value used.
- **`ADDER_MAP_FILE`**: Optional mapping file supplied to Yosys to map adders
- **`ASAP7_USE_VT`** (default: `RVT`): A space separated list of VT options to use with the ASAP7 standard cell library: RVT, LVT, SLVT.
- **`CACHED_REPORTS`**: List of pre-existing report files to copy into the reports directory before synthesis. Used when reusing prior synthesis results with SYNTH_NETLIST_FILES.
- **`CLKGATE_MAP_FILE`**: Optional mapping file supplied to Yosys to map clock gating cells
- **`CORNERS`**: List of timing corner names for multi-corner analysis (e.g. "slow fast"). When set, liberty files are loaded per corner using uppercase <CORNER>_LIB_FILES environment variables (e.g. corner "slow" reads SLOW_LIB_FILES) and timing models are generated per corner.
- **`DFF_LIB_FILE`**: Single Liberty file for flip-flop technology mapping (dfflibmap) during synthesis. Takes precedence over DFF_MAP_FILE when set.
- **`DFF_MAP_FILE`**: Optional mapping file supplied to Yosys to map D flip-flops
- **`KEEP_VARS`** (default: `0`): Feature toggle to keep intermediate variables during the flow. This is useful for the single-run flow, where all stages of the flow are run in a single OpenROAD instance.
- **`LATCH_MAP_FILE`**: Optional mapping file supplied to Yosys to map latches
- **`MIN_BUF_CELL_AND_PORTS`**: Used to insert a buffer cell to pass through wires. Used in synthesis.
- **`NUM_CORES`**: Passed to `openroad -threads $(NUM_CORES)`, defaults to numbers of cores in system as determined by system specific code in Makefile, `nproc` is tried first. OpenROAD does not limit itself to this number of cores across OpenROAD running instances, which can lead to overprovisioning in contexts such as bazel-orfs where there could be many routing, or place jobs running at the same time.
- **`OPENROAD_HIERARCHICAL`** (default: `0`): Feature toggle to enable to run OpenROAD in hierarchical mode, otherwise considered flat. Will eventually be the default and this option will be retired.
- **`POST_SYNTH_TCL`**: Specifies a Tcl script with commands to run after synthesis ODB generation.
- **`PRE_SYNTH_TCL`**: Specifies a Tcl script with commands to run before synthesis ODB generation.
- **`SDC_FILE`**: The path to design constraint (SDC) file.
- **`SDC_GUT`**: Load design and remove all internal logic before doing synthesis. This is useful when creating a mock .lef abstract that has a smaller area than the amount of logic would allow. bazel-orfs uses this to mock SRAMs, for instance.
- **`SKIP_REPORT_METRICS`** (default: `0`): If set to 1, then metrics, report_metrics does nothing. Useful to speed up builds.
- **`SLANG_PLUGIN_PATH`** (default: `slang`): Path to the slang plugin for Yosys. This can be a full path to a custom-built plugin (e.g. for Bazel builds) or just the plugin name.
- **`SWAP_ARITH_OPERATORS`**: Improve timing QoR by swapping ALU and MULT arithmetic operators.
- **`SYNTH_ARGS`**: Optional synthesis variables for yosys.
- **`SYNTH_BLACKBOXES`**: List of cells treated as a black box by Yosys. With Bazel, this can be used to run synthesis in parallel for the large modules of the design. Non-existant modules are ignored silently, useful when listing modules statically, even if modules come and go dynamically.
- **`SYNTH_CANONICALIZE_TCL`**: Specifies a Tcl script with commands to run as part of the synth canonicalize step.
- **`SYNTH_CHECKPOINT`**: Path to a Yosys RTLIL checkpoint to read in place of the default canonicalization checkpoint at the start of synth.tcl. Intended for parallel synthesis flows that reuse a checkpoint taken after coarse synthesis and `keep_hierarchy` have already been decided, so each partition skips that common prefix. Leave unset for the normal flow.
- **`SYNTH_GUT`** (default: `0`): Load design and remove all internal logic before doing synthesis. This is useful when creating a mock .lef abstract that has a smaller area than the amount of logic would allow. bazel-orfs uses this to mock SRAMs, for instance.
- **`SYNTH_HDL_FRONTEND`**: Select an alternative language frontend to ingest the design. Available option is "slang". If the variable is empty, design is read with the Yosys read_verilog command.
- **`SYNTH_HIERARCHICAL`** (default: `0`): Enable to Synthesis hierarchically, otherwise considered flat synthesis.
- **`SYNTH_HIER_SEPARATOR`** (default: `.`): Separator used for the synthesis flatten stage.
- **`SYNTH_INSBUF`** (default: `1`): Insert input buffers on top-level input ports during synthesis. Useful to disable when doing parallel synthesis and concatenating netlists later as we're generating netlists of submodules.
- **`SYNTH_KEEP_MOCKED_MEMORIES`** (default: `1`): When `SYNTH_MOCK_LARGE_MEMORIES=1`, setting this to 1, will keep mocked memories (not flattening them). This preserves some of the access logic complexity and avoids optimizations outside of the mocked memory.
- **`SYNTH_KEEP_MODULES`**: Mark modules to keep from getting removed in flattening.
- **`SYNTH_MEMORY_MAX_BITS`** (default: `4096`): Maximum number of bits for memory synthesis. Ideally, real RAM or realistic fakeram should be used for RAMs much larger than 1024 bits. To temporarily ignore the RAM concerns and investigate other aspects of the design, consider setting `SYNTH_MOCK_LARGE_MEMORIES=1`, or adjusting `SYNTH_MEMORY_MAX_BITS`.
- **`SYNTH_MINIMUM_KEEP_SIZE`** (default: `0`): For hierarchical synthesis, we keep modules of larger area than given by this variable and flatten smaller modules. The area unit used is the size of a basic nand2 gate from the platform's standard cell library. The default value is platform specific.
- **`SYNTH_MOCK_LARGE_MEMORIES`** (default: `0`): Reduce Yosys inferred memories larger than SYNTH_MEMORY_MAX_BITS to 1 row. Yosys will generally infer memories from behavioral Verilog code, whether the memories are in standalone modules or instantiated within some larger module. fakeram and empty Verilog memories(blackboxes) of memories will not be inferred memories by Yosys and are therefore not affected by this variable. This is useful and convenient to separate the concern of instantiating and placing memories from investigating other issues with a design, though it comes at the expense of the increased accuracy that using realistic fakemem would provide. Memories with a single 1 row will of course have unrealistically good timing and area characteristics, but timing will still correctly terminate in a register. Large port memories, typically register files, will still have the retain a lot of the port logic that can be useful to investigate issues. This can be especially useful during development of designs where the behavioral model comes first and suitable memories are matched up when the design RTL is stable. A typical use case would be Chisel which will generate a behavioral model for a memories with the required clocks, ports, etc. in addition to a computer readable file with the specification of the memories that is used to [automatically](https://chipyard.readthedocs.io/en/stable/Tools/Barstools.html/) match up suitable memory macros later in the flow. During an architectural screening study, a large range of memory configurations can be investigated quickly with this option, without getting bogged down in the concern of how to realize the memories in silicon for emphemral RTL configurations that exist only long enough to run through the ORFS flow to create a table of some characteristics of a design configuration.
- **`SYNTH_NETLIST_FILES`**: Skips synthesis and uses the supplied netlist files. If the netlist files contains duplicate modules, which can happen when using hierarchical synthesis on indvidual netlist files and combining here, subsequent modules are silently ignored and only the first module is used.
- **`SYNTH_OPERATIONS_ARGS`**: Extra arguments appended to the Yosys synth command operations list. When set, replaces the default Kogge-Stone adder extra-map.
- **`SYNTH_OPT_HIER`**: Optimize constants across hierarchical boundaries.
- **`SYNTH_REPEATABLE_BUILD`** (default: `0`): License to prune anything that makes builds less repeatable, typically used with Bazel to ensure that builds are bit-for-bit identical so that caching works optimally. Removes debug information that encodes paths, timestamps, etc.
- **`SYNTH_RETIME_MODULES`**: *This is an experimental option and may cause adverse effects.* *No effort has been made to check if the retimed RTL is logically equivalent to the non-retimed RTL.* List of modules to apply automatic retiming to. These modules must not get dissolved and as such they should either be the top module or be included in SYNTH_KEEP_MODULES. The main use case is to quickly identify if performance can be improved by manually retiming the input RTL. Retiming will treat module ports like register endpoints/startpoints. The objective function of retiming isn't informed by SDC, even the clock period is ignored. As such, retiming will optimize for best delay at potentially high register number cost. Automatic retiming can produce suboptimal results as its timing model is crude and it doesn't find the optimal distribution of registers on long pipelines. See OR discussion # 8080.
- **`SYNTH_SKIP_KEEP`** (default: `0`): Only meaningful together with SYNTH_CHECKPOINT. When set, signals that the supplied checkpoint is still canonical RTLIL (coarse synth and `keep_hierarchy` have not been run yet), so synth.tcl runs the full coarse+fine synthesis flattened. When unset and SYNTH_CHECKPOINT is used, synth.tcl assumes the checkpoint already has coarse synth + `keep_hierarchy` done and resumes from `coarse:fine`.
- **`SYNTH_SLANG_ARGS`**: Additional arguments passed to the slang frontend during synthesis.
- **`SYNTH_USE_SYN`** (default: `0`): If set to 1, run synthesis using the "syn" tool built into OpenROAD (the synth_syn.tcl flow) instead of the default Yosys-based flow. Defaults to 0 (Yosys flow).
- **`SYNTH_WRAPPED_ADDERS`**: Specify the adder modules that can be used for synthesis, separated by commas. The default adder module is determined by the first element of this variable.
- **`SYNTH_WRAPPED_MULTIPLIERS`**: Specify the multiplier modules that can be used for synthesis, separated by commas. The default multiplier module is determined by the first element of this variable.
- **`SYNTH_WRAPPED_OPERATORS`**: Synthesize multiple architectural options for each arithmetic operator in the design. These options are available for switching among in later stages of the flow.
- **`TIEHI_CELL_AND_PORT`**: Tie high cells used in Yosys synthesis to replace a logical 1 in the Netlist.
- **`TIELO_CELL_AND_PORT`**: Tie low cells used in Yosys synthesis to replace a logical 0 in the Netlist.
- **`UNSET_ABC9_BOX_CELLS`**: List of cells to unset the abc9_box attribute on
- **`VERILOG_DEFINES`**: Preprocessor defines passed to the language frontend. Example: `-D HPDCACHE_ASSERT_OFF`
- **`VERILOG_FILES`**: The path to the design Verilog/SystemVerilog files providing a description of modules.
- **`VERILOG_INCLUDE_DIRS`**: Specifies the include directories for the Verilog input files.
- **`VERILOG_TOP_PARAMS`**: Apply toplevel params (if exist). Passed in as a list of key value pairs in tcl syntax; separated by spaces: PARAM1 VALUE1 PARAM2 VALUE2
- **`WRITE_ODB_AND_SDC_EACH_STAGE`** (default: `1`): Save out .sdc and .odb file after each stage, useful to disable when using a single OpenROAD instance to run all stages of the flow.
- **`YOSYS_FLAGS`** (default: `-v 3`): Flags to pass to yosys.
