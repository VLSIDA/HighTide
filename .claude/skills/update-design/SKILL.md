---
name: update-design
description: Check for upstream updates to existing HighTide designs and tools, summarize what changed, apply updates, and keep the per-design DECISIONS.md (designs/src/<design>/DECISIONS.md) in sync — recording bug workarounds, manual macro/IO placement, timing-constraint choices, utilization tuning, and any other non-obvious decisions, with one section per technology. Use when a design needs to be refreshed, with no arguments to audit all designs for available updates, or with `--init-decisions <design>` to bootstrap a new DECISIONS.md from existing git history + BUILD.bazel + SDC.
argument-hint: "[design-name or 'all'] [platform]"
---

# Update an Existing Design

If `$ARGUMENTS` is empty or `all`, run the **Upstream Audit** first. Otherwise, you are updating the design `$0` on platform `$1` — determine what kind of update is needed by asking the user or inferring from context.

**Always** also keep `designs/src/$0/DECISIONS.md` in sync — see the **Decisions Document** section below for the file shape, where to record what, and the bootstrap workflow for designs that don't have one yet.

## Upstream Audit

Check all designs and their tool dependencies for upstream changes. Present a summary so the user can decide what's worth updating.

### 1. Audit design source pins

Every design's upstream source is a hermetic `http_archive` in the root
`MODULE.bazel` (`@<design>_src`, plus shared deps such as the PULP
`@pulp_*_src` / `@snitch_*_src` archives) — there are no design git
submodules and no vendored RTL. The pinned commit is the SHA in the
archive's `urls` / `strip_prefix`:

```bash
# List every source pin: repo name, upstream URL (commit SHA embedded)
grep -n -A6 '^http_archive(' MODULE.bazel | grep -E 'name =|urls ='

# Upstream latest for one archive (owner/repo from its URL)
git ls-remote https://github.com/<owner>/<repo>.git HEAD
gh api repos/<owner>/<repo>/compare/<pinned-sha>...HEAD --jq '.ahead_by, (.commits[].commit.message | split("\n")[0])'
```

Worked example (ternip — plain SystemVerilog read by yosys-slang, plus a
shared `@basejump_stl_src` dependency):

```bash
grep -n -A5 'name = "ternip_src"' MODULE.bazel
#   urls = [".../sifferman/ternip/archive/187957b57e2a....tar.gz"]
gh api repos/sifferman/ternip/compare/187957b57e2a0d4f74374a354e189d158a38ba13...HEAD \
  --jq '.ahead_by, .commits[-1].commit.committer.date'
```

Archives pinned to a release tarball (e.g. `sv2v`) or a Maven/PyPI version
are audited in step 2 instead.

For each pin that has new commits upstream, summarize:
- **Design name** and upstream repo URL
- **Commits behind**: `ahead_by` from the compare API
- **Recency**: date of the most recent upstream commit
- **Extent of changes**: the compare API commit list (or `git log --oneline <pinned>..HEAD` in a scratch clone). Categorize as:
  - **Minor**: documentation, CI, test-only changes, cosmetic fixes
  - **Moderate**: bug fixes, small feature additions, dependency bumps
  - **Major**: new features, architectural changes, API/interface changes, new memory modules
- **Patches at risk**: if the archive carries `patches = [...]`, note whether upstream touched the patched files (the patches may no longer apply)
- **Recommendation**: whether the changes are likely to affect generated RTL or just ancillary files

### 2. Audit RTL-generation tool pins

Converters are pinned in `MODULE.bazel`, not installed by a `setup.sh`:
- **Python generators** (LiteX / migen / liteeth / litedram / litepcie, NNgen, floogen, snitch clustergen): the `pip.parse(...)` hubs and their `requirements_lock.txt` files, and any generator shipped as its own `http_archive` — check for newer upstream commits / PyPI releases
- **Chisel / Scala** (gemmini, sha3, coralnpu): the `maven.install(...)` artifact versions, `scala_config`, and the `rules_chisel` / firtool pin
- **sv2v**: the pinned release archive (`name = "sv2v"`)
- **yosys-slang** (SystemVerilog read directly by synthesis): pinned via `//:yosys_slang.bzl`; bumps go through `/upgrade-tools`

