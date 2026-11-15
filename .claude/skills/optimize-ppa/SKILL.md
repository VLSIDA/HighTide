---
name: optimize-ppa
description: Optimize power, performance, and area (PPA) for a HighTide design. Maximize cell utilization and clock frequency while maintaining a clean flow (no DRC violations).
argument-hint: "<platform>/<design>"
---

# Optimize PPA for a Design

You are optimizing the PPA (power, performance, area) of the design at `designs/$0`. The goals are:
1. **Maximize utilization** — pack cells as tightly as possible to minimize die area
2. **Maximize clock frequency (Fmax)** — tighten the clock period to find the fastest achievable frequency
3. **Maintain a clean flow** — zero DRC violations, no routing failures

**Important:** HighTide is a benchmark suite — the RTL is a fixed input. Never suggest modifying the upstream Verilog/RTL. All optimizations must be scoped to flow parameters (BUILD.bazel `arguments`), timing constraints (constraint.sdc), physical design files (io.tcl, pdn.tcl), and FakeRAM configuration.

**Key lesson: utilization and clock period are coupled.** Tighter clock constraints cause synthesis and repair_timing to insert more buffers, increasing the effective cell area. A design that fits at 80% utilization with a relaxed clock may overflow at 80% with an aggressive clock. Optimize utilization first at the current clock, then tighten the clock and re-check utilization.

## Step 0: Check prior art — CLAUDE.md bugs and other designs' DECISIONS.md

Before measuring or tuning anything, spend 60 seconds looking at how similar designs were optimized:

1. **CLAUDE.md "Known OpenROAD / yosys-slang bug workarounds"** at the repo root — if a row's "Affected designs" cell mentions this design or a structurally-similar one, the workaround may already be active in `arguments={…}`.  Don't re-introduce a knob the bug-table already controls.

2. **Other designs' DECISIONS.md** at `designs/src/<design>/DECISIONS.md`.  These capture *why* each design's util / density / halo / clock landed where it did.  Before tightening any knob, check whether a similarly-shaped design (same platform, same macro count, same gate type — e.g., another sky130hd ML-accelerator with N macros) already explored the same axis:

   ```bash
   # Same platform, similar size or shape — read all of them
   grep -rln '^## sky130hd' designs/src/*/DECISIONS.md
   # Specific knobs people have written about
   grep -rE 'CORE_UTILIZATION|PLACE_DENSITY|MACRO_PLACE_HALO|clk_period' designs/src/*/DECISIONS.md
   ```

   The reusable pattern is usually:
   - **Floor on `CORE_UTILIZATION`** for a given (platform, macro-count) — if every macro-heavy design on sky130hd has a util ceiling around 25%, this design probably can't push past it without a manual macros.tcl.
   - **Floor on clock period** — period_min vs target ratios that converged elsewhere generalize.
   - **Halo trade-off shape** — what halo value each platform's working designs settled on.

   Reusing prior art beats re-discovering it: when this skill makes the final DECISIONS.md update in Step 6, note which other design's experience informed the decision.

## Step 1: Establish Baseline

First, gather the current metrics from the most recent build.

**Find the metrics report** (check `bazel-bin/designs/$0/` then `artifacts/$0/`):
```bash
cat bazel-bin/designs/$0/logs/*/base/6_report.json 2>/dev/null
cat artifacts/$0/logs/*/base/6_report.json 2>/dev/null
```

If no artifacts exist locally, fetch from the Nautilus PVC:
```bash
./tools/fetch_artifacts.sh --keep <platform> <design>
```

If no build exists at all, run the flow:
```bash
bazel build //designs/<platform>/<design>:<design>_final
```

**Record baseline metrics:**
- Die area, core area, instance area
- Cell utilization (%)
- WNS, TNS, Fmax
- `report_clock_min_period` — the true minimum achievable clock period (more reliable than computing from WNS)
- Total power
- DRC error count
- Cell count, macro count
- **Total flow runtime** — record wall-clock time for the baseline build. This is a critical early-warning signal.
- **GRT congestion** — check routing overflow counts (see Step 2d)

**Read the design configuration:**
- `designs/<platform>/<design>/BUILD.bazel`
- `designs/<platform>/<design>/constraint.sdc`
- `designs/<platform>/<design>/pdn.tcl` (if it exists)
- `designs/<platform>/<design>/io.tcl` (if it exists)

**Artifact path convention:** Throughout this skill, paths like `logs/*/base/` refer to whichever artifact location has the files. Check `bazel-bin/designs/$0/` first, then `artifacts/$0/`.

