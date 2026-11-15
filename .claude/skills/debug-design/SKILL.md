---
name: debug-design
description: Analyze and debug a failing HighTide design. Diagnose synthesis problems, memory inference issues, congestion, timing violations, and placement/routing failures. Can generate layout images for visual diagnosis.
argument-hint: "<platform>/<design> [stage] [issue-description]"
---

# Debug a Failing Design

You are debugging the design at `designs/$0`. The user may have specified a stage (`$1`) and/or an issue description (`$2`). If the stage or issue is not provided, determine them by examining build artifacts and logs.

**Important:** HighTide is a benchmark suite — the RTL is a fixed input. Never suggest modifying the upstream Verilog/RTL. All fixes must be scoped to flow parameters (BUILD.bazel `arguments`), timing constraints (constraint.sdc), physical design files (io.tcl, pdn.tcl), and FakeRAM configuration.

## Step 0: Check prior art — CLAUDE.md bugs and other designs' DECISIONS.md

Before reading logs, spend 60 seconds looking for someone who already solved this:

1. **CLAUDE.md "Known OpenROAD / yosys-slang bug workarounds"** at the repo root.  Grep for the error code (`grep -E "MPL-0040|CTS-0105|ODB-1200" CLAUDE.md`) or the failing stage name.  If a row matches, the **Workaround** column points at the exact fix and the **Issue** column links the upstream tracker.

2. **Other designs' DECISIONS.md**.  These live at `designs/src/<design>/DECISIONS.md` and capture per-(design, platform) tuning rationale, manual placement strategies, and timing-constraint reasoning.  A design with a similar shape (macro-heavy, deep pipeline, same platform) often hit the same problem first:

   ```bash
   # Search every DECISIONS.md for the symptom — error code, stage name, or keyword
   grep -rn -E "<error-code>|<stage-name>|<symptom>" designs/src/*/DECISIONS.md
   ```

   When grep hits, read the full **Decisions** entry on the matching platform — the why is what generalizes, even if the exact fix doesn't.  Common reusable patterns: `MACRO_PLACE_HALO` for sky130hd macro-heavy designs, `TNS_END_PERCENT = 100` vs lower for repair_timing budget, `clk_io_pct` bumps for nangate45 long IO paths, `PRE_CTS_TCL` for CTS-0105.

If a similar problem turned up in another design and the workaround applies, propose it as the candidate fix in Step 5 — and note in the DECISIONS.md update which design's experience you reused.

## Step 1: Locate Build Artifacts

Check for artifacts in three locations, in order of preference:

### 1a. Local Bazel artifacts

```bash
ls bazel-bin/designs/$0/results/*/base/*.odb 2>/dev/null
ls bazel-bin/designs/$0/logs/*/base/*.log 2>/dev/null
ls bazel-bin/designs/$0/logs/*/base/6_report.json 2>/dev/null
```

### 1b. Previously fetched artifacts

Artifacts downloaded from the Nautilus PVC are stored at `artifacts/<platform>/<design>/`:
```bash
ls artifacts/$0/results/*/base/*.odb 2>/dev/null
ls artifacts/$0/logs/*/base/*.log 2>/dev/null
ls artifacts/$0/logs/*/base/6_report.json 2>/dev/null
```

### 1c. Fetch from Nautilus PVC

If no local artifacts exist, the design may have been built on the Nautilus NRP cluster (via `./k8s/run.sh --upload-artifacts`). Fetch the artifacts:

```bash
./tools/fetch_artifacts.sh --keep <platform> <design>
```

This downloads results, reports, and logs from the `hightide-artifacts` PVC to `artifacts/<platform>/<design>/`. Use `--keep` to preserve the remote copy for other users. Without `--keep`, remote artifacts are deleted after fetch.

Other fetch options:
```bash
./tools/fetch_artifacts.sh --keep <platform>          # all designs for a platform
./tools/fetch_artifacts.sh --keep                     # all designs, all platforms
./tools/fetch_artifacts.sh --keep --design <design>   # one design, all platforms
```

### 1d. Determine build status

