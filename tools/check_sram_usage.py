#!/usr/bin/env python3
"""Check after synthesis that a design's memories actually exist.

A memory can vanish with no error: a wrapper whose generate branches no longer
match the configured shape instantiates nothing (ternip, 2026-05..11: 0 macros,
2,399 flops for 606,208 memory bits), or an empty stub module gets dissolved
(floonoc #254). Synthesis then prunes the logic behind it, every later stage
closes, and SYNTH_MEMORY_MAX_BITS never fires because nothing was inferred.

This reads the design's synth_stat.txt and checks:
  * every macro in the design's ADDITIONAL_LEFS is instantiated at least once
    (a LEF the netlist never uses is the classic symptom);
  * per-macro counts match --expect / sram/expected_macros.txt, if given;
  * the flop count is at least --min-flops / the expected_macros.txt floor.

Usage:
  tools/check_sram_usage.py <platform> <design-path> [--bazel-bin DIR | --stat FILE]
                            [--expect NAME=COUNT ...] [--min-flops N]
  e.g. tools/check_sram_usage.py asap7 ternip
       tools/check_sram_usage.py sky130hd NVDLA/partition_c --bazel-bin bazel-bin

sram/expected_macros.txt (optional, next to sram/lef/): one "NAME COUNT" per
line, plus an optional "flops >= N" line; '#' starts a comment.

Exit status: 0 = all checks pass, 1 = a check failed, 2 = could not check.
"""
import argparse, glob, os, re, sys

# Sequential cells by name: asap7 DFF*/DHL/DLL, nangate45 DFF*/SDFF*/DLH/DLL,
# sky130 df*/edf*/sdf*/dl{x,r,clk}* (but not dlygate/dlymetal delay cells),
# gt2n *_dff*. Pass --stat for a custom library and check the printed count.
FLOP_RE = re.compile(r"(?i)((^|_)s?dff|(^|_)s?e?df[a-z]+_\d|(^|_)(dhl|dll|dlh)|latch"
                     r"|(^|_)s?dl(x|r|clk)[a-z]*_\d)")

def repo_root():
    d = os.path.abspath(os.path.dirname(__file__))
    return os.path.dirname(d)

def lef_macros(path):
    try:
        return re.findall(r"^\s*MACRO\s+(\S+)", open(path, errors="replace").read(), re.M)
    except OSError:
        return []

def resolve_lef_label(root, pkg, label):
    """':name' or '//designs/x/y:name' -> list of LEF files from that filegroup."""
    if label.startswith("//"):
        pkg_path, name = label[2:].split(":", 1)
    elif label.startswith(":"):
        pkg_path, name = pkg, label[1:]
    else:
        return None
    build = os.path.join(root, pkg_path, "BUILD.bazel")
    try:
        text = open(build).read()
    except OSError:
        return None
    m = re.search(r'filegroup\(\s*name\s*=\s*"%s"\s*,\s*srcs\s*=\s*(glob\(\s*\[(.*?)\]\s*\)|\[(.*?)\])' % re.escape(name), text, re.S)
    if not m:
        return None
    if m.group(2) is not None:      # glob([...])
        files = []
        for pat in re.findall(r'"([^"]+)"', m.group(2)):
            files += glob.glob(os.path.join(root, pkg_path, pat))
        return sorted(files)
    return [os.path.join(root, pkg_path, f) for f in re.findall(r'"([^"]+)"', m.group(3))]

def design_lefs(root, platform, design):
    pkg = f"designs/{platform}/{design}"
    try:
        text = open(os.path.join(root, pkg, "BUILD.bazel")).read()
    except OSError:
        sys.exit(f"cannot read {pkg}/BUILD.bazel")
    m = re.search(r'"ADDITIONAL_LEFS"\s*:\s*\[(.*?)\]', text, re.S)
    if not m:
        return {}, []
    macros, unresolved = {}, []
    for label in re.findall(r'"([^"]+)"', m.group(1)):
        files = resolve_lef_label(root, pkg, label)
        if files is None:
            unresolved.append(label)
            continue
        for f in files:
            for name in lef_macros(f):
                macros[name] = os.path.relpath(f, root)
    return macros, unresolved

