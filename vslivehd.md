---
name: optimize-livehd
description: Diagnose and improve LiveHD synthesis and physical-design quality or runtime using HighTide designs and controlled exchanges with Yosys and OpenROAD. Use for cross-tool comparisons, stage isolation, timing calibration, and optimization experiments.
---

# Optimize LiveHD through interchangeable stages

Use HighTide designs to find problems and opportunities in LiveHD by exchanging
inputs and outputs with Yosys and OpenROAD. Compare whole flows to find a gap,
then swap individual stages to locate its cause. Use the reference tools as
independent implementations and evaluators; investigate discrepancies in either
flow before attributing them to LiveHD.

Discover the current implementation, defaults and benchmark configuration for
each task. Re-evaluate hypotheses with the selected design and tool revisions.
This skill prescribes an experimental method, not preferred parameter values or
conclusions about which algorithms will win.

## Establish the experiment

1. Read the design's `BUILD.bazel`, RTL/top, includes/defines, generated wrappers,
   constraints, memory models and technology views. Resolve the actual Yosys and
   OpenROAD scripts, platform configuration and executable versions.
2. Inspect LiveHD's `lhd help`, `lhd describe synth`, effective configuration and
   relevant implementation. Trace enabled stages and options through wrappers;
   a recognized setting does not prove the selected path uses it.
3. Reproduce a valid reference at the boundary under investigation. Debug setup
   failures rather than relaxing constraints to manufacture a baseline. Separate
   successful execution from meeting timing, area or congestion targets.
4. State the hypothesis, shared inputs, stage to exchange, primary metric and
   resource budget. Start with the smallest comparison that can answer it.

Match the RTL semantics, library corner, SDC and explicit physical constraints.
Distinguish core utilization from placement density: a supplied core fixes the
available area, while density is a placement objective. Derive RC, routing
capacity, macro geometry and legal orientations from the selected technology.
Record tool-specific defaults and unsupported constraint translations instead
of silently substituting values.

## Choose a stage exchange

| Question | Controlled experiment |
| --- | --- |
| Frontend or elaboration? | Compile the same RTL/top in LiveHD and Yosys; inspect elaborated hierarchy, widths, state and memories before optimization. Exchange lowered Verilog when both readers support its semantics. |
| Logic optimization or mapping? | Feed LiveHD and Yosys the same elaborated design, or a compatible unmapped intermediate, and hold the technology mapper constant where possible. Then hold the optimized input constant and vary mapping. |
| Synthesis QoR? | Synthesize the same RTL with each flow; evaluate both mapped netlists with common timing, then pass both through the same placement/repair flow. |
| Synthesis versus placement interaction? | Run each synthesized netlist through each placer, producing a 2×2 comparison under the same physical constraints. |
| Floorplan or macro placement? | Transfer each tool's macro coordinates/orientations to a common mapped netlist, then run each cell placer on each macro arrangement. |
| Cell placement or legalization? | Use one mapped netlist, core, fixed macros and IOs. Compare GP snapshots, legal placement and subsequent repair separately. |
| Resizing or buffering? | Start both repair implementations from the same mapped netlist and legal placement. Separate sizing, buffer insertion/removal, tree repair and logic resynthesis. |
| Timing engine or RC estimator? | Give OpenTimer and OpenSTA identical netlist, constraints and parasitics. Compare RC estimators separately using one timing engine. |

Use a full matrix when interactions matter; a single stage swap is often enough
to locate the next useful investigation. An end-to-end difference alone does
not identify the responsible stage.

## Validate the handoff

- **Logic:** carry cell definitions, bit-level port names and widths, constants,
  clock/reset semantics and black-box interfaces. Use Verilog accepted by the
  receiving tool; fix export incompatibilities without changing behavior.
- **Memories:** verify inferred arrays versus mapped SRAM instances, port counts,
  read latency, masks and read/write collision behavior. Match Liberty and LEF
  masters. Do not equate a flop array or proxy with a technology SRAM merely
  because capacity matches.
