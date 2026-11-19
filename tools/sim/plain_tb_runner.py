#!/usr/bin/env python3
"""Shared runner for plain (.v/.sv) self-checking testbenches — the Pattern-B
counterpart of tools/sim/cocotb_runner.py. A design's plain_tb_test() target
(tools/sim/plain_tb.bzl) rewraps this script so every design runs
verification with the same uniform command shape:

    bazel run //designs/src/<d>:<name>_tb           # default: verilator
    bazel run //designs/src/<d>:<name>_tb -- --sim=icarus  # override backend

The generated py_binary passes (as baked args):
    --sim=<backend> [--build-args="..."] --toplevel=<module> --sources="f..."
where the file list of `--sources=` additionally arrives as separate bare
argv tokens when `$(locations ...)` expands a multi-file label; bare
trailing tokens are therefore appended to the source list, and the backend
override is `--sim=<backend>` (last occurrence wins).

Compared to cocotb_runner.py this is deliberately tiny: a plain TB
self-drives and self-checks (a silent run with exit 0 is green), so there is
no test module, no Python path, no VPI — compile DUT + TB, run, propagate
the exit status.
"""

import os
import shlex
import subprocess
import sys

DEFAULT_SIM = "verilator"


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    sim = DEFAULT_SIM
    toplevel = ""
    build_args: list[str] = []
    sources: list[str] = []

    plain = []  # bare tokens = expanded source files (Bazel splits $(locations))
    for tok in argv:
        if tok.startswith("--sim="):
            sim = tok[len("--sim="):]  # last one wins: run-time override
        elif tok.startswith("--build-args="):
            build_args = tok[len("--build-args="):].replace(",", " ").split()
        elif tok.startswith("--toplevel="):
            toplevel = tok[len("--toplevel="):]
        elif tok.startswith("--sources="):
            sources = tok[len("--sources="):].split()
        else:
            plain.append(tok)
    sources += plain
    if not toplevel:
        sys.exit("plain_tb_runner: --toplevel is required")
    if not sources:
        sys.exit("plain_tb_runner: no --sources passed")
    # Sources arrive runfiles-relative (Bazel $(locations)); cocotb builds
    # the sim in a sub-directory so they are made absolute there — same
    # requirement here, since verilator writes into its own dir.
    sources = [os.path.abspath(s) for s in sources]

    if sim == "verilator":
        build = ["verilator", "--binary", "--timing", "-Wno-fatal"]
        out = os.path.join("plain_tb_obj", f"{toplevel}_tb")
        build += ["--top-module", toplevel, "-Mdir", "plain_tb_obj",
                  "-o", f"{toplevel}_tb", *build_args, *sources]
        subprocess.run(build, check=True,
                       stdout=subprocess.DEVNULL)
        subprocess.run([f"./{out}"], check=True)
    elif sim == "icarus":
        build = ["iverilog", "-g2012", *build_args, "-o", "plain_tb_sim.vvp",
                 *sources]
        subprocess.run(build, check=True)
        subprocess.run(["vvp", "plain_tb_sim.vvp"], check=True)
    else:
        sys.exit(
            f"plain_tb_runner: unsupported simulator '{sim}' "
            "(supports: verilator, icarus)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