## Step 2: Maximize Utilization (Area Optimization)

The goal is to increase `CORE_UTILIZATION` as high as possible while maintaining a routable design with zero DRC violations.

### 2a. Check current utilization headroom

Compare the **target utilization** (from BUILD.bazel `arguments`) to the **achieved utilization** (from the metrics report). If there is a large gap, the die is oversized.

Also check the placement density — if `PLACE_DENSITY` is much lower than the target utilization, placement may be too spread out.

### 2b. Increase utilization incrementally

Raise `CORE_UTILIZATION` in steps (e.g., +5% at a time). For each step:

1. Update `CORE_UTILIZATION` in BUILD.bazel `arguments`
2. Adjust `PLACE_DENSITY`. It has **two distinct uses** that pull in opposite directions; pick the one that matches the bottleneck (see 2c′ for the spreading use):
   - **Packing (default):** when you're raising `CORE_UTILIZATION` to shrink the die, keep `PLACE_DENSITY` slightly above the utilization fraction (e.g., util 60 → density 0.65–0.70). This lets the global placer pack std cells tightly into the smaller core.
   - **Spreading (see 2c′):** when achieved-util is already comfortable but heatmaps show *local* clumping (cells crowded near macro pins, empty die elsewhere), drop `PLACE_DENSITY` *below* the achieved utilization fraction to force the global placer to disperse cells across empty area. Sky130hd/cnn uses `0.20` against a 28.6% achieved-util for exactly this reason.
3. Run `bazel build //designs/<platform>/<design>:<design>_final`
4. Check for:
   - Placement overflow (placement cannot converge)
   - Routing congestion (DRC violations — check GRT overflow, see 2d)
   - Timing degradation (WNS getting worse)
   - **Runtime blowup** (see section 2e)

### 2c. Handle congestion at high utilization

As utilization increases, congestion will become the bottleneck. See `.claude/skills/shared/congestion-analysis.md` for the fix priority and diagnostic approach.

### 2c′. Low `PLACE_DENSITY` as a spreading lever (when clumping is the bottleneck, not packing)

This is a separate use of `PLACE_DENSITY` from 2b — reach for it when the design **closes timing fine at the current target util** but heatmaps or visual layout show **cells clumped in spots with large empty regions elsewhere**.

**Mechanism.** `global_placement` is pin-edge-blind: when it sees a macro with std-cell loads, it pulls those cells toward the macro's pin edge. With many macros this creates dense clumps next to each macro and near-empty space everywhere else. Local congestion spikes on lower metals (met1/met2 on sky130hd, M1/M2 on asap7) at usage % well below the "global congestion wall" — the average is fine but the local density isn't. Lowering `PLACE_DENSITY` below the achieved utilization fraction tells the placer to **disperse** instead of clump.

**When to reach for this:**
- Achieved utilization is comfortable (no overflow, no DRCs) but layout heatmap shows clumps near macro pin edges and empty die elsewhere.
- Local met1/met2 max H/V is much higher than the average usage % (a sign of *local* not *global* congestion).
- The design has macro pins on a single edge (sky130hd fakeram met2 pin clusters; NVDLA partition memories) — the "pin attractor" effect is strongest.
- You've tried `MACRO_PLACE_HALO` and it's solving routability around macros but std cells are still clumped.

**Trade-offs (be honest about them):**

| Effect | Direction with low `PLACE_DENSITY` |
|---|---|
| Local clump congestion | **better** (cells spread) |
| Wirelength | worse (cells farther apart) |
| Setup timing | typically slightly worse from wire delay — often offset by less buffer insertion in repair_timing |
| Power | worse (more wire cap; bigger fanouts on net segments) |
| Die area, when `DIE_AREA`/`CORE_AREA` is explicit | unchanged (just fills the die more evenly) |
| Die area, when utilization-driven sizing | **worse** (low density forces a larger core to fit) |

So spreading is **not** a power-area win — it's a *routability* win that trades a bit of P+W for cleaner congestion. Use it when the issue you're solving is congestion clumps, not when the issue is "too much area".

**What it does NOT fix.** Cells already *touching* the macro pins (the close ring directly attracted to pin edges). For that you need `MACRO_PLACE_HALO` (cell-keepout zone around each macro) or `MACRO_BLOCKAGE_HALO` (routing-blockage zone). The combination — low `PLACE_DENSITY` for the bulk plus `MACRO_PLACE_HALO` for the ring — is what sky130hd/cnn ended up with (`0.20` + `300 300`).