- **Physical data:** carry core/rows/sites, IO locations, macro orientations,
  halos/blockages and fixed status. For a cell-placement comparison, remove only
  the standard-cell positions being recomputed. Match instances by identity and
  master; reject ambiguous mappings rather than guessing by size.
- **Policy:** apply input normalization to both branches and record it. Decide
  explicitly whether resizing, buffering and resynthesis may alter the netlist.
  Verify virtual edits are rolled back when claiming unchanged-netlist placement.

Check the received artifact before running the next optimizer. Instance counts
alone are insufficient: compare masters and signal connectivity for unchanged
netlists, and audit intended edits for repair runs. If two synthesis flows produce
different memory implementations, choose a compatible boundary or label the
comparison as a whole-flow experiment.

## Diagnose and optimize

**Synthesis.** Inspect lowering, hierarchy specialization, synthesis colors and
region boundaries, optimization, technology mapping and read-back separately.
Compare area, logic depth, fanout, sequential/memory counts, timing coverage and
runtime. For color changes, inspect cone membership, shared logic, boundary
loads, clock/reset handling and memory barriers. A balanced partition is useful
only if it improves the measured objective without changing semantics. Separate
region-mapping quality from cross-region sizing and buffering.

**Timing.** First compare zero-wire timing to expose netlist or constraint
differences. For engine calibration, hold RC identical and inspect matching path
pins, transitions, loads, library units and launch/capture conditions. Add wire
capacitance and resistance in controlled steps; reduce disagreements to a small
synthetic case. Equal coordinates with independently estimated RC do not isolate
the timing engine. Verify endpoint coverage before trusting better WNS/TNS.

**Physical optimization.** Trace where timing and congestion feedback actually
run, which nets receive weights and when edits are committed. Separate floorplan,
macro placement, cell GP, legalization, detailed placement and repair. Capture
coordinates immediately around the suspect stage. Count attempted versus accepted
edits, final surviving buffers/master changes, timing calls and their cost.
Distinguish congestion estimates from measured routed congestion.

Tune options that act on the diagnosed stage. Candidate dimensions include
synthesis boundaries/backend, area-delay objectives, timing coverage and weight
smoothing, feedback cadence, repair policy, density/grid, macro anchors/halos and
optimization budgets. Obtain names, ranges and defaults from the current code;
keep experimental values explicit. Hold unrelated settings fixed, then explore
interactions where the evidence warrants it. A schedule change can also alter
smoothing and repair opportunities, so attribute combined changes carefully.

Use common OpenSTA scoring for cross-tool timing comparisons, with identical
libraries, constraints, parasitic assumptions and clock treatment at each stage.
Choose the objective for the task: WNS, TNS, area, power, runtime, or a stated
trade-off. HPWL and RUDY help explain physical results but cannot establish timing
or routing quality. Compare power only with consistent activity assumptions.

A target may be unattainable. Report target attainment, measured improvement,
plateau evidence and budget exhaustion separately. Compare additional effort
with a matched control to decide whether continuing helps; density convergence
alone is not timing convergence. Preserve the best validated checkpoint.

## Confirm the improvement

Run focused checks in the repository owning the change, then repeat the affected
stage exchange and the relevant downstream flow. Check semantic correctness,
constraint coverage and physical legality as applicable. A buffer-collapsed
connectivity audit is not equivalence proof. If running LEC, use the default
`formal.effort=test`; report proven, refuted, timeout and setup failure distinctly.

Test the hypothesis on another suitable design or seed before generalizing.
Choose contrasting structure when useful: combinational versus state-heavy,
flat versus hierarchical, few versus many memories. Keep large benchmarks in
HighTide; LiveHD regression tests must use repository or declared dependency
inputs, not sibling benchmark paths.