Summarize each with the same minor/moderate/major classification.

### 3. Audit the EDA toolchain pin

ORFS / OpenROAD / OpenSTA / Yosys are pinned by the `bazel-orfs` submodule;
the root `MODULE.bazel` mirrors bazel-orfs's root-only overrides
(`archive_override(module_name = "orfs", ...)` etc.). Report how far the
pin is behind, but **do not bump it here** — toolchain bumps are the
`/upgrade-tools` skill's job (it re-validates every passing design and
drops fixed-bug workarounds).

```bash
git -C bazel-orfs rev-parse --short HEAD
git ls-remote https://github.com/The-OpenROAD-Project/bazel-orfs.git HEAD
```

### 4. Present summary table

Format the results as a table:

```
| Design/Tool        | Pinned     | Upstream   | Behind | Last Activity | Severity | Recommendation     |
|--------------------|------------|------------|--------|---------------|----------|--------------------|
| minimax            | cb62251    | def5678    | 12     | 2026-02-15    | Moderate | Bug fixes, review  |
| ternip             | 187957b    | 1a2b3c4    | 45     | 2026-03-10    | Major    | New features       |
| verilog-lfsr       | 789abcd    | 789abcd    | 0      | 2025-01-03    | -        | Up to date         |
| litex (pip lock)   | a25eeec    | b36ff0d    | 8      | 2026-03-12    | Minor    | Docs only          |
| bazel-orfs         | 6c1bbca    | 9f0e1d2    | 40     | 2026-03-14    | Major    | → /upgrade-tools   |
```

Let the user decide which updates to apply. Small changes that don't affect RTL generation (docs, tests, CI) are usually not worth updating for. Major changes that affect RTL output, fix synthesis bugs, or add new features are worth considering.

## Decisions Document

Every design has a long-form decisions log at `designs/src/<design>/DECISIONS.md` (one file per design — variants share it via sub-sections).  This is the place where non-obvious tuning choices, workaround rationale, and platform-specific gotchas live.  The file complements but **does not duplicate**:

- **CLAUDE.md "Known OpenROAD / yosys-slang bug workarounds" table** — the canonical bug index.  DECISIONS.md cross-links to specific rows there rather than restating the bug.
- **BUILD.bazel `arguments = { … }`** — the live config.  DECISIONS.md records *why* an argument has the value it does, not the value itself.
- **`constraint.sdc` comments** — the live constraints.  DECISIONS.md records *why* a clock period or `set_false_path` was chosen.

### When to record a decision

Update `designs/src/<design>/DECISIONS.md` whenever any of these change:

- A bug workaround lands in BUILD.bazel (`PRE_CTS_TCL`, `SKIP_*`, `SETUP_MOVE_SEQUENCE` trim, etc.) — link to the CLAUDE.md row.
- The clock period changes — record before/after Fmax and the period_min that motivated the change.
- A `macros.tcl`, `io.tcl`, `pdn.tcl`, or `*_pre_*.tcl` is added.
- Utilization, density addon, or macro halo gets a non-default value.
- A platform-specific FakeRAM tweak is needed.
- Synthesis is hierarchical / uses `SYNTH_HIERARCHICAL`, with a reason.
- A platform is marked "not yet finishing" (record what's been tried and what blocks closure).
- An optimization-PPA pass moves the QoR more than ~5% in any axis.

The other HighTide skills (`/debug-design`, `/optimize-ppa`, `/port-design`, `/track-bug`) should each append to this file when their work touches one of the above triggers.

### File shape

```markdown
# <design> Design Decisions

Per-platform notes on tuning, workarounds, and platform-specific
quirks for <design>.  See CLAUDE.md (root) for the canonical
upstream-bug index; this file cross-links to it.

## asap7

**Status**: finishing | not finishing | failing-timing | partial
**Last updated**: 2026-05-08 (commit a1b2c3d)

### Configuration
- `CORE_UTILIZATION = N` — <one-line why this value>
- `PLACE_DENSITY_LB_ADDON = X` — <reason>
- Clock: `<N> ns` (Fmax `<X>` MHz) — <reason>
- Active workarounds: link to CLAUDE.md rows by error code

### Decisions
- **YYYY-MM-DD `<short-sha>`**: one-line summary of the decision and its motivation, with PR or issue reference where applicable.
- **YYYY-MM-DD `<short-sha>`**: …

### Known issues / open questions
- One bullet per known limitation, e.g. "DRC-clean but Fmax limited by macro→macro cross-die paths; manual macros.tcl might unlock further."

## nangate45

…

## sky130hd

…
```

For multi-variant designs (NVDLA, liteeth, bp_processor), each platform's section gets variant sub-sections:

```markdown
## sky130hd

### partition_a
…
### partition_c
**Status**: not finishing — GP overflow plateaus at 0.31, see CLAUDE.md.
…
```

### Bootstrap workflow (`--init-decisions <design>`)

If the file doesn't exist yet, build it from already-committed history rather than asking the user from scratch:

1. **Find the design's commits**:
   ```bash
   git log --oneline --reverse -- "designs/*/$design/" "designs/src/$design/"
   ```

2. **For each platform**, derive the live configuration:
   - Read `designs/<platform>/<design>/BUILD.bazel` → `arguments`, `sources`.
   - Read `designs/<platform>/<design>/constraint.sdc` → clock period, `set_false_path` lines, IO delay constants.
   - Note any `pdn.tcl` / `io.tcl` / `macros.tcl` / `*pre*.tcl` files that exist.

3. **Pull bug links from CLAUDE.md**: any row in the workarounds table whose "Affected designs" cell mentions this design becomes a "Active workarounds" bullet in the matching platform section, with the issue link copied verbatim.

4. **Pull historical decisions from git log**: scan commit messages on files in `designs/<platform>/<design>/` and `designs/src/<design>/`.  Promote commits that match these patterns to "Decisions" entries:
   - "Relax", "Tighten", "Bump", "Drop", "Switch", "Disable", "Enable" + clock/util/density/halo terms.
   - Anything tagged `Fix`, `Workaround`, `Skip`.
   - Initial port commits (first `Add … on <platform>` for each platform).

5. **Drop decisions older than 1 year** unless they're still load-bearing (e.g. the clock period chosen at port still in effect).  The doc is a working memory, not a changelog.

6. **Show the user the proposed file before writing**, especially when the inferred reasoning is uncertain — they may have context that didn't make it into commit messages.

### Updating an existing decisions file

Each invocation of `/update-design <design> <platform>` that touches the live config should also append (or replace) entries under that platform's **Decisions** list with the current commit short-sha.  Don't rewrite history — append a new dated bullet, and update the platform section's `**Last updated**` line.

If the only change is regenerating RTL from upstream with no flow-config impact, no DECISIONS.md update is needed (the upstream audit table is enough).

## Types of Updates

### A. Update upstream source (new RTL from upstream repo)

1. **Re-pin the `http_archive` in `MODULE.bazel`:** point the `@$0_src`
   archive's `urls` (and `strip_prefix`) at the new commit SHA. Set
   `sha256` to a bogus value, run the build once, and paste the real
   hash Bazel prints back into the stanza. E.g. for ternip, replace both
   occurrences of `187957b57e2a…` in the `ternip_src` stanza. Shared
   dependency archives (ternip's `@basejump_stl_src`, the PULP
   `@pulp_*_src` set used by floonoc/snitch_cluster) are re-pinned the
   same way — check every design that consumes them.

2. **Check declarative patches still apply:** if the `http_archive` has
   `patches = [...]`, a re-fetch against the new sources may fail to
   apply them. Refresh or drop patches as needed.

3. **Re-fetch and regenerate RTL:**
   ```bash
   bazel build //designs/src/$0:rtl
   ```
   Bazel re-fetches the archive and re-runs any converter (sv2v / Chisel
   emitter / Python generator). There is no `dev/generated` cache to
   clean and nothing to check in.

4. **Check for new or changed memories:**
   - Compare the new RTL against the old to identify any new memory modules
   - If new memories are found, add them to `designs/src/$0/dev/generated/fakeram_<platform>.cfg` and regenerate with `tools/regenerate_sram.sh $0 <platform>` (see section D and `/generate-sram`)
   - Update the design's `BUILD.bazel` `sources` dict (`ADDITIONAL_LEFS` / `ADDITIONAL_LIBS` filegroups) if new FakeRAM files were added

5. **Check if the RTL file set changed:**
   - If the converter now emits different Verilog paths (or the upstream layout moved), update the `:rtl` filegroup in `designs/src/$0/external.BUILD.bazel` and any generator `outs` in `designs/src/$0/BUILD.bazel`.

6. **Test the flow:**
   ```bash
   # Build :<design>_gallery (not :<design>_final) so the layout PNG gets
   # rendered and cached too — update-results becomes a pure cache fetch.
   bazel build //designs/$1/$0:$0_gallery
   ```
   Run one platform at a time on the local machine — these can be big
   designs and parallel platform builds may exhaust memory.

7. **Refresh the webpage (once, before opening the PR):** after every
   supported platform for this design has built green (whichever of
   asap7 / nangate45 / sky130hd / gt2n the design has), run the `/update-results` skill **once**
   so `webpage/results.html`, the Design Portfolio badges in
   `webpage/index.html`, `webpage/gallery.html`, and the per-row layout
   PNGs in `webpage/figures/` reflect the new builds together. Commit
   the webpage diff as part of the PR for the design bump — not after
   each individual platform build.

### B. Update conversion tools (Chisel/Maven, Python packages, sv2v, etc.)

Conversion tools are pinned in Bazel, not installed by a `setup.sh`, so a
tool bump is a pin bump in `MODULE.bazel` (or the design's build files):

1. **Bump the relevant pin:**
   - **Chisel/Scala** — the Maven coordinates in the `maven_chisel` install
   - **LiteX / migen / NNgen (Python)** — the `pip_*` hub lock, or the tool's own `http_archive`
   - **sv2v** — the pinned `sv2v` release archive

2. **Regenerate and verify:**
   ```bash
   bazel build //designs/src/$0:rtl
   ```
   Confirm the generated Verilog still builds through the flow.

### C. Tune flow parameters (timing, utilization, density)

1. **Read current config:**
   - `designs/$1/$0/BUILD.bazel`
   - `designs/$1/$0/constraint.sdc`
   - Check recent flow reports in `bazel-bin/designs/$1/$0/reports/$1/$0/base/` if available

2. **Congestion troubleshooting priority:**
   It is preferable to keep cell utilization high. If there are congestion problems, try these before lowering utilization:
   - First, fix IO pin placement — create or adjust `io.tcl` to spread pins and reduce congestion near IO (see `designs/asap7/gemmini/io.tcl` for reference). Set `IO_CONSTRAINTS` and `FOOTPRINT_TCL` in the BUILD.bazel `arguments` dict.
   - Second, adjust `MACRO_PLACE_HALO` — increase spacing around macros to give the router more room (e.g., `5 5` or `6 6`).
   - Third, try `PLACE_PINS_ARGS = -min_distance <N> -min_distance_in_tracks` to spread auto-placed pins.
   - Only as a last resort, lower `CORE_UTILIZATION` or `PLACE_DENSITY`.

3. **Common adjustments in `BUILD.bazel` `arguments`:**
   - `CORE_UTILIZATION` — Prefer keeping this high; only lower as a last resort for congestion
   - `PLACE_DENSITY` — Affects routing congestion (0.6-0.8 typical)
   - `CORE_AREA` / `DIE_AREA` — For explicit die size control instead of utilization-based
   - `PLACE_DENSITY_LB_ADDON` — Additional placement density lower bound
   - `MACRO_PLACE_HALO` — Spacing around macros (increase if DRC errors or congestion near macros)
   - `ABC_AREA = 1` — Optimize for area in synthesis
   - `SYNTH_HIERARCHICAL = 1` — For large designs that need hierarchical synthesis

3. **Common adjustments in `constraint.sdc`:**
   - Clock period — Relax if timing violations, tighten if design can run faster
   - IO delay percentage (`clk_io_pct`) — Adjust input/output timing margin

4. **Test:**
   ```bash
   bazel build //designs/$1/$0:$0_gallery
   ```
   One platform at a time on the local machine. (Bazel re-runs only
   affected stages when arguments or sources change.)

5. **Refresh the webpage (once, before opening the PR):** once every
   affected platform has built green, run `/update-results` a single
   time and commit the webpage diff alongside the parameter change in
   the same PR.

### D. Add FakeRAM for newly identified memories

1. **Identify memory modules** in the design's Verilog that should be black-boxed:
   - Large register files, SRAMs, caches, deep FIFOs
   - Typically >32 entries or >256 total bits

2. **Generate LEF and LIB with bsg_fakeram** (never hand-edit a template —
   see `/generate-sram`):
   - Add one entry per macro to `designs/src/$0/dev/generated/fakeram_$1.cfg`
     (width / depth / banks / ports / `no_wmask`). asap7 cfgs must use the
     camelCase `snapWidth_nm` / `snapHeight_nm` keys (see the snap-grid row
     in CLAUDE.md's bug table).
   - Run `tools/regenerate_sram.sh $0 $1`; it copies the result into
     `designs/$1/$0/sram/{lef,lib}/`. ternip is the minimal example: one
     `fakeram7_512x16` entry in `designs/src/ternip/dev/generated/fakeram_asap7.cfg`.
   - Review the size change with `tools/diff_sram_size.sh $0 $1` and confirm
     no `*_wd_in` pin is `DIRECTION OUTPUT` in the LEF.
   - Memories below the generator's range (depth ≤ 16, very narrow, < ~1 Kb)
     get a behavioural Verilog stub in the `:rtl` filegroup instead and are
     synthesized as flip-flops (see NVDLA `gen_ff_rams.py`, vortex
     `designs/src/vortex/VX_dp_ram.sv`).

3. **Update `BUILD.bazel`** to reference the new FakeRAM files:
   ```python
   filegroup(name = "sram_lefs", srcs = glob(["sram/lef/*.lef"]))
   filegroup(name = "sram_libs", srcs = glob(["sram/lib/*.lib"]))

   hightide_design(
       ...
       sources = {
           "SDC_FILE": [":constraint.sdc"],
           "ADDITIONAL_LEFS": [":sram_lefs"],
           "ADDITIONAL_LIBS": [":sram_libs"],
       },
       arguments = {
           ...
           "MACRO_PLACE_HALO": "5 5",
       },
   )
   ```
   (`GDS_ALLOW_EMPTY = fakeram.*` is the default from `hightide_design()`.)

4. **Swap the memory for the macro in the RTL** — as a declarative patch on
   the `http_archive` (NyuziProcessor's fakeram-swap patch) or by excluding
   the behavioural module from the `:rtl` filegroup — so synthesis
   instantiates the black-box macro instead.

### E. Port to a new platform

Prefer the `/port-design` skill, which calibrates clock/area scaling from
designs already on both platforms. The minimal manual steps are:

1. **Create the platform directory:**
   ```bash
   mkdir -p designs/<new-platform>/$0
   ```

2. **Copy and adapt from an existing platform:**
   - `BUILD.bazel` — Change `platform`, adjust utilization/density `arguments` for the new technology
   - `constraint.sdc` — Adjust clock period for the technology node
   - `sram/` — Create platform-specific FakeRAM files if needed (different metal stacks and design rules per platform)

3. **Platform-specific clock period guidance:**
   - asap7 (7nm): 500-1000 ps
   - nangate45 (45nm): 2-10 ns
   - sky130hd (130nm): 10-50 ns
   - gt2n (2nm nanosheet, backside PDN): 400-1600 ps; no OpenRCX rules and no antenna cells — see an existing gt2n DECISIONS.md section (e.g. `designs/src/sha3/DECISIONS.md`)

4. **Test the new platform:**
   ```bash
   bazel build //designs/<new-platform>/$0:$0_gallery
   ```
   One platform at a time on the local machine.

5. **Refresh the webpage (once, before opening the PR):** once the new
   platform has built green, run `/update-results` a single time so the
   new platform shows up in `webpage/results.html` + Design Portfolio
   badges, and commit the webpage diff with the port in the same PR.

## General Notes

- Flow outputs go to `bazel-bin/designs/$1/$0/{logs,objects,reports,results}/$1/$0/base/`.
- Bazel caches per-stage outputs; arguments / sources changes invalidate only the affected stages automatically — no manual clean needed.
- To force a single design's results to re-run, change an argument in its `BUILD.bazel` or pass `--strategy=<target>=local`. **Never** `bazel clean --expunge` — synthesis takes hours.
