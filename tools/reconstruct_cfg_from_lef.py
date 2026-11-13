#!/usr/bin/env python3
"""tools/reconstruct_cfg_from_lef.py <design> <platform>

Reconstruct a bsg_fakeram cfg from a design's *committed* LEF macro set.

Used for Section B designs (coralnpu, vortex, nyuzi) whose original
cfgs were lost, drifted from the committed LEFs, or never existed. The
committed LEF macro set is the ground truth for what the design's RTL
instantiates, so deriving (width, depth, ports, write_granularity) by
counting pins reproduces exactly those macros under the fixed generator —
the only intended change is the wd_in pin-direction correction (c83ecb4).

Pin model (bsg_fakeram naming):
  - addr_in pins exist on every addressable port (r/w/rw). Total addr pin
    count = n_addr_ports * ceil(log2(depth))  ->  depth = 2^(total/n_ports).
  - wd_in / wmask_in exist only on write-capable ports (w + rw). width =
    total wd_in / n_write_ports. write_granularity = width / (wmask per port);
    no wmask pins -> "no_wmask": true.
  - port multiplicity is encoded in the macro-name suffix, e.g.
    _1rw -> {rw:1}; _1r1w -> {r:1,w:1}; _2r1w -> {r:2,w:1}.

Writes designs/src/<design>/dev/generated/fakeram_<platform>.cfg (the
standard path tools/regenerate_sram.sh expects).
"""
import json
import math
import re
import subprocess
import sys
from pathlib import Path

PLATFORM_HEADER = {
    "asap7": {
        "tech_nm": 7, "voltage": 0.7, "metalPrefix": "M",
        "LRpinWidth_nm": 24, "LRpinPitch_nm": 48,
        "TBpinWidth_nm": 18, "TBpinPitch_nm": 36,
        "manufacturing_grid_nm": 1, "contacted_poly_pitch_nm": 54,
        "column_mux_factor": 3, "fin_pitch_nm": 27,
        "flipPins": False, "snap_width_nm": 190, "snap_height_nm": 1400,
    },
    "nangate45": {
        "tech_nm": 45, "voltage": 1.1, "metalPrefix": "metal",
        "LRpinWidth_nm": 70, "LRpinPitch_nm": 140,
        "TBpinWidth_nm": 70, "TBpinPitch_nm": 190,
        "snapWidth_nm": 190, "snapHeight_nm": 1400, "flipPins": True,
    },
    "sky130hd": {
        "tech_nm": 130, "voltage": 1.8, "metalPrefix": "met",
        "LRpinWidth_nm": 300, "LRpinPitch_nm": 680,
        "TBpinWidth_nm": 140, "TBpinPitch_nm": 460,
        "snapWidth_nm": 460, "snapHeight_nm": 2720, "flipPins": True,
    },
}

PIN_RE = re.compile(r"^\s*PIN\s+(\S+)", re.M)


def parse_ports(macro_name):
    """fakeram_..._1r1w -> ({'r':1,'w':1,'rw':0}, n_addr_ports, n_write_ports)."""
    suffix = macro_name.rsplit("_", 1)[-1]            # e.g. '1r1w', '2r1w', '1rw'
    counts = {"r": 0, "w": 0, "rw": 0}
    for n, kind in re.findall(r"(\d+)(rw|r|w)", suffix):
        counts[kind] += int(n)
    n_addr = counts["r"] + counts["w"] + counts["rw"]
    n_write = counts["w"] + counts["rw"]
    return counts, n_addr, n_write


def macro_from_lef(lef_path):
    text = lef_path.read_text()
    name = re.search(r"^MACRO\s+(\S+)", text, re.M).group(1)
    pins = PIN_RE.findall(text)
    n_addr_pin = sum(1 for p in pins if re.search(r"_addr_in\[", p) or re.search(r"_addr_in$", p))
    # addr pins are named e.g. rw0_addr_in[3]; match the bus
    n_addr_pin = sum(1 for p in pins if "_addr_in[" in p)
    n_wd_pin = sum(1 for p in pins if "_wd_in[" in p)
    n_wmask_pin = sum(1 for p in pins if "_wmask_in[" in p)

    counts, n_addr_ports, n_write_ports = parse_ports(name)
    if n_addr_ports == 0:
        raise SystemExit(f"{name}: could not parse ports from name")

    addr_bits = n_addr_pin // n_addr_ports
    addr_space = 1 << addr_bits
    width = n_wd_pin // n_write_ports if n_write_ports else None  # data width

    # Recover the *logical* depth (may be non-power-of-2, e.g. 52) from the
    # two integer tokens in the macro name. Naming orientation differs by
    # design (coralnpu = DEPTHxWIDTH, vortex/Nyuzi = WIDTHxDEPTH), so pick
    # the token that is NOT the pin-derived width as the depth.
    # The "<a>x<b>" core of the name carries the two dimensions.
    m = re.search(r"_(\d+)x(\d+)_", name)
    name_dims = [int(m.group(1)), int(m.group(2))] if m else []
    if width is None:
        width = n_addr_pin
    depth = addr_space
    if len(name_dims) == 2:
        if width in name_dims:
            rest = [d for d in name_dims if d != width]
            depth = rest[0] if rest else width
        else:
            depth = min(name_dims, key=lambda d: abs(d - addr_space))
    # Sanity: the LEF address bus must be wide enough for the logical depth.
    assert (1 << math.ceil(math.log2(max(2, depth)))) == addr_space, (
        f"{name}: name depth {depth} inconsistent with {addr_bits}-bit addr bus")
    entry = {
        "name": name,
        "width": width,
        "depth": depth,
        "banks": 1,
        "ports": {"r": counts["r"], "w": counts["w"], "rw": counts["rw"]},
    }
    if n_wmask_pin == 0:
        entry["no_wmask"] = "true"
    else:
        wmask_per_port = n_wmask_pin // n_write_ports
        wgran = max(1, round(width / wmask_per_port)) if wmask_per_port else 1
        entry["write_granularity"] = wgran
    return entry


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: reconstruct_cfg_from_lef.py <design> <platform>")
    design, plat = sys.argv[1], sys.argv[2]
    if plat not in PLATFORM_HEADER:
        sys.exit(f"unknown platform {plat}")
    root = Path(subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"], text=True).strip())
    lef_dir = root / "designs" / plat / design / "sram" / "lef"
    lefs = sorted(lef_dir.glob("*.lef"))
    if not lefs:
        sys.exit(f"no LEFs under {lef_dir}")
    cfg = dict(PLATFORM_HEADER[plat])
    cfg["srams"] = [macro_from_lef(p) for p in lefs]
    out = root / "designs" / "src" / design / "dev" / "generated" / f"fakeram_{plat}.cfg"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(cfg, indent=2) + "\n")
    print(f"wrote {out} ({len(cfg['srams'])} macros)")
    for s in cfg["srams"]:
        print(f"  {s['name']:<28} w={s['width']:<4} d={s['depth']:<5} "
              f"ports={s['ports']} "
              f"{'no_wmask' if s.get('no_wmask') else 'wgran='+str(s.get('write_granularity'))}")


if __name__ == "__main__":
    main()
