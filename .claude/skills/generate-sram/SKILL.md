---
name: generate-sram
description: Generate FakeRAM SRAM macros (LEF, LIB, Verilog) for a design using bsg_fakeram, and verify after synthesis that every memory actually got storage. Use when a design needs custom SRAM macros, when SYNTH_MEMORY_MAX_BITS errors occur, when a memory wrapper or config changes, or when a design has fewer macros or flops than expected.
argument-hint: "[platform] [depth]x[width] [depth]x[width] ..."
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Generate SRAM Macros with bsg_fakeram

You are generating FakeRAM SRAM macros for use in ASIC synthesis. The bsg_fakeram tool is at `tools/bsg_fakeram/` (a git submodule from https://github.com/VLSIDA/bsg_fakeram).

## Arguments

`$ARGUMENTS` should contain:
- **Platform**: `asap7`, `sky130hd`, `nangate45`, or `gt2n`
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
  "snapWidth_nm": 190,
  "snapHeight_nm": 1400
}
```

The snap keys must be camelCase. bsg_fakeram silently ignores snake_case
`snap_width_nm`/`snap_height_nm` and falls back to a 1 nm grid (see the
CLAUDE.md bug table).

### sky130hd
Use `tools/bsg_fakeram/example_cfgs/sky130hd.cfg` as the base config.

### nangate45
Use `tools/bsg_fakeram/example_cfgs/freepdk45.cfg` as the base config (tech_nm: 45, voltage: 1.1).

## Steps

1. **Parse arguments** to extract platform and memory specs (DepthxWidth pairs).

2. **Generate a JSON config file** at `designs/src/<design>/dev/generated/fakeram_<platform>.cfg` (one per platform) using the platform template above. Add each memory to the `srams` array:
   ```json
   {
     "name": "fakeram_<depth>x<width>",
     "width": <width>,
     "depth": <depth>,
     "banks": 1,
     "no_wmask": "true",
     "ports": {"r": 0, "w": 0, "rw": 1}
   }
   ```
   Use the platform-neutral `fakeram_` prefix on every platform (the old `fakeram7_`/`fakeram45_`/`fakeram130_` prefixes were retired in 2026-10), so one wrapper binds on all platforms.

3. **Run `tools/regenerate_sram.sh <design> <platform>`**. It runs bsg_fakeram on the cfg (building CACTI only where needed), replaces everything in `designs/<platform>/<design>/sram/{lef,lib}/` with the new `.lef`/`.lib`, and keeps the behavioral `.v` under `dev/generated/sram/<platform>/`. It refuses a cfg with snake_case snap keys and fails if a generated LEF has the `wd_in` direction bug. Then run `tools/check_sram_cfg.py` (the same lint CI runs): it checks snap keys and that each cfg's macros match its committed LEFs. A regeneration that changes only the LIB `date` line is noise; `git checkout` it.

4. **Check sizes**: `tools/diff_sram_size.sh <design> <platform>` flags area changes over 25 % or aspect changes over 2× against git HEAD. Big macros on sky130hd add up fast (a 64 Kb macro is ~0.76 mm² there).

5. **Report the generated files** and suggest BUILD.bazel additions:
   ```python
   filegroup(name = "sram_lefs", srcs = glob(["sram/lef/*.lef"]))
   filegroup(name = "sram_libs", srcs = glob(["sram/lib/*.lib"]))
   # then in the hightide_design() call:
   sources = {
       "SDC_FILE": [":constraint.sdc"],
       "ADDITIONAL_LEFS": [":sram_lefs"],
       "ADDITIONAL_LIBS": [":sram_libs"],
   },
   ```

6. **Verify after synthesis that every memory has storage (mandatory).** A
   clean flow proves nothing here, so check numbers. Write
   `designs/<platform>/<design>/sram/expected_macros.txt` (one `NAME COUNT`
   per macro, plus `flops >= N` for the memory bits mapped to flip-flops;
   see `designs/asap7/ternip/sram/expected_macros.txt`), build `:<name>_synth`,
   and run:
   ```bash
   tools/check_sram_usage.py <platform> <design>      # e.g. asap7 ternip, sky130hd NVDLA/partition_c
   ```
   It exits 1 if any macro in the design's `ADDITIONAL_LEFS` is never
   instantiated, a count differs from `expected_macros.txt`, or flops fall
   below the floor. Every k8s build runs it too and prints the result under
   `=== SRAM usage check ===` in the pod log (advisory, never fails the job).

## Memories that silently vanish

A memory can disappear with no error. Synthesis then prunes the logic behind
it and every later stage happily closes a hollow design. `SYNTH_MEMORY_MAX_BITS`
does not catch this, because it only checks memories yosys *infers*, and a
memory with no storage infers nothing. Two real cases:

- **ternip (2026-05 → 2026-11)**: the memory wrapper chose a macro with
  `generate if (DATA_WIDTH == … && NUM_ENTRIES == …)` branches and had no
  default branch. A config bump changed every memory shape, nothing matched,
  read data was left undriven, and the design shrank to 0 macros and 2,399
  flops (606,208 memory bits; 71,708 flops once fixed). It ran that way for
  six months with "10 banked SRAMs" in its DECISIONS.md.
- **floonoc ([#254](https://github.com/VLSIDA/HighTide/issues/254))**: an
  empty stub module without `(* blackbox *)` was dissolved by the slang
  frontend and the mesh behind it was constant-folded (~13.7K flops of ~278K).

Rules:

- **Every wrapper that dispatches on parameters ends in an error branch**:
  ```systemverilog
  end else begin : gen_unmapped
      $error("<module>: no FakeRAM mapping for DATA_WIDTH=%0d NUM_ENTRIES=%0d",
             DATA_WIDTH, NUM_ENTRIES);
  end
  ```
  An intentional flip-flop fallback is an explicit branch, never the absence
  of one.
- **Stub modules that stand in for hardware** either carry real logic (the
  macros.v pattern) or `(* blackbox *)`; never leave an empty module body.
- **Compute the shapes from the design's actual config**, not from an old
  DECISIONS.md or a previous wrapper: width and depth at every instantiation
  under the suite's config header/defines. Re-check whenever the config
  changes.
- **After synthesis, compare against expectations** with
  `tools/check_sram_usage.py`, which reads
  `reports/<platform>/<design>/base/synth_stat.txt` and checks:
  - macro instances per macro name == the counts in `expected_macros.txt`;
  - every macro in the design's `ADDITIONAL_LEFS` is instantiated (an
    unused LEF is the classic symptom);
  - flop count ≥ the `flops >=` floor (the memory bits you mapped to
    flip-flops).

  Then judge by eye whether the printed flop count fits the design's size;
  the tool can't (a large accelerator with a few thousand flops is hollow).
  An empty `synth_mocked_memories.txt` does **not** mean the memories exist.
- Record the shapes and their mapping in the design's DECISIONS.md and the
  counts in `sram/expected_macros.txt`, so the next upgrade re-checks them.

## Important Notes

- bsg_fakeram uses VLSIDA's fork with multi-port support (1rw, 1r1w, 2r1w, etc.)
- The `rw` port type creates a single read-write port (standard SRAM interface: ce_in, we_in, addr_in, wd_in, rd_out, clk)
- Pin names for `rw` ports: `rw0_rd_out`, `rw0_addr_in`, `rw0_we_in`, `rw0_wd_in`, `rw0_ce_in`, `rw0_clk`
- Do NOT include the generated `.v` files in the design's `rtl` filegroup — yosys will synthesize the internal reg arrays. Let yosys auto-blackbox undeclared modules instead.
- The design's RTL must instantiate the fakeram module by name with matching port connections.
