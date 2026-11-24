#!/usr/bin/env python3
"""Move the GTH transceiver off chip in the generated LiteEth core.

The generator instantiates a Xilinx GTHE4_CHANNEL (FPGA hard IP). The former
GTHE4_CHANNEL_DUMMY stand-in had no serializer/deserializer: TX data went
nowhere and RX data was constant 0, so synthesis pruned the PCS and the PHY
side of the MAC (~3K flops on every platform). An ASIC would keep the SerDes
off chip (or as a hard macro), so this script deletes the instance and turns
its PCS-side parallel interface into chip ports:

  * every connection the core drives INTO the GTH (TX data/ctrl, resets,
    user clocks, ...) becomes an output port  gth_<port>;
  * every GTH output the core actually reads (RX data/ctrl, status, the
    recovered TX/RX clocks) becomes an input port  gth_<port>;
  * constant tie-offs and GTH outputs nothing reads are dropped;
  * the serial pins and the SerDes refclk (sgmii_rx[pn], sgmii_tx[pn],
    sgmii_refclk), which only connected to the GTH, are removed.

Port widths come from the core's own nets, not the stub's declarations.

It also ties the BUFG_GT instances' unconnected CE/CEMASK/CLR/CLRMASK to the
Xilinx defaults; left floating, the stand-in's divider sat in reset and the
half-rate PCS clocks were constant 0.

Usage: gth_offchip.py <core.v> <GTHE4_CHANNEL_DUMMY.v>   (rewrites core.v)
"""
import re, sys

core_path, stub_path = sys.argv[1], sys.argv[2]
core = open(core_path).read()
stub = open(stub_path).read()

# Port directions from the stub (same port list as GTHE4_CHANNEL).
DIRS = {n: d for d, n in re.findall(r"^\s*(input|output)\s*(?:\[[^\]]*\])?\s*(\w+)\s*,?", stub, re.M)}

# Locate the instance, including LiteX's banner comment above it.
m = re.search(r"(//-+\n// Instance GTHE4_CHANNEL of GTHE4_CHANNEL Module\.\n//-+\n)?GTHE4_CHANNEL_DUMMY\s*#\(.*?\n\)\s*GTHE4_CHANNEL\s*\((.*?)\n\);\n", core, re.S)
if not m:
    sys.exit("gth_offchip: GTHE4_CHANNEL_DUMMY instance not found")
inst_text, conn_text = m.group(0), m.group(2)
rest = core[:m.start()] + core[m.end():]
conns = re.findall(r"\.(\w+)\s*\(\s*(.*?)\s*\)\s*,?\s*$", conn_text, re.M)

def width_of(name):
    d = re.search(r"^\s*(?:input|output)?\s*(?:wire|reg)\s*(?:signed\s*)?(?:\[(\d+):(\d+)\])?\s*\b%s\b" % re.escape(name), core, re.M)
    if not d:
        d = re.search(r"^\s*(?:input|output)\s+wire\s*(?:\[(\d+):(\d+)\])?\s*\b%s\b" % re.escape(name), core, re.M)
    if not d:
        sys.exit(f"gth_offchip: no declaration for {name}")
    return abs(int(d.group(1)) - int(d.group(2))) + 1 if d.group(1) else 1

def terms(expr):
    e = expr.strip()
    if e.startswith("{") and e.endswith("}"):
        e = e[1:-1]
    return [t.strip() for t in e.split(",") if t.strip()]

def term_width(t):
    if re.fullmatch(r"\d+'[dbh][0-9a-fA-F_xXzZ]+", t):
        return int(t.split("'")[0])
    s = re.fullmatch(r"(\w+)\s*\[(\d+):(\d+)\]", t)
    if s: return abs(int(s.group(2)) - int(s.group(3))) + 1
    s = re.fullmatch(r"(\w+)\s*\[(\d+)\]", t)
    if s: return 1
    return width_of(t)

