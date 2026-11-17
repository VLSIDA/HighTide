---
name: new-design
description: Incorporate a new open-source hardware design into the HighTide benchmark suite. Use when adding a design that doesn't exist yet in the project.
argument-hint: "[design-name] [upstream-repo-url]"
---

# Incorporate a New Design

You are adding a new design called `$0` from upstream repository `$1` into the HighTide benchmark suite.

## Step-by-step Process

### 1. Understand the upstream design

- Clone or browse the upstream repo to understand:
  - What HDL it uses (Verilog, SystemVerilog, Chisel/Scala, LiteX/Python, etc.)
  - The top-level module name and its ports (especially clock, reset, data buses)
  - Whether it has substantial embedded memories (register files, FIFOs, caches, etc.)
  - Any build dependencies needed to generate Verilog (sv2v, sbt, Python venv, etc.)

### 2. Pin the upstream source as a hermetic `http_archive`

RTL is fetched by Bazel from a pinned upstream tarball — **no git
submodule, no vendored copy, no `setup.sh`**. Add an `http_archive` to
the "HighTide design RTL sources" block in the root `MODULE.bazel`:

```python
http_archive(
    name = "$0_src",
    build_file = "//designs/src/$0:external.BUILD.bazel",
    strip_prefix = "<upstream-repo>-<commit-sha>",
    urls = ["https://github.com/<owner>/<repo>/archive/<commit-sha>.tar.gz"],
    sha256 = "<run once with a bogus hash; Bazel prints the real one>",
    # patches = ["//designs/src/$0:0001-fix.patch"],  # declarative source fixes, if needed
)
```

Pin a specific commit SHA (not a branch). See `lfsr_src` in
`MODULE.bazel` for the simplest reference.

### 3. Create `designs/src/$0/external.BUILD.bazel`

This is the BUILD injected into the fetched archive. It exposes the
upstream sources HighTide consumes — as an `:rtl` filegroup directly
(pure Verilog) or as the input files a converter lowers to Verilog.

```python
# Pure-Verilog design — expose the files directly as :rtl
filegroup(
    name = "rtl",
    srcs = ["rtl/$0.v"],   # paths inside the upstream archive
    visibility = ["//visibility:public"],
)
```

If the design needs conversion, expose the raw sources here and do the
conversion under Bazel (step 4). Follow existing patterns:
- **Pure Verilog** — expose `:rtl` directly (see `designs/src/lfsr/external.BUILD.bazel`)
- **SystemVerilog** — expose the `.sv` sources; lower with sv2v under Bazel (see `designs/src/minimax`)
- **Chisel/Scala** — compile + run the emitter with `scala_binary` under `rules_scala`, Maven-pinned chisel3 (see `designs/src/gemmini/BUILD.bazel`)
- **LiteX / migen (Python)** — run the generator as a Bazel `py_binary`, no venv / pip-at-build (see `designs/src/litedram`, `designs/src/liteeth`)
- **Veriloggen / NNgen (Python)** — same, as a `py_binary` generator (see `designs/src/cnn`)

### 4. Create `designs/src/$0/BUILD.bazel`

Carry a stable `:rtl` alias so consumer labels (`//designs/src/$0:rtl`)
never change, regardless of how the RTL is produced:

```python
# Pure Verilog: alias straight to the fetched archive
alias(
    name = "rtl",
    actual = "@$0_src//:rtl",
    visibility = ["//visibility:public"],
)
```

When conversion is needed, point the alias at the local generator target
instead — e.g. a `gen_$0` genrule that runs sv2v or a Chisel/Python
emitter over `@$0_src`, then `actual = ":gen_$0"`. See
`designs/src/gemmini/BUILD.bazel` (Chisel) or `designs/src/cnn/BUILD.bazel`
(Python generator + committed SRAM macros) for richer examples.

### 5. Identify and create FakeRAM black-box memories

Analyze the design's Verilog for any substantial memory arrays. These include:
- Register files, SRAMs, caches, FIFOs with significant depth
- Any module that infers a large memory (typically >32 entries or >256 total bits)

For each memory found, create FakeRAM LEF and LIB files:

**Naming convention:** `fakeram_<width>x<depth>_<ports>.{lef,lib}`
- Ports: `1r1w` (1 read, 1 write), `2r1w` (2 read, 1 write), `1rw` (1 read/write), etc.

**LEF file structure** (see `designs/asap7/nyuzi/sram/lef/` for examples):
- Define a MACRO with CLASS BLOCK
- SIZE should be estimated proportionally to the memory size (use existing FakeRAMs as reference for scaling)
- Include pins for: data input bus, data output bus, address bus(es), write enable, chip enable, clock
- Include VDD/VSS power pins
- Include OBS (obstruction) layers for M1-M4
- Pin placement: distribute signal pins across the macro edges on M3/M4 layers

**LIB file structure** (see `designs/asap7/nyuzi/sram/lib/` for examples):
- Liberty format with timing/power tables
- Define pin groups matching the LEF: data, address, control, clock
- Include setup/hold constraints and clk-to-q delays
- Use placeholder timing values consistent with the technology node

**Place FakeRAM files at:** `designs/<platform>/$0/sram/lef/` and `designs/<platform>/$0/sram/lib/`

The same memory may need different LEF/LIB files per platform due to different metal layer stacks and design rules. Use existing FakeRAM files from the same platform as templates.