**Recipe.**
1. Measure achieved utilization from a known-closing build.
2. Set `PLACE_DENSITY` ~10–30 percentage points below it (e.g., achieved 30% → try `0.20` first, then `0.30` if the spread is too aggressive).
3. Re-check the layout/heatmap and per-layer GRT max H/V to confirm clumps smoothed.
4. If wire-delay penalty pushed setup slack down too much, bump `MACRO_PLACE_HALO` by ~half a macro pitch and re-run — that lets you keep some of the spread while reclaiming the cells nearest pin edges.

**Existing examples in the repo:** `designs/sky130hd/cnn/BUILD.bazel` documents the rationale in-line; copy the comment style when applying this elsewhere so the *why* survives in DECISIONS.md.

### 2d. Check GRT congestion metrics

After each build, check the global routing congestion report — this is the most reliable numeric indicator of whether utilization can be pushed further:

```bash
grep -A 15 "Final congestion report" logs/*/base/5_1_grt.log 2>/dev/null
```

- **Total Overflow = 0**: routing succeeded, may have room for more utilization
- **Usage % > 70-80% on any layer**: approaching the congestion wall
- **Any overflow > 0**: congestion failures — apply fixes from `.claude/skills/shared/congestion-analysis.md` before increasing utilization further

### 2e. Monitor runtime as an early-warning signal

A significant increase in flow runtime compared to the baseline is a strong indicator that the design is over-constrained — the tools are spending excessive time on repair_timing iterations, detailed routing retries, or placement optimization that cannot converge well.

**How to detect runtime blowup:**
- Compare wall-clock time to the baseline build. A run taking 2-3x longer than baseline is a warning; 5x+ means the configuration is likely unviable.
- Check per-stage runtimes by comparing log timestamps. The stages that blow up most are:
  - **Placement** (stage 3) — excessive time means placement density is too high
  - **CTS / repair_timing** (stage 4) — excessive time means timing constraints are too tight and the tool is doing many repair iterations
  - **Detailed routing** (stage 5) — excessive time means routing congestion is too high, causing many rip-up-and-retry cycles

**What to do when runtime blows up:**
- Do not wait for the run to finish — if a stage is already taking much longer than baseline, kill it and back off the most recent parameter change.
- If utilization increase caused the blowup, back off to the previous utilization value — that was likely the practical limit without other changes (io.tcl, pdn.tcl, etc.).
- If clock tightening caused the blowup, the previous clock period was near the achievable Fmax — back off and declare that as the result.
- A runtime blowup at one utilization level may be fixable with congestion mitigation (io.tcl, macro halo) before trying that utilization again.

### 2f. Generate images to diagnose congestion

When congestion blocks further utilization increases, generate heatmaps to identify specific problem areas. See `.claude/skills/shared/image-generation.md` for Tcl scripts and the `xvfb-run` invocation. The most useful heatmaps:
- **Placement density** — find regions with excessive cell density
- **RUDY** — estimate routing demand before routing
- **Routing congestion** — find actual routing bottlenecks after routing

### 2g. Repartition FakeRAM macros (split or merge)

For macro-heavy designs, FakeRAM **geometry** is often a more powerful tuning lever than placement density: splitting wide banks into many narrow ones makes placement easier (at the cost of memory density); combining narrow banks into wider ones is denser but harder to place — especially on sky130hd's coarse pitches.

Reach for this when Step 2 plateaus before timing converges and std-cell utilization is noticeably below `CORE_UTILIZATION` (i.e., the routability bottleneck is the macros, not the std cells).  See `.claude/skills/shared/sram-repartition.md` for the trade-off table, the per-platform direction guide, the 5-step procedure (uses `/generate-sram`), the DECISIONS.md template, and — as a last resort, with explicit user approval — guidance on shrinking a memory.

## Step 3: Maximize Clock Frequency (Performance Optimization)

The goal is to find the highest Fmax by tightening the clock period until timing violations appear, then backing off slightly. **Before tightening, run the structured diagnosis in `.claude/skills/shared/timing-analysis.md`** to identify *why* the current critical path is slow — clock skew, unreasonable clock period or IO delay, wire/logic/macro delay dominance, a single problematic stage, a multi-corner failure, or something else. The lever you reach for (tighten the clock vs. fix placement vs. retune SDC) depends on the answer; the steps below assume that triage is done.

