---
name: new-design
description: Incorporate a new open-source hardware design into the HighTide2 benchmark suite. Use when adding a design that doesn't exist yet in the project.
argument-hint: "[design-name] [upstream-repo-url]"
---

# Incorporate a New Design

You are adding a new design called `$0` from upstream repository `$1` into the HighTide2 benchmark suite.

## Step-by-step Process

### 1. Understand the upstream design

- Clone or browse the upstream repo to understand:
  - What HDL it uses (Verilog, SystemVerilog, Chisel/Scala, LiteX/Python, etc.)
  - The top-level module name and its ports (especially clock, reset, data buses)
  - Whether it has substantial embedded memories (register files, FIFOs, caches, etc.)
  - Any build dependencies needed to generate Verilog (sv2v, sbt, Python venv, etc.)

### 2. Add the git submodule

```bash
git submodule add <UPSTREAM_URL> designs/src/$0/dev/repo
```

### 3. Create `designs/src/$0/dev/setup.sh`

This script must:
- `cd` to its own directory: `cd "$(dirname $(readlink -f $0))"`
- Install any required build tools locally if not present (sv2v, JDK, Python venv, etc.)
- Generate flat Verilog from the upstream source
- Place the output at a known location (e.g., `dev/generated/$0.v` or `dev/$0.v`)

The setup.sh must install all dependencies needed to convert the source HDL to plain Verilog. Follow existing patterns:
- **SystemVerilog designs**: Use either sv2v (see `designs/src/minimax/dev/setup.sh`) or yosys-slang. The setup.sh must build/install the chosen tool locally if not present.
- **Pure Verilog designs**: May just need file copying (see `designs/src/lfsr_prbs_gen/dev/setup.sh`)
- **Chisel/Scala designs**: Install JDK + sbt locally, run sbt to generate Verilog (see `designs/src/gemmini/dev/setup.sh`)
- **LiteX/Python designs**: Create Python venv, pip install all dependencies, generate Verilog (see `designs/src/liteeth/dev/setup.sh`)
- **Veriloggen/Python designs**: Create Python venv, pip install dependencies including Veriloggen/NNgen, generate Verilog (see `designs/src/cnn/dev/setup.sh`)

### 4. Create `designs/src/$0/verilog.mk`

This file controls RTL selection between dev-generated and release Verilog. Use one of these patterns:

**Simple single-file design:**
```makefile
ifneq ($(wildcard $(DEV_FLAG)),)
export VERILOG_FILES = $(BENCH_DESIGN_HOME)/src/$0/dev/generated/$0.v
else
export VERILOG_FILES = $(BENCH_DESIGN_HOME)/src/$0/$0.v
endif
```

**Multi-file design (wildcard):**
```makefile
ifneq ($(wildcard $(DEV_FLAG)),)
export VERILOG_FILES = $(wildcard $(BENCH_DESIGN_HOME)/src/$0/dev/repo/rtl/*.v)
else
export VERILOG_FILES = $(wildcard $(BENCH_DESIGN_HOME)/src/$0/*.v)
endif
```

### 5. Identify and create FakeRAM black-box memories

Analyze the design's Verilog for any substantial memory arrays. These include:
- Register files, SRAMs, caches, FIFOs with significant depth
- Any module that infers a large memory (typically >32 entries or >256 total bits)

For each memory found, create FakeRAM LEF and LIB files:

**Naming convention:** `fakeram_<width>x<depth>_<ports>.{lef,lib}`
- Ports: `1r1w` (1 read, 1 write), `2r1w` (2 read, 1 write), `1rw` (1 read/write), etc.

**LEF file structure** (see `designs/asap7/NyuziProcessor/sram/lef/` for examples):
- Define a MACRO with CLASS BLOCK
- SIZE should be estimated proportionally to the memory size (use existing FakeRAMs as reference for scaling)
- Include pins for: data input bus, data output bus, address bus(es), write enable, chip enable, clock
- Include VDD/VSS power pins
- Include OBS (obstruction) layers for M1-M4
- Pin placement: distribute signal pins across the macro edges on M3/M4 layers

**LIB file structure** (see `designs/asap7/NyuziProcessor/sram/lib/` for examples):
- Liberty format with timing/power tables
- Define pin groups matching the LEF: data, address, control, clock
- Include setup/hold constraints and clk-to-q delays
- Use placeholder timing values consistent with the technology node

**Place FakeRAM files at:** `designs/<platform>/$0/sram/lef/` and `designs/<platform>/$0/sram/lib/`

The same memory may need different LEF/LIB files per platform due to different metal layer stacks and design rules. Use existing FakeRAM files from the same platform as templates.

### 6. Create platform-specific design directories

For each target platform (start with one, typically asap7), create `designs/<platform>/$0/` with:

**`config.mk`** (required):
```makefile
export DESIGN_NAME = $0
export PLATFORM    = <platform>

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SDC_FILE         = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc
export CORE_UTILIZATION = 40
export CORE_ASPECT_RATIO = 1.0
export CORE_MARGIN      = 4
export PLACE_DENSITY    = 0.7
export TNS_END_PERCENT  = 100
```

If the design uses FakeRAM, add:
```makefile
export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/*.lef
export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/*.lib
export GDS_ALLOW_EMPTY = fakeram*
export MACRO_PLACE_HALO = 5 5
```

For large designs, consider:
```makefile
export SYNTH_HIERARCHICAL = 1
export ABC_AREA = 1
```

If DESIGN_NAME differs from the source directory name (e.g., multi-variant designs), set:
```makefile
export DESIGN_NICKNAME = $0
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

### 8. Generate and check in release RTL

Run the dev flow to generate Verilog, then copy it to the release location:
```bash
# Generate via dev mode
make DESIGN_CONFIG=./designs/<platform>/$0/config.mk dev

# Copy generated RTL to release location
cp designs/src/$0/dev/generated/$0.v designs/src/$0/$0.v
```

### 9. Update the Makefile design list

Add a comment line for the new design in the Makefile header:
```makefile
# DESIGN_CONFIG=./designs/<platform>/$0/config.mk
```

### 10. Test the flow

```bash
# Test with release RTL
make DESIGN_CONFIG=./designs/<platform>/$0/config.mk

# Test with dev RTL generation
make DESIGN_CONFIG=./designs/<platform>/$0/config.mk dev
```

Use `./runorfs_ni.sh` prefix if running via Docker non-interactively.

### 11. Port to additional platforms

Repeat step 6 for nangate45 and sky130hd as needed. Each platform needs its own:
- `config.mk` (adjust utilization/density for the technology)
- `constraint.sdc` (adjust clock period for the technology)
- `sram/` directory with platform-specific FakeRAM files (if applicable)