Identify the **last completed stage** (1_synth, 2_floorplan, 3_place, 4_cts, 5_route, 6_final) and the **first failed stage** by checking which .odb files exist. Check whichever artifact location has the files (bazel-bin or artifacts directory).

**Artifact path convention:** Throughout this skill, paths like `logs/<platform>/<design>/base/` refer to whichever artifact location has the files. Check in order: `bazel-bin/designs/$0/`, then `artifacts/$0/`. Use the one that exists.

## Step 2: Read the Design Configuration

Read these files to understand the design setup:
- `designs/<platform>/<design>/BUILD.bazel` — flow parameters (in `arguments`) and source files
- `designs/<platform>/<design>/constraint.sdc` — timing constraints
- `designs/<platform>/<design>/pdn.tcl` — power delivery (if it exists)
- `designs/<platform>/<design>/io.tcl` — pin placement (if it exists)
- `designs/src/<design>/BUILD.bazel` — which Verilog files are in the `rtl` filegroup

## Step 3: Analyze by Failure Type

Based on the failed stage and symptoms, follow the appropriate diagnosis path below.

---

### A. Synthesis Failures (Stage 1)

**Read the synthesis log** (check bazel-bin or artifacts directory, whichever has the files):
```bash
tail -200 bazel-bin/designs/$0/logs/*/base/1_1_yosys.log 2>/dev/null
tail -200 artifacts/$0/logs/*/base/1_1_yosys.log 2>/dev/null
```

**Common synthesis issues:**

1. **Missing modules / unresolved references**: Check that all Verilog files are reachable via the `rtl` filegroup in `designs/src/<design>/BUILD.bazel`. Search the RTL for the missing module name.

2. **Incorrectly synthesized memories**: Yosys may infer memories as flip-flops instead of using FakeRAM macros.
   - Check the synth log for `Creating memory...` or `$mem` cells
   - Search for large register arrays: `grep -i "mem\|ram\|reg.*\[" <synth-log>`
   - If memories are being flattened into flops, the design needs FakeRAM black-box macros:
     - FakeRAM LEF/LIB files must exist in `designs/<platform>/<design>/sram/`
     - `ADDITIONAL_LEFS` and `ADDITIONAL_LIBS` must be present in BUILD.bazel `sources`
     - The Verilog module interfaces must match the FakeRAM macro pin names
     - `SYNTH_MEMORY_MAX_BITS` may need adjustment to prevent Yosys from synthesizing large memories
   - A suspiciously high cell count is a strong indicator memories were flattened

3. **SystemVerilog not supported**: Yosys has limited SV support. Prefer `SYNTH_HDL_FRONTEND = slang` (yosys-slang) in BUILD.bazel `arguments`; failing that, the design may need sv2v conversion in `designs/src/<design>/dev/setup.sh`.

4. **Synthesis timeout / excessive runtime**: Consider `SYNTH_HIERARCHICAL = 1` and `ABC_AREA = 1` in BUILD.bazel `arguments`.

---

### B. Floorplan Failures (Stage 2)

**Read the floorplan log:**
```bash
tail -200 logs/<platform>/<design>/base/2_*.log
```

**Common floorplan issues:**

1. **Macro placement failures (MPL-0040 or similar)**: The macro placer cannot find valid placements.
   - Increase `MACRO_PLACE_HALO` (e.g., `6 6` or `8 8`)
   - Lower `CORE_UTILIZATION` or increase die area — macros + std cells may not fit
   - Consider explicit `DIE_AREA` and `CORE_AREA` instead of utilization-based sizing
   - **If the design has many FakeRAM macros and platform-knob tuning isn't unsticking it**, consider repartitioning the FakeRAM banks for **this platform only** — splitting wide banks into more numerous narrow ones (or merging them) often fixes macro-driven floorplan failures that no halo/density value can.  See `.claude/skills/shared/sram-repartition.md`.

2. **PDN failures**: Power grid cannot be constructed.
   - Check if `pdn.tcl` exists and metal layer names match the platform (M1-M7 for asap7, met1-met5 for sky130hd)
   - If `2_4_floorplan_pdn.log` is clean but PSM-0069 fires at Stage 6, see **G (PSM errors)** — via obstruction leaves no trace in the PDN log

