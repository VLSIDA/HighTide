# tools/sim — design-agnostic plain-testbench rule (Pattern B of the
# verify-design skill).
#
# plain_tb_test() generates a `bazel run`nable target for a self-checking
# Verilog/SystemVerilog testbench (optionally carrying SVA assertions), so a
# design runs verification with the same uniform command shape as cocotb:
#
#   bazel run //designs/src/<d>:<name>_tb                 # default: verilator
#   bazel run //designs/src/<d>:<name>_tb -- --sim=icarus  # override backend
#
# The rule rewraps tools/sim/plain_tb_runner.sh, wiring the DUT and TB
# sources from the pinned upstream archive (via `$(locations ...)`), so
# testbenches are not checked in and can't drift from the RTL. Generated
# targets shell out to the host simulator at run time, so they are tagged
# `manual`: run with `bazel run` (host execution env), never a sandboxed
# `bazel test`. Usage:
#
#   load("//tools/sim:plain_tb.bzl", "plain_tb_test")
#   plain_tb_test(
#       name = "lfsr_prbs9_tb",
#       toplevel = "test_lfsr_prbs9",        # the testbench module is the top
#       sources = ["//designs/src/lfsr:rtl",
#                  "//designs/src/lfsr:sim_sources"],
#   )
#
# Backend override convention (same as cocotb_test): run the target with the
# simulator you want as the first argument — the runner treats any bare
# trailing token as the backend.
#
# Implemented as a py_binary (rules_python, already a repo dep) rewrapping
# tools/sim/plain_tb_runner.py — same pattern as cocotb_test/cocotb_runner.py
# — so no extra top-level dependency (e.g. rules_shell) is introduced.

load("@rules_python//python:defs.bzl", "py_binary")

def plain_tb_test(name, toplevel, sources, simulator = "verilator",
                  build_args = None, tags = [], **kwargs):
    """Create a `bazel run`nable self-checking/SVA testbench launcher.

    Args:
        name: Bazel target name.
        toplevel: top-level module name — usually the *testbench* module
            (plain TBs self-drive and self-check).
        sources: list of labels resolving to the DUT + testbench Verilog/SV
            files (for HighTide designs, from the pinned `@<design>_src`
            archive).
        simulator: "verilator" (default) or "icarus".
        build_args: extra simulator flags, e.g.
            `["-Wno-SELRANGE", "-Wno-WIDTH"]`.
        tags: extra bazel tags.
        **kwargs: forwarded to sh_binary.
    """
    args = ["--sim={}".format(simulator)]
    if build_args:
        args.append("--build-args={}".format(" ".join(build_args)))
    args.append("--toplevel={}".format(toplevel))
    # One `--sources=` switch holding all `$(locations ...)` expansions so
    # filegroups (multi-file labels) expand correctly: Bazel keeps the
    # space-separated list inside a single argv element, and the runner
    # splits it back into files.
    locs = " ".join(["$(locations {})".format(s) for s in sources])
    args.append("--sources={}".format(locs))
    py_binary(
        name = name,
        srcs = ["//tools/sim:plain_tb_runner.py"],
        main = "//tools/sim:plain_tb_runner.py",
        args = args,
        data = list(sources),
        tags = tags + ["manual"],
        **kwargs,
    )
