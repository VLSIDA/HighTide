---
name: find-designs
description: Search for new open-source hardware designs that would be good candidates for the HighTide2 benchmark suite and open GitHub issues to propose them.
argument-hint: "[optional: category or keyword to focus on, e.g. 'processors', 'accelerators', 'peripherals']"
---

# Find New Benchmark Designs

Search for interesting open-source hardware designs that would be good additions to the HighTide2 benchmark suite, then open GitHub issues to propose adding them.

## Selection Criteria

A good candidate design must meet ALL of these:
- **Open-source license** — Publicly available on GitHub with a permissive or copyleft license (MIT, Apache 2.0, BSD, GPL, LGPL, etc.)
- **Synthesizable RTL** — Verilog, SystemVerilog, Chisel, LiteX/Migen, Veriloggen, SpinalHDL, Amaranth, or another HDL convertible to plain Verilog
- **Verification framework** — Must have a testbench or verification environment (e.g., cocotb, UVM, verilator sim, formal proofs, or at least a basic testbench) so that we can verify post-synthesis functionality

And should meet at least one of these motivations:
1. **Active development** — The project is actively maintained with recent commits, indicating a living design that the suite should track
2. **New design language** — Written in an HDL not yet represented in the suite (current languages: Verilog, SystemVerilog, Chisel/Scala, LiteX/Python, Veriloggen/Python). Adding e.g. SpinalHDL, Amaranth, Clash, or other emerging HDLs increases conversion coverage.
3. **New architecture** — Represents a design style or architecture not already covered (e.g., out-of-order processor, GPU, NoC, systolic array variant, hardware security module, etc.)
4. **Industry-relevant** — Something commonly seen in real chip designs (e.g., USB controller, PCIe endpoint, DDR controller, standard bus interconnect, crypto engine) that makes the benchmark suite representative of production workloads

## Design Categories to Consider

- **Processors**: RISC-V cores (various pipeline depths), GPUs, DSPs
- **Accelerators**: ML/AI accelerators, cryptographic engines, signal processing, compression
- **Peripherals**: Network controllers (Ethernet, USB, PCIe, SPI, I2C, UART), memory controllers, DMA engines
- **SoC components**: Bus interconnects, cache hierarchies, interrupt controllers
- **Domain-specific**: Video/image processing, audio, software-defined radio

## Current Designs (do NOT propose duplicates)

Check the existing designs before proposing:
- gemmini (ML systolic array accelerator)
- minimax (RISC-V core)
- NyuziProcessor (RISC processor)
- lfsr (LFSR/PRBS generator)
- liteeth (Ethernet MAC, multiple variants)
- cnn (CNN accelerator via NNgen/Veriloggen)
- sha3 (SHA3 hash, in progress)

Also check open GitHub issues for already-proposed designs:
```bash
gh issue list --state open --limit 50
```

## Search Process

1. **Search the web** for open-source hardware designs using queries like:
   - "open source RISC-V core github synthesizable"
   - "open source hardware accelerator RTL github"
   - "open source FPGA IP core verilog"
   - Site-specific: "site:github.com FPGA verilog core"
   - If the user provided a category focus (`$ARGUMENTS`), tailor searches to that area

2. **Evaluate each candidate** against the selection criteria above. For each promising design, check:
   - The GitHub repo: stars, activity, license, documentation quality
   - RTL source availability and language (Verilog/SV/Chisel/etc.)
   - Top-level module ports (clock, reset, data buses) — is it self-contained enough to run through ORFS?
   - Memory usage — does it have large SRAMs that would need FakeRAM?
   - Approximate size/complexity
   - Verification: what test/verification framework is available (cocotb, UVM, verilator, formal, basic testbench, etc.)

3. **Check for duplicates** against both the existing designs in the repo AND open GitHub issues.

## Opening Issues

For each viable candidate, open a GitHub issue:

```bash
gh issue create --title "Add <design-name>" --label "enhancement" --body "$(cat <<'ISSUE_EOF'
## Design: <design-name>

**Repository:** <github-url>
**License:** <license>
**Language:** <Verilog/SystemVerilog/Chisel/LiteX/etc.>
**Stars:** <count>

### Description
<1-2 sentence description of what the design does>

### Why it's a good benchmark candidate
<Brief explanation of what makes it interesting for the suite — e.g., stresses routing, has many macros, high IO count, deep pipeline, etc.>

### Estimated complexity
- **Gate count:** <rough estimate if available: small/medium/large>
- **Memories:** <does it use SRAMs/register files that need FakeRAM?>
- **IO count:** <low/medium/high>

### Verification
<What verification framework is available — e.g., "cocotb testbench with CI", "verilator simulation with test suite", "UVM testbench", "basic iverilog testbench", "formal verification with SymbiYosys", etc.>

### Conversion notes
<What's needed to get plain Verilog — e.g., "pure Verilog, no conversion needed", "SystemVerilog, needs sv2v or yosys-slang", "Chisel, needs JDK + sbt", etc.>

### Target platforms
- [ ] asap7
- [ ] nangate45
- [ ] sky130hd
ISSUE_EOF
)"
```

## Guidelines

- Aim to propose 3-5 quality candidates per invocation, not a huge list of marginal ones
- If a design looks great but has a problematic license, skip it and note why
- In the issue body, note which selection criteria the design meets (active development, new language, new architecture, industry-relevant)
- If the user specified a focus area (`$ARGUMENTS`), prioritize that category but still ensure diversity
- Do NOT open issues for designs that are already in the repo or already have an open issue
