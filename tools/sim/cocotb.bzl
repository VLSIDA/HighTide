# tools/sim — design-agnostic cocotb test rule (see the verify-design skill).
#
# cocotb_test() generates a `bazel run`nable py_binary for a single design by
# rewrapping tools/sim/cocotb_runner.py, wiring the design's DUT and testbench
# sources as runfiles and passing them to the runner via `$(locations ...)`.
# The design only has to add:
#
#   load("//tools/sim:cocotb.bzl", "cocotb_test")
#   cocotb_test(
#       name = "lfsr_cocotb",
#       hdl_toplevel = "lfsr_prbs_gen",
#       test_module = "test_lfsr_prbs_gen",
#       verilog_sources = ":rtl",              # DUT filegroup (`.v`/`.sv`)
#       test_module_sources = ":sim_sources",  # filegroup incl. the test `.py`
#       simulator = "icarus",                  # backend upstream documents
#   )
#
# `build_args` is optional and backend-specific (e.g. `["-Wno-SELRANGE",
# "-Wno-WIDTH", "-Wno-COMBDLY"]` when a run intended for verilator needs
# upstream's warning suppressions replayed).
#
# Then run the design's testbench with a single line:
#
#   bazel run //designs/src/lfsr:lfsr_cocotb              # default SIM
#   bazel run //designs/src/lfsr:lfsr_cocotb -- --sim=vcs  # override backend
#
# Note: the backend override must use `--sim=<backend>`. A bare `-- vcs`
# token is appended after the target's other args and gets swallowed by an
# earlier nargs="+" option — the runner now errors on that instead of
# silently running the default backend.
#
# The generated target shells out to the host simulator + compiler at run time,
# so it is tagged `manual` and must be run with `bazel run` (host execution
# env), never a sandboxed `bazel test`. `verilog_sources` / `test_module_sources`
# may be any label that resolves to a filegroup of the upstream RTL / testbench
# files (for HighTide designs these come from the pinned `@<design>_src`
# archive, so the testbench is fetched with the RTL, not checked in).
load("@rules_python//python:defs.bzl", "py_binary")

# The cocotb + test-driver python deps a generated target needs. pip hub
# normalizes package names, so `cocotb-test` is exposed as `cocotb_test`.
_COCOTB_DEPS = [
    "@pip_cocotb//find_libpython",
    "@pip_cocotb//cocotb",
    "@pip_cocotb//cocotb_test",
    "@pip_cocotb//pytest",
    "@pip_cocotb//packaging",
]

def cocotb_test(name, hdl_toplevel, test_module, verilog_sources,
                test_module_sources = None, simulator = None, timescale = "1ns/1ps",
                build_args = None, tags = [], **kwargs):
    """Create a `bazel run`nable cocotb test launcher for a design.

    Args:
        name: Bazel target name.
        hdl_toplevel: DUT top-level module name.
        test_module: Python module name containing the cocotb tests.
        verilog_sources: a label whose files are the DUT Verilog/SystemVerilog
            sources (passed to the simulator as the design-under-test).
        test_module_sources: optional label whose files include the test
            module(s); their enclosing dir is added to the test import path.
        simulator: default simulator backend (verilator/icarus/vcs/...). If
            None, the runner's default (verilator) is used; the backend can
            still be overridden on the command line with `bazel run ... -- <s>`.
        timescale: Simulation timescale "1ns/1ps".
        build_args: extra simulator build flags, e.g. warning suppressions
            (`["-Wno-WIDTH", "-Wno-COMBDLY"]`).
        tags: extra bazel tags.
        **kwargs: Forwarded to py_binary.
    """
    data = [verilog_sources]
    args = [
        "--toplevel", hdl_toplevel,
        "--test-module", test_module,
        "--timescale", timescale,
        "--sources",
        "$(locations %s)" % verilog_sources,
    ]
    if simulator:
        args.insert(0, simulator)
    if build_args:
        args.append("--build-args=%s" % ",".join(build_args))
    if test_module_sources:
        data.append(test_module_sources)
        args += ["--pythonpath", "$(locations %s)" % test_module_sources]

    py_binary(
        name = name,
        srcs = ["//tools/sim:cocotb_runner.py"],
        main = "//tools/sim:cocotb_runner.py",
        data = data,
        deps = _COCOTB_DEPS,
        args = args,
        tags = tags + ["manual"],
        **kwargs,
    )