When routed QoR is part of the question, feed the accepted legal netlist/LEF/DEF
from either flow into the same OpenROAD CTS/routing setup. Validate the resume
boundary and score any handoff cleanup separately. Use propagated clocks and
the intended extracted parasitics for routed timing; a stage label does not
prove extraction occurred. Cross-tool diagnostics do not require adding OpenDB
or OpenROAD dependencies to LiveHD's native optimization code.

## Reproduce and report

Keep a fresh directory per variant with input/tool hashes, revisions and dirty
patches, exact commands, effective settings, seeds, thread counts, checkpoints
and logs. Freeze binaries during a measured sweep. Measure cold and warm cache
behavior deliberately; rebuilds can invalidate cache entries.

Serialize synthesis jobs and measured comparisons. Monitor the whole owned
process tree against a memory limit and OS reserve. Retain completed artifacts
and report timeouts or guard stops as incomplete runs.

Deliver the hypothesis, comparison boundary, measured trade-offs, validation and
next discriminating experiment. Include synthesis and placement times separately,
with stage/repair/scoring breakdowns where relevant. Report counts and area with
explicit macro/physical-only definitions. For physical comparisons, include
same-scale stage PNGs and candidate/color overlays when they help explain the
result. Keep measurements in the run's HTML/data artifacts, outside this skill.

## Repository entry points

- HighTide design `BUILD.bazel` files and [export tools](tools/bazel_to_orfs.sh):
  resolve RTL, technology and the reference flow for the selected design.
- LiveHD [synthesis](../livehd/pass/synth/README.md),
  [coloring](../livehd/pass/color/README.md),
  [timing](../livehd/pass/opentimer/README.md) and
  [placement](../livehd/pass/place/README.md): locate relevant code, then verify
  actual behavior against the selected revision and logs.
- [Physical replay helper](tools/vslivehd/run.py): inspect before reuse. It takes
  prepared `native.json` and resolved ORFS `flow_env.json` inputs, with `LIVEHD`,
  `OPENROAD_EXE`, `PREPARED` and fresh `VS_OUT` environment paths. Native inputs
  identify the top, DEF, Liberty, LEFs, SDC and technology RC. The helper imposes
  experiment policies; inspect its overrides and Tcl stages rather than treating
  it as either tool's production defaults or a generic design importer.
- [Common scorer](tools/vslivehd/score.tcl) and
  [connectivity export](tools/vslivehd/audit.tcl): check their metric definitions
  and supported stages before adapting them. Add preparation, validation and
  downstream resume scripts for the chosen experiment when needed.
- [Measurement tools](tools/vslivehd/BUILD.bazel),
  [freezer](tools/vslivehd/freeze_tools.py), and
  [resource wrapper](tools/vslivehd/measure.py) support
  [lhdtrack's corpus ASAP7 pre-CTS comparison](../lhdtrack/tools/run_placement.py)
  and the earlier [lhdsuite diagnostic](../lhdsuite/bench/placement.py). The wrapper
  records `perf stat`, CPU, largest-process RSS, sampled process-group RSS and
  explicit guard stops. Freeze the optimized binaries before the sweep.
  `score_flow.tcl` accepts `SCORE_STAGE=synth|place`; synthesis uses zero
  wire RC and placement uses estimated RC with ideal clocks.
  Run scoring outside the measured synthesis/physical interval.
- [lhdtrack SRAM preparation](../lhdtrack/src/lhdtrack/srams.py) uses this checkout's
  pinned `tools/bsg_fakeram` generator for declared explicit SRAMs. It stages the
  generator, validates write-data pin directions, uses camel-case site-grid snap
  keys, and converts ns/pF Liberty timing/capacitance/energy units before merging
  with ASAP7. Both tools receive the same models. The
  [integration check](../lhdtrack/tools/check_placement_srams.py) runs both pre-CTS
  flows and checks original versus converted models on one DEF. Inferred arrays
  retain their original semantics and the compiler's default realization policy.
