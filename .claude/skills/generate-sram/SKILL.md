---
name: generate-sram
description: Generate FakeRAM SRAM macros (LEF, LIB, Verilog) for a design using bsg_fakeram. Use when a design needs custom SRAM macros for synthesis, or when SYNTH_MEMORY_MAX_BITS errors occur.
argument-hint: "[platform] [depth]x[width] [depth]x[width] ..."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Generate SRAM Macros with bsg_fakeram

You are generating FakeRAM SRAM macros for use in ASIC synthesis. The bsg_fakeram tool is at `tools/bsg_fakeram/` (a git submodule from https://github.com/VLSIDA/bsg_fakeram).

## Arguments

`$ARGUMENTS` should contain:
- **Platform**: `asap7`, `sky130hd`, or `nangate45`
- **Memory specs**: One or more `DepthxWidth` pairs (e.g., `64x512 256x64 128x37`)
- **Optional**: Port config like `1rw` (default), `1r1w`, `2r1w`

Example: `/generate-sram asap7 64x512 256x64`

## Platform Configurations

Use these technology parameters based on platform:

### asap7
```json
{
  "tech_nm": 7,
  "voltage": 0.7,
  "metalPrefix": "M",
  "LRpinWidth_nm": 24,
  "LRpinPitch_nm": 48,
  "TBpinWidth_nm": 18,
  "TBpinPitch_nm": 36,
  "manufacturing_grid_nm": 1,
  "contacted_poly_pitch_nm": 54,
  "column_mux_factor": 3,
  "fin_pitch_nm": 27,
  "flipPins": false,
  "snap_width_nm": 190,
  "snap_height_nm": 1400
}
```

### sky130hd
Use `tools/bsg_fakeram/example_cfgs/sky130hd.cfg` as the base config.

### nangate45
Use `tools/bsg_fakeram/example_cfgs/freepdk45.cfg` as the base config (tech_nm: 45, voltage: 1.1).

## Steps

1. **Parse arguments** to extract platform and memory specs (DepthxWidth pairs).

2. **Generate a JSON config file** at `designs/src/<design>/dev/generated/fakeram.cfg` using the platform template above. Add each memory to the `srams` array:
   ```json
   {
     "name": "fakeram7_<depth>x<width>",
     "width": <width>,
     "depth": <depth>,
     "banks": 1,
     "no_wmask": "true",
     "ports": {"r": 0, "w": 0, "rw": 1}
   }
   ```
   Use `fakeram7_` prefix for asap7, `fakeram45_` for nangate45, `fakeram130_` for sky130hd.

3. **Ensure cacti is built**: Check if `tools/bsg_fakeram/tools/cacti/cacti` exists. If not, run `cd tools/bsg_fakeram && make tools`.

4. **Run the generator**:
   ```bash
   cd tools/bsg_fakeram && python3 scripts/run.py <config_path> --output_dir <output_dir>
   ```
   Output directory should be `designs/src/<design>/dev/generated/sram/`.

5. **Copy outputs** to the design's platform directory or keep in `generated/sram/`:
   - `<name>/<name>.lef` → LEF file
   - `<name>/<name>.lib` → Liberty file
   - `<name>/<name>.v` → Verilog behavioral model

6. **Report the generated files** and suggest config.mk additions:
   ```makefile
   export ADDITIONAL_LEFS = path/to/<name>.lef
   export ADDITIONAL_LIBS = path/to/<name>.lib
   ```

## Important Notes

- bsg_fakeram uses VLSIDA's fork with multi-port support (1rw, 1r1w, 2r1w, etc.)
- The `rw` port type creates a single read-write port (standard SRAM interface: ce_in, we_in, addr_in, wd_in, rd_out, clk)
- Pin names for `rw` ports: `rw0_rd_out`, `rw0_addr_in`, `rw0_we_in`, `rw0_wd_in`, `rw0_ce_in`, `rw0_clk`
- Do NOT include the generated `.v` files in `VERILOG_FILES` — yosys will synthesize the internal reg arrays. Let yosys auto-blackbox undeclared modules instead.
- The design's RTL must instantiate the fakeram module by name with matching port connections.