def parse_stat(path):
    """Cell counts from the top module section (largest 'cells' including submodules)."""
    best, cur, cur_cells, cells = None, None, 0, {}
    for line in open(path, errors="replace"):
        if line.startswith("=== "):
            if cur is not None and (best is None or cur_cells > best[1]):
                best = (cur, cur_cells, cells)
            name = line.strip("= \n")
            cur, cur_cells, cells = (None if name == "design hierarchy" else name), 0, {}
            continue
        if cur is None:
            continue
        m = re.match(r"^\s+(\d+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s*$", line)
        if not m:
            continue
        count, what = int(m.group(1)), m.group(2)
        if what == "cells":
            cur_cells = count
        elif what not in ("wires", "bits", "ports", "memories", "processes"):
            cells[what] = count
    if cur is not None and (best is None or cur_cells > best[1]):
        best = (cur, cur_cells, cells)
    return best

def read_expected(path):
    exp, min_flops = {}, None
    if not os.path.exists(path):
        return exp, min_flops
    for raw in open(path):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        m = re.match(r"flops\s*>=\s*(\d+)$", line)
        if m:
            min_flops = int(m.group(1)); continue
        name, count = line.split()
        exp[name] = int(count)
    return exp, min_flops

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("platform"); ap.add_argument("design")
    ap.add_argument("--bazel-bin", default=None)
    ap.add_argument("--stat", default=None)
    ap.add_argument("--expect", action="append", default=[], metavar="NAME=COUNT")
    ap.add_argument("--min-flops", type=int, default=None)
    a = ap.parse_args()
    root = repo_root()
    tag = f"{a.platform}/{a.design}"

    stat = a.stat
    if stat is None:
        bb = a.bazel_bin or os.path.join(root, "bazel-bin")
        hits = glob.glob(os.path.join(bb, "designs", a.platform, a.design, "reports", a.platform, "*", "base", "synth_stat.txt"))
        if not hits:
            print(f"SKIP {tag}: no synth_stat.txt under {bb} (build :<name>_synth first)")
            return 2
        stat = hits[0]
    top = parse_stat(stat)
    if top is None:
        print(f"SKIP {tag}: could not parse {stat}")
        return 2
    top_name, ncells, cells = top

    macros, unresolved = design_lefs(root, a.platform, a.design)
    exp, exp_flops = read_expected(os.path.join(root, "designs", a.platform, a.design, "sram", "expected_macros.txt"))
    for e in a.expect:
        name, count = e.split("=", 1); exp[name] = int(count)
    min_flops = a.min_flops if a.min_flops is not None else exp_flops

    flops = sum(n for c, n in cells.items() if FLOP_RE.search(c) and c not in macros)
    fails, notes = [], []
    for name, lef in sorted(macros.items()):
        n = cells.get(name, 0)
        if n == 0:
            fails.append(f"macro {name} ({lef}) is never instantiated")
        notes.append(f"{name} x{n}")
    for name, want in sorted(exp.items()):
        got = cells.get(name, 0)
        if got != want:
            fails.append(f"macro {name}: expected {want}, netlist has {got}")
    if min_flops is not None and flops < min_flops:
        fails.append(f"flops {flops} < expected floor {min_flops}")
    for label in unresolved:
        notes.append(f"(could not resolve LEF label {label}; its macros were not checked)")

    status = "FAIL" if fails else "OK"
    print(f"{status} {tag} [{top_name}]: {ncells} cells, {flops} flops; macros: {', '.join(notes) or 'none'}")
    for f in fails:
        print(f"    - {f}")
    if fails:
        print("    A memory with no storage passes synthesis silently and takes the logic behind it;")
        print("    see .claude/skills/generate-sram/SKILL.md, 'Memories that silently vanish'.")
    return 1 if fails else 0

if __name__ == "__main__":
    sys.exit(main())
