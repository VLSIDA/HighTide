#!/usr/bin/env python3
"""Lint every bsg_fakeram cfg (designs/src/<design>/dev/generated/fakeram_<platform>.cfg).

Checks (grep-level, no toolchain):
  1. Snap-grid keys are camelCase. bsg_fakeram reads only snapWidth_nm /
     snapHeight_nm and silently falls back to a 1 nm grid on the snake_case
     spelling, so macros land off the site grid (CLAUDE.md bug table).
  2. The cfg's macro set equals the MACROs in the committed LEFs under
     designs/<platform>/<design>/sram/lef/, i.e. the LEFs were regenerated
     from this cfg with tools/regenerate_sram.sh and nothing is stale.

Whether the netlist actually *uses* each macro is a post-synthesis question;
see tools/check_sram_usage.py.

Exit status 0 = clean, 1 = a check failed.
"""
import glob, json, os, re, subprocess, sys

# cfgs committed with the snake_case keys before the bug was found. Their LEFs
# are off-grid and regenerating them changes macro sizes, so the fix is
# deferred (CLAUDE.md, "bsg_fakeram snap-grid key mismatch"). Remove an entry
# when its cfg is fixed and regenerated; never add one.
SNAKE_CASE_ALLOWLIST = {
    "bp_processor/fakeram_asap7.cfg", "cnn/fakeram_asap7.cfg",
    "coralnpu/fakeram_asap7.cfg", "eyeriss/fakeram_asap7.cfg",
    "liteeth/fakeram_asap7.cfg", "litepci/fakeram_asap7.cfg",
    "NVDLA/fakeram_asap7.cfg", "nyuzi/fakeram_asap7.cfg",
    "vortex/fakeram_asap7.cfg",
}

def main():
    root = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                          text=True, check=True).stdout.strip()
    os.chdir(root)
    bad, seen_allow = 0, set()
    for cfg in sorted(glob.glob("designs/src/*/dev/generated/fakeram_*.cfg")):
        design = cfg.split("/")[2]
        platform = os.path.basename(cfg)[len("fakeram_"):-len(".cfg")]
        key = f"{design}/{os.path.basename(cfg)}"
        text = open(cfg).read()
        try:
            names = {s["name"] for s in json.loads(text)["srams"]}
        except (ValueError, KeyError) as e:
            print(f"FAIL {cfg}: cannot parse ({e})"); bad += 1; continue

        if re.search(r'"snap_(width|height)_nm"', text):
            if key in SNAKE_CASE_ALLOWLIST:
                seen_allow.add(key)
            else:
                print(f"FAIL {cfg}: snake_case snap_width_nm/snap_height_nm keys are ignored by "
                      f"bsg_fakeram; use snapWidth_nm/snapHeight_nm and regenerate")
                bad += 1
        elif key in SNAKE_CASE_ALLOWLIST:
            print(f"FAIL {cfg}: fixed, so remove it from SNAKE_CASE_ALLOWLIST in {sys.argv[0]}")
            bad += 1

        lefdir = f"designs/{platform}/{design}/sram/lef"
        lefs = set()
        for f in glob.glob(f"{lefdir}/*.lef"):
            lefs |= set(re.findall(r"^\s*MACRO\s+(\S+)", open(f, errors="replace").read(), re.M))
        if names != lefs:
            print(f"FAIL {cfg}: cfg and {lefdir} disagree "
                  f"(cfg only: {sorted(names - lefs) or '-'}; LEF only: {sorted(lefs - names) or '-'}); "
                  f"run tools/regenerate_sram.sh {design} {platform}")
            bad += 1

    for key in sorted(SNAKE_CASE_ALLOWLIST - seen_allow):
        if not os.path.exists(f"designs/src/{key.split('/')[0]}/dev/generated/{key.split('/')[1]}"):
            print(f"FAIL allowlisted cfg {key} no longer exists; remove it from SNAKE_CASE_ALLOWLIST")
            bad += 1
    if bad:
        print(f"\n{bad} problem(s)")
        return 1
    print(f"OK: all fakeram cfgs consistent ({len(SNAKE_CASE_ALLOWLIST)} allowlisted snake_case cfgs pending regeneration)")
    return 0

if __name__ == "__main__":
    sys.exit(main())