def is_const(expr):
    return all(re.fullmatch(r"\d+'[dbh][0-9a-fA-F_xXzZ]+", t) for t in terms(expr))

def nets(expr):
    return {re.match(r"\w+", t).group(0) for t in terms(expr) if not re.fullmatch(r"\d+'[dbh][0-9a-fA-F_xXzZ]+", t)}

DROP_PORTS = {"sgmii_rxp", "sgmii_rxn", "sgmii_txp", "sgmii_txn", "sgmii_refclk"}
# Uses of a net = references outside its own declaration line.
uses_text = "\n".join(l for l in rest.split("\n")
                      if not re.match(r"\s*(wire|reg)\b", l))
ports, assigns = [], []
for port, expr in conns:
    if not expr or port not in DIRS or is_const(expr):
        continue
    ns = nets(expr)
    if ns & DROP_PORTS:
        continue
    if DIRS[port] == "output":   # GTH drives the core: keep only if the core reads it
        if not any(re.search(r"\b%s\b" % re.escape(n), uses_text) for n in ns):
            continue
    w = sum(term_width(t) for t in terms(expr))
    pname = f"gth_{port.lower()}"
    rng = f"[{w - 1}:0] " if w > 1 else ""
    if DIRS[port] == "input":
        ports.append(f"    output wire   {rng}{pname}")
        assigns.append(f"assign {pname} = {expr};")
    else:
        ports.append(f"    input  wire   {rng}{pname}")
        assigns.append(f"assign {expr} = {pname};")

banner = ("//------------------------------------------------------------------------------\n"
          "// GTHE4_CHANNEL moved off chip (HighTide, designs/src/liteeth/dev/gth_offchip.py):\n"
          "// its PCS-side parallel interface is now the gth_* ports.\n"
          "//------------------------------------------------------------------------------\n")
rest = rest[:m.start()] + banner + "\n".join(assigns) + "\n\n" + rest[m.start():]

# Drop the serial/refclk ports from the module header; add the gth_* ports.
hdr = re.search(r"module\s+\w+\s*\((.*?)\n\);", rest, re.S)
lines = [l for l in hdr.group(1).split("\n") if l.strip()]
kept = [l.rstrip(",") for l in lines if not any(re.search(r"\b%s\b" % p, l) for p in DROP_PORTS)]
for p in DROP_PORTS:
    if re.search(r"\b%s\b" % p, rest[hdr.end():]):
        sys.exit(f"gth_offchip: {p} is still used outside the GTH; refusing to drop it")
new_hdr = "\n" + ",\n".join(kept + ports)
rest = rest[:hdr.start(1)] + new_hdr + rest[hdr.end(1):]

# LiteX instantiates BUFG_GT with only DIV/I/O. On the real primitive the
# unconnected CE/CEMASK/CLR/CLRMASK take safe defaults (enabled, not cleared);
# in the stand-in they float, synthesis resolves them so the divider sits in
# reset, and the DIV=1 half-rate clocks become constant 0 (the PCS half-rate
# domains were never clocked). Tie them to the Xilinx defaults explicitly.
TIE = ("\t.CE      (1'd1),\n\t.CEMASK  (1'd0),\n"
       "\t.CLR     (1'd0),\n\t.CLRMASK (1'd0),\n")
def tie_bufg(mm):
    block = mm.group(0)
    return block if ".CLR" in block else block.replace("// Inputs.\n", "// Inputs.\n" + TIE, 1)
rest, nbufg = re.subn(r"BUFG_GT\s+\w+\s*\(.*?\n\);", tie_bufg, rest, flags=re.S)
open(core_path, "w").write(rest)
print(f"gth_offchip: removed GTHE4_CHANNEL; {len(ports)} gth_* ports "
      f"({sum('output' in p for p in ports)} out, {sum('input ' in p for p in ports)} in)", file=sys.stderr)