3. **IO placement failures**: Too many pins for the die perimeter — increase die area or create a manual `io.tcl`.

**Generate a floorplan image** to visualize macro placement and die area (see Step 4).

---

### C. Placement Failures (Stage 3)

**Read the placement log:**
```bash
tail -200 logs/<platform>/<design>/base/3_*.log
```

**Common placement issues:**

1. **Placement overflow / cannot place**: Die too small or utilization too high.
   - Check reported utilization vs target
   - Lower `PLACE_DENSITY` (try 0.5-0.65)

2. **Congestion hotspots**: Router estimates show high congestion during placement.
   - Look for "Congestion" warnings in the log
   - Generate a placement density and RUDY heatmap (see Step 4)
   - Follow the congestion fix priority in `.claude/skills/shared/congestion-analysis.md`
   - For macro-heavy designs where local-density hot spots near macro pins are the culprit (GP overflow plateaus around 0.2–0.4), consider repartitioning the FakeRAM banks for **this platform only** — see `.claude/skills/shared/sram-repartition.md`.
   - For sky130hd and other low-layer-count platforms, consider **alternating macro row orientation** (R0/MX) in `macro_placement.tcl` rather than a uniform grid — it creates distinct channel types that can reduce per-layer routing pressure. Inter-column spacing and hot/cold channel ratio require per-design tuning; start near the high end of the available spacing range.

---

### D. CTS Failures (Stage 4)

**Read the CTS log:**
```bash
tail -200 logs/<platform>/<design>/base/4_*.log
```

**Common CTS issues:**
1. **Clock tree cannot meet skew targets**: Check the clock definitions in `constraint.sdc`
2. **Missing clock port**: Verify `clk_port_name` in the SDC matches the actual design port name

---

### E. Routing Failures (Stage 5)

**Read the routing log:**
```bash
tail -200 logs/<platform>/<design>/base/5_*.log
```

**Common routing issues:**

1. **DRC violations**:
   ```bash
   head -100 reports/<platform>/<design>/base/5_route_drc.rpt 2>/dev/null
   ```

2. **Congestion-driven routing failures**: Too many routing resources consumed.
   - Check the GRT congestion report for per-layer overflow counts (see `.claude/skills/shared/congestion-analysis.md`):
     ```bash
     grep -A 15 "Final congestion report" logs/*/base/5_1_grt.log 2>/dev/null
     ```
   - Non-zero overflow on any layer means congestion-driven failures
   - Generate a routing congestion heatmap (see Step 4) for spatial diagnosis
   - Follow the congestion fix priority in `.claude/skills/shared/congestion-analysis.md`

3. **Antenna violations**: Check antenna report if available

---

### F. Timing Violations (Any Stage)

**First, diagnose.** Run the structured triage in `.claude/skills/shared/timing-analysis.md` to decide whether the dominant problem is (a) clock skew, (b) unreasonable clock period or IO delay, (c) wire vs. logic vs. macro delay, (d) a single problematic stage, (e) a multi-corner STA failure, or (f) something else. The shared reference gives the exact report/`jq` commands, the heuristic for each bucket, and the conclusion format. Targeting the right knob beats trying every fix below in sequence.

**Important: utilization and clock period are coupled.** Tighter clock constraints cause synthesis and `repair_timing` to insert more buffers and decompose gates, which raises the effective utilization. A design that fits at 80% util with a relaxed clock may overflow at 80% with an aggressive clock. When diagnosing timing, also check whether cell count and instance area changed compared to a relaxed-clock build.

**Common fixes (after diagnosis):**

