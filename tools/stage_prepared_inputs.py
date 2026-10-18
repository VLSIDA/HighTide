#!/usr/bin/env python3
"""Make a bazel_to_orfs.sh bundle portable to another machine.

For hermetic designs the RTL / includes / LEF-LIB live in the Bazel cache
($output_base/external/... and bazel-out/...), not the repo — so the extracted
config.mk points at absolute paths that only exist on the build machine.  This
copies every file/dir referenced by the path-bearing config vars into
<inputs>/, and rewrites those tokens to $(PREPARED_INPUTS)/... so the bundle is
self-contained.  bazel_to_orfs.sh's generated run.sh exports PREPARED_INPUTS to the
bundle's own inputs/ dir (derived from run.sh's location), so make expands the
paths correctly wherever the bundle is copied.

Include dirs are copied whole (preserving internal structure, so `include
"pkg/foo.svh"` still resolves against the -I dir).  Files are grouped by a hash
of their source directory to stay unique without long mirrored paths.

With ``--manifest``, the staged design also gets a tool-neutral JSON manifest
and its shared platform gets one platform manifest.  This mode is used only by
the suite-level benchmark export; ordinary ORFS bundles keep their existing
config.mk-only interface.

Usage: stage_prepared_inputs.py [--manifest FILE --platform-dir DIR]
                                <config.mk> <inputs_dir>
"""

import argparse
import hashlib
import os
import re
import shutil
import sys
from pathlib import Path

from benchmark_manifest import write_manifests

# Vars whose value is one or more file/dir paths (mirrors bazel_to_config_mk.sh).
_PATH_VARS = re.compile(
    r"^(VERILOG_FILES|VERILOG_INCLUDE_DIRS|SDC_FILE|ADDITIONAL_LEFS|"
    r"ADDITIONAL_LIBS|ADDITIONAL_GDS|IO_CONSTRAINTS|FOOTPRINT_TCL|"
    r"MACRO_PLACEMENT_TCL|PDN_TCL)$"
)

_ASSIGNMENT = re.compile(r"^(export\s+)?(\w+)\s*(\??=)\s*(.*)$")


def _is_pathvar(key):
    return bool(_PATH_VARS.match(key)) or key.endswith("_TCL")


def _dst_for(src, inputs):
    """Mirror <src> under <inputs> grouped by a hash of its parent dir."""
    src = os.path.realpath(src)
    parent = os.path.dirname(src)
    tag = hashlib.md5(parent.encode()).hexdigest()[:10]
    rel = os.path.join(tag, os.path.basename(src))
    return rel, os.path.join(inputs, rel)


def stage_prepared_inputs(cfg, inputs, manifest=None, platform_dir=None):
    if manifest and not platform_dir:
        raise ValueError("--manifest requires --platform-dir")
    os.makedirs(inputs, exist_ok=True)

    out_lines = []
    values = {}
    copied = 0
    with open(cfg) as config_file:
        for line in config_file:
            m = _ASSIGNMENT.match(line.rstrip("\n"))
            if not m:
                out_lines.append(line.rstrip("\n"))
                continue
            prefix, key, assign, val = m.groups()
            if not _is_pathvar(key):
                out_lines.append(line.rstrip("\n"))
                values[key] = val
                continue
            new_toks = []
            for tok in val.split():
                # Only absolutize real absolute filesystem paths; leave flags,
                # make-vars, and already-relative tokens untouched.
                if not tok.startswith("/") or tok.startswith("-") or "$(" in tok:
                    new_toks.append(tok)
                    continue
                if not os.path.exists(tok):
                    new_toks.append(tok)  # leave dangling tokens as-is
                    continue
                rel, dst = _dst_for(tok, inputs)
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                if os.path.isdir(tok):
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.copytree(tok, dst, symlinks=False)
                else:
                    shutil.copy2(os.path.realpath(tok), dst)
                copied += 1
                new_toks.append("$(PREPARED_INPUTS)/" + rel)
            if key == "VERILOG_FILES":
                # Match bazel-orfs EXPAND_VERILOG_DIRS: expand each TreeArtifact
                # in place, sorting within it rather than across the RTL list.
                expanded = []
                for tok in new_toks:
                    path = Path(tok.replace("$(PREPARED_INPUTS)", os.fspath(inputs)))
                    if path.is_dir():
                        expanded.extend(
                            tok + "/" + file.relative_to(path).as_posix()
                            for file in sorted(path.rglob("*"))
                            if file.is_file() and file.suffix in (".v", ".sv", ".svh")
                        )
                    else:
                        expanded.append(tok)
                new_toks = expanded
            values[key] = " ".join(new_toks)
            out_lines.append(
                "%s%s%s%s" % (prefix or "", key, assign, " ".join(new_toks))
            )

    with open(cfg, "w") as fh:
        fh.write("\n".join(out_lines) + "\n")
    if manifest:
        write_manifests(manifest, inputs, values, platform_dir)
    print("Staged %d input files/dirs into %s" % (copied, inputs), file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest")
    parser.add_argument("--platform-dir")
    parser.add_argument("config")
    parser.add_argument("inputs_dir")
    args = parser.parse_args()
    stage_prepared_inputs(
        args.config,
        args.inputs_dir,
        manifest=args.manifest,
        platform_dir=args.platform_dir,
    )


if __name__ == "__main__":
    main()