### 6. Create platform-specific design directories

For each target platform (start with one, typically asap7), create `designs/<platform>/$0/` with:

**`BUILD.bazel`** (required):
```python
load("//:defs.bzl", "hightide_design")

hightide_design(
    name = "$0",
    top = "$0",          # set if the top module name differs from name
    platform = "<platform>",
    verilog_files = ["//designs/src/$0:rtl"],
    sources = {
        "SDC_FILE": [":constraint.sdc"],
    },
    arguments = {
        "CORE_UTILIZATION": "40",
        "CORE_ASPECT_RATIO": "1.0",
        "CORE_MARGIN": "4",
        "PLACE_DENSITY": "0.7",
        "TNS_END_PERCENT": "100",
    },
)
```

If the design uses FakeRAM, add the LEF/LIB sources and bump halo:
```python
    sources = {
        "SDC_FILE": [":constraint.sdc"],
        "ADDITIONAL_LEFS": [":sram_lefs"],   # filegroup over sram/lef/*.lef
        "ADDITIONAL_LIBS": [":sram_libs"],
    },
    arguments = {
        ...
        "MACRO_PLACE_HALO": "5 5",
    },
```

(`GDS_ALLOW_EMPTY = fakeram.*` is set by `hightide_design()` by default.)

For large designs, consider:
```python
    arguments = {
        ...
        "SYNTH_HIERARCHICAL": "1",
        "ABC_AREA": "1",
    },
```

**`constraint.sdc`** (required):
```tcl
current_design $0

set clk_name  clock
set clk_port_name clk
set clk_period <appropriate_period_ns>
set clk_io_pct 0.2

set clk_port [get_ports $clk_port_name]
create_clock -name $clk_name -period $clk_period $clk_port

set non_clock_inputs [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set_input_delay  [expr $clk_period * $clk_io_pct] -clock $clk_name $non_clock_inputs
set_output_delay [expr $clk_period * $clk_io_pct] -clock $clk_name [all_outputs]
```

Adjust `clk_port_name` and `clk_period` based on the actual design. Check the top-level module ports for the clock signal name. For clock period:
- asap7: typically 500-1000 ps (0.5-1.0 ns)
- nangate45: typically 2-10 ns
- sky130hd: typically 10-50 ns

### 7. Optionally create pdn.tcl and io.tcl

Most designs work fine with platform defaults. These are needed in specific situations:

- **`pdn.tcl`** — Create a custom power delivery network when IR drop violations occur. Use `designs/asap7/gemmini/pdn.tcl` as a reference. This adds extra power stripes on higher metal layers to reduce IR drop.
- **`io.tcl`** — Create custom IO pin placement when the design has a large number of IOs or when there is routing congestion around the IO pins. Use `designs/asap7/gemmini/io.tcl` as a reference. This manually assigns pins to specific die edges and metal layers to spread them out.

**Congestion troubleshooting priority:** It is preferable to keep cell utilization high. If congestion occurs, try fixing IO placement first (`io.tcl`), then adjusting `MACRO_PLACE_HALO`, then `PLACE_PINS_ARGS = -min_distance <N> -min_distance_in_tracks`. Only lower `CORE_UTILIZATION` as a last resort.

### 8. Verify the RTL resolves

Confirm the `:rtl` target fetches and (if needed) generates cleanly:
```bash
bazel build //designs/src/$0:rtl
```
The Verilog is produced hermetically from the pinned `@$0_src` archive —
there is nothing to check in beyond the `external.BUILD.bazel` /
`BUILD.bazel` wiring (and any declarative `patches`).

### 9. Test the flow

```bash
bazel build //designs/<platform>/$0:$0_final
```

For incremental work, build a single stage instead of the full flow:
```bash
bazel build //designs/<platform>/$0:$0_synth
bazel build //designs/<platform>/$0:$0_place
```

### 10. Port to additional platforms

Repeat step 6 for nangate45 and sky130hd as needed. Each platform needs its own:
- `BUILD.bazel` (adjust utilization/density for the technology)
- `constraint.sdc` (adjust clock period for the technology)
- `sram/` directory with platform-specific FakeRAM files (if applicable)

### 11. Create DECISIONS.md

Create `designs/src/$0/DECISIONS.md` with one `## <platform>` section per technology this design targets. Use `designs/src/gemmini/DECISIONS.md` as the canonical template (header + per-variant table + per-platform sections).

Each platform section should capture:
- **Status**: `finishing` or `not yet finishing`
- **Configuration**: a table of every non-default `BUILD.bazel` `arguments` knob, the SDC clock period, and which `pdn.tcl` / `io.tcl` / `pre_cts.tcl` files are wired in.
- **Decisions**: dated bullet list of the non-obvious calls made (why this utilization, why this SDC, what congestion / IR / timing surfaces you fought), with commit hashes.
- **Known issues / open questions**: active workarounds, anything pending.

For pre-existing designs that need a DECISIONS.md retroactively, the `update-design --init-decisions <design>` skill bootstraps a starter file from git history + BUILD.bazel + SDC.

**Do not** add the new design's narrative to `CLAUDE.md`. CLAUDE.md's "Build status" is a pure index of which (design, platform) pairs reach `_final`; per-design narrative belongs in DECISIONS.md. Update CLAUDE.md only to add the design to the Platforms table and to the appropriate status list (cached / local-only / not-finishing).