1. **Relax clock period** in `constraint.sdc` to find the achievable Fmax for this (design, platform) pair.
2. **Lower `clk_io_pct`** when IO paths dominate. `clk_io_pct` multiplies `clk_period` to set both `set_input_delay` and `set_output_delay`; raising it makes IO timing *tighter*, lowering it gives the design more internal slack on IO paths. For benchmarking, `set_false_path` on non-meaningful IO ports lets the core register-to-register Fmax come through.
3. **Set `TNS_END_PERCENT = 100`** in BUILD.bazel `arguments` to give the flow more budget for `repair_timing` iterations.
4. **Add `set_clock_uncertainty`** in the SDC when CTS insertion delay is comparable to the IO budget — shared `(a)` covers when to suspect this.
5. **Hold violations** are usually fixed automatically by the flow; persistent hold failures usually indicate clock-tree problems — shared `(a)` again.

---

### G. Final Stage / DRC (Stage 6)

**Read the finish log and DRC report:**
```bash
tail -100 logs/<platform>/<design>/base/6_*.log
head -50 reports/<platform>/<design>/base/6_finish_drc.rpt 2>/dev/null
```

**Check the summary metrics:**
```bash
./tools/summary.sh            # Bazel flow
# Or manually parse 6_report.json
```

**PSM errors** (power connectivity, `6_*.log`):
- **PSM-0069** — check if all PSM-0039 warnings cluster in a single boundary row. If so, vias to that row were likely silently dropped by pin obstruction (no PDN-0110 fires for obstruction removal). See CLAUDE.md bugs table for root cause and fix.

---

## Step 4: Generate Layout Images

For visual diagnosis of floorplan, placement, congestion, and power routing problems, generate images using OpenROAD's `save_image` command.

See `.claude/skills/shared/image-generation.md` for the `xvfb-run` setup, Tcl scripts, and heatmap variants (routing congestion, placement density, RUDY, IR drop).

---

## Step 5: Recommend Fixes

Based on the diagnosis, recommend specific changes. Always explain **what** to change, **why**, and provide the exact file edits. Remember: never suggest RTL modifications — the Verilog is a fixed benchmark input.

**Congestion fix priority** — see `.claude/skills/shared/congestion-analysis.md`

**Timing fix priority:**
1. Check if the clock period target is realistic for the platform and design complexity
2. Check if failing paths are IO-constrained — if so, adjust `clk_io_pct` or IO delays to account for clock tree insertion delay
3. Add `set_clock_uncertainty` to model expected skew
4. Set `TNS_END_PERCENT = 100` in BUILD.bazel `arguments`
5. Relax clock period to find the true achievable Fmax

**Memory fix priority:**
1. Identify which memories need FakeRAM black-boxing
2. Create FakeRAM LEF/LIB files (use existing designs on the same platform as templates)
3. Add `ADDITIONAL_LEFS` / `ADDITIONAL_LIBS` filegroups to BUILD.bazel `sources`

## Step 6: Test the Fix

After applying changes, re-run the flow:

```bash
bazel build //designs/<platform>/<design>:<design>_final
```

Compare metrics before and after (WNS, TNS, Fmax, DRC count, cell count) to verify the fix improved the situation.

Once the design is passing cleanly, suggest that the user run `/optimize-ppa` to maximize utilization and clock frequency.

## Step 7: Record the fix in DECISIONS.md

After the fix lands, append a dated bullet to `designs/src/<design>/DECISIONS.md` under the `## <platform>` section (create the section, or the whole file, if missing — use `designs/src/gemmini/DECISIONS.md` as the canonical template). Capture:
- **What surfaced** — the error code or symptom (stage, log marker).
- **Root cause** — what you traced it back to (e.g. PDN-0195 via-removal near macros, MPL-0040 annealing failure, RTL-bounded path).
- **Fix applied** — the BUILD.bazel argument, the new tcl file, the SDC tweak, with commit hash.
- **Which prior design's experience you reused** — credit the DECISIONS.md / bug-table row you pulled the workaround from (the Step 0 prior-art search).

If the fix is a workaround for a new upstream bug, also run `/track-bug` so the cross-cutting CLAUDE.md table gets a row pointing at the upstream issue.

**Do not** add the debug story to `CLAUDE.md`. CLAUDE.md's "Build status" is a pure index; per-design narrative belongs in DECISIONS.md. Only update CLAUDE.md if the (design, platform) pair changed status (moved between cached / local-only / not-finishing).
