#!/usr/bin/env python3
"""Freeze explicit optimized binaries, runfiles, and ASAP7 views for lhdsuite."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("lhd", "yosys", "openroad", "slang", "flow-home", "out"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--threads", type=int, default=8)
    parser.add_argument("--build-description", required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    tools = Path(__file__).resolve().parent
    for name in ("lhd", "yosys", "openroad"):
        source = getattr(args, name).resolve()
        dest = out / "bin" / name
        dest.mkdir(parents=True)
        shutil.copy2(source, dest / name)
        if source.with_name(name + ".runfiles").exists():
            shutil.copytree(source.with_name(name + ".runfiles"), dest / (name + ".runfiles"))
        manifest = source.with_name(name + ".runfiles_manifest")
        if manifest.exists():
            shutil.copy2(manifest, dest / manifest.name)
        # Yosys locates its technology maps beside the executable first.
        if name == "yosys":
            shutil.copytree(source.parent / "share", dest / "share")
            shutil.copy2(source.parent / "yosys-abc", dest / "yosys-abc")
    shutil.copy2(args.slang, out / "bin/yosys/slang.so")
    flow = out / "flow"
    flow.mkdir()
    for directory in ("scripts", "util"):
        shutil.copytree(args.flow_home / directory, flow / directory)
    shutil.copy2(args.flow_home / "Makefile", flow / "Makefile")
    (flow / "platforms").mkdir()
    for directory in ("asap7", "common"):
        shutil.copytree(args.flow_home / "platforms" / directory, flow / "platforms" / directory)
    platform = flow / "platforms/asap7"
    # Pin exactly the five real RVT/TT NLDM families. FAKE multi-bit DFFs
    # are experimental files in ORFS and must not enter this comparison.
    libs = sorted(p for p in (platform / "lib/NLDM").glob("*RVT_TT*.lib*") if "FAKE" not in p.name)
    if len(libs) != 5:
        raise ValueError(f"Expected five ASAP7 RVT/TT families, found {libs}")
    subprocess.run([sys.executable, str(tools / "merge_liberty.py"),
                    str(out / "asap7-tt.lib"), *map(str, libs)], check=True)
    shutil.copy2(tools / "score_flow.tcl", out / "score.tcl")
    shutil.copy2(tools.parent.parent / "bazel-orfs/synth.tcl", out / "synth.tcl")
    cfg = {name: str(out / "bin" / name / name) for name in ("lhd", "yosys", "openroad")}
    cfg.update(slang=str(out / "bin/yosys/slang.so"), flow_home=str(flow),
               hightide=str(tools.parent.parent), platform=str(platform), threads=args.threads,
               liberty=str(out / "asap7-tt.lib"), tech_rc=str(platform / "setRC.tcl"),
               lefs=[str(platform / "lef" / n) for n in
                     ("asap7_tech_1x_201209.lef", "asap7sc7p5t_28_R_1x_220121a.lef")],
               make="/usr/bin/make", python=sys.executable, score_script=str(out / "score.tcl"),
               synth_script=str(out / "synth.tcl"), build_description=args.build_description)
    (out / "tools.json").write_text(json.dumps(cfg, indent=2) + "\n")
    files = {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest()
             for p in sorted(out.rglob("*")) if p.is_file()}
    (out / "sha256.json").write_text(json.dumps(files, indent=2) + "\n")
    print(out / "tools.json")


if __name__ == "__main__":
    main()