### 3a. Tighten clock period

Use `report_clock_min_period` from the finish report as the starting target, then binary search:

1. Start from the current `clk_period` in constraint.sdc
2. If WNS is positive, reduce `clk_period` toward the `period_min` value (minus a small margin)
3. Re-run the flow
4. If WNS is still positive, tighten further
5. If WNS is negative, back off — the previous period was close to optimal
6. Converge when WNS is near zero (within ~0.01-0.05ns for asap7, ~0.05-0.1ns for nangate45/sky130hd)

**Set `TNS_END_PERCENT = 100`** in the design's `BUILD.bazel` `arguments` dict to ensure the flow tries hard to close timing.

**Remember the util/clock coupling:** after tightening the clock significantly, re-check that the design still fits. CTS repair_timing inserts buffers that increase cell area. You may need to lower utilization when the clock gets aggressive.

### 3b. Watch for runtime blowup during clock tightening

As the clock period gets tighter, the CTS and routing stages will spend increasingly more time on repair_timing iterations. If a run is taking significantly longer than the baseline (2-3x+), the clock target is likely too aggressive — kill it, back off to the previous period, and declare that as the achievable Fmax.

### 3c. Clock period guidance by platform

- **asap7 (7nm)**: 500-1000 ps typical; aggressive designs may reach 300-500 ps
- **nangate45 (45nm)**: 2-10 ns typical
- **sky130hd (130nm)**: 10-50 ns typical

## Step 4: Power Optimization

Power is generally a secondary concern for benchmarking, but some quick wins:

1. **Check for IR drop issues** — Generate an IR drop heatmap (see `.claude/skills/shared/image-generation.md`). If there are hotspots, create or adjust `pdn.tcl` to add power stripes (see `designs/asap7/gemmini/pdn.tcl`).

2. **ABC area optimization** (`ABC_AREA = 1`) reduces cell count, which also reduces dynamic power.

3. **Review power report** in the JSON metrics (`finish__power__total`). Power will naturally decrease as area decreases (higher utilization = smaller die = shorter wires = less capacitance).

## Step 5: Generate Layout Images

For visual diagnosis, generate images using OpenROAD's `save_image` command.

See `.claude/skills/shared/image-generation.md` for the `xvfb-run` setup, Tcl scripts, and heatmap variants (routing congestion, placement density, RUDY, IR drop).

## Step 6: Iterate and Report

After each round of changes, re-run the flow and compare metrics:

```bash
bazel build //designs/<platform>/<design>:<design>_final
```

**Present results as a comparison table:**

```
| Metric       | Baseline | Current  | Change  |
|--------------|----------|----------|---------|
| Utilization  | 35.0%    | 55.0%    | +20%    |
| Die Area     | 12500    | 8200     | -34%    |
| Fmax (GHz)   | 1.25     | 1.42     | +14%    |
| WNS (ns)     | 0.05     | 0.01     | -0.04   |
| Power (mW)   | 45.2     | 38.7     | -14%    |
| DRC errors   | 0        | 0        | clean   |
| GRT overflow | 0        | 0        | clean   |
| Runtime (s)  | 255      | 260      | +2%     |
```

Continue iterating until either:
- Further utilization increases cause unresolvable congestion/DRC
- Further clock tightening causes timing violations that cannot be closed
- The user is satisfied with the achieved PPA

### 6a. Record the sweep in DECISIONS.md

Once the user accepts a result, append the outcome to `designs/src/<design>/DECISIONS.md` under the `## <platform>` section (create the section if it's missing). Capture:
- **An updated Configuration table** reflecting the new knobs that landed.
- **A new dated "Decisions" bullet** describing the sweep — what changed, the per-iteration table (util / SDC / Fmax / area / DRC / runtime) including any failed iterations and why, which Step 0 prior-art DECISIONS.md informed the choices, and the commit hash once you commit.
- **Any new "Known issues / open questions"** discovered along the way (bug workarounds added, plateaus hit, hold-skew limits, etc.). If a new upstream bug was found, also run `/track-bug` to add it to CLAUDE.md's centralized bug table.

The per-iteration table from Step 6's comparison output transplants directly — keep it. Future readers (including the next invocation of this skill) will rely on it as prior art.

**Do not** add the PPA narrative to `CLAUDE.md`. CLAUDE.md's "Build status" is a pure index; per-design narrative lives in DECISIONS.md. Update CLAUDE.md only if a (design, platform) pair moved between the cached / local-only / not-finishing lists.
