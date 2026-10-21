#!/usr/bin/env python3
"""Simulator-agnostic cocotb testbench runner for HighTide designs.

Builds the DUT with a user-selected simulator backend and runs the cocotb
test suite against it, both driven through cocotb's runner API so the harness
does not care which simulator executes the simulation.

Backend selection (mirrors the verify-design skill's decision rule):
  * `--sim`/positional chooses the backend (default: verilator).
  * Choose whichever simulator the design's upstream explicitly documents.
  * Any cocotb-supported backend works — verilator, icarus, vcs, questa,
    riviera, cvc, nvc, xcelium — or a custom/remote wrapper around one.

Usage:
  cocotb_runner.py [<simulator>] --toplevel <mod> --test-module <pkg> \
      [--sources a.v b.sv ...] [--pythonpath <dir>] [--timescale 1ns/1ps]

Example (local, open-source sim):
  cocotb_runner.py verilator --toplevel lfsr --test-module test_lfsr \
      --sources rtl/lfsr.v --pythonpath tests

The positional simulator must come FIRST: as the first argument it binds to
`s`, while a bare backend token appended later (e.g. after bazel-run `--`)
is swallowed by an earlier `nargs="+"` option and silently ignored — the
runner errors on such tokens rather than compiling with the wrong backend.
When appending via `bazel run ... --`, use `-- --sim=<backend>` explicitly.
"""

import argparse
import logging
import os
import sys

# cocotb 1.x: the runner lives at cocotb.runner.
# cocotb 2.x: it moved to cocotb_tools.runner. Try both so the harness is
# version-agnostic (see tools/sim/requirements_lock.txt for the pinned line).
try:  # pragma: no cover - trivial import dispatch
    from cocotb.runner import get_runner  # type: ignore[import-not-found]
except ImportError:  # pragma: no cover
    from cocotb_tools.runner import get_runner  # type: ignore[import-not-found]

log = logging.getLogger("hightide.cocotb")

DEFAULT_SIM = "verilator"
DEFAULT_TIMESCALE = ("1ns", "1ps")

# Backends cocotb's runner supports (subset used in docs/invocations). A bare
# token equal to one of these is virtually always a misplaced backend name,
# not a real source file — fail loudly instead of a silently wrong backend.
_KNOWN_BACKENDS = frozenset({
    "verilator", "icarus", "vcs", "questa", "riviera", "cvc", "nvc",
    "xcelium", "ghdl", "ius",
})


def _add_pythonpath(dirs):
    """Register dirs so cocotb can import the test module(s).

    cocotb's Runner.test() sets the simulation's PYTHONPATH to
    ``os.pathsep.join(sys.path)`` of the runner process, so simply exporting
    PYTHONPATH in the environment is not enough — the dirs must be on the
    runner's own ``sys.path``. Entries may be directories, or files whose
    enclosing directory is added (so bazel ``$(location ...)`` of a test .py
    works directly).
    """
    for d in reversed(dirs):
        if not d:
            continue
        d = os.path.abspath(d)
        if os.path.isfile(d):
            d = os.path.dirname(d)
        if d not in sys.path:
            sys.path.insert(0, d)
    # Also export for any subprocess that does respect the env var.
    existing = [x for x in os.environ.get("PYTHONPATH", "").split(os.pathsep) if x]
    merged = list(dirs) + existing
    os.environ["PYTHONPATH"] = os.pathsep.join(merged)


def _run(args):
    _add_pythonpath(args.pythonpath or [])

    # Sources come in as runfiles-relative paths (e.g. via bazel
    # "$(locations ...)"). cocotb builds the sim in a sub-directory, so
    # normalize to absolute paths before handing them to cocotb.runner.
    sources = [os.path.abspath(s) for s in args.sources]

    runner = get_runner(args.sim)
    build_kwargs = dict(sources=sources, hdl_toplevel=args.toplevel)
    if args.build_args:
        build_kwargs["build_args"] = args.build_args

    if not args.test_only:
        runner.build(**build_kwargs, always=True)
        log.info("Built DUT for the '%s' backend.", args.sim)

    if not args.build_only:
        test_kwargs = dict(
            hdl_toplevel=args.toplevel,
            test_module=args.test_module,
            timescale=args.timescale,
        )
        if args.test_args:
            test_kwargs["test_args"] = args.test_args
        runner.test(**test_kwargs)


def _check_bare_backend(argv, parser):
    """Reject backend names that would be silently ignored (gh-1: a bare
    backend token after the other options is swallowed by an earlier
    nargs="+" option, e.g. --pythonpath, and the run proceeds with the
    default backend — the override must be `--sim=<backend>`)."""
    skip_next = False
    for idx, tok in enumerate(argv):
        if skip_next:  # value of a space-separated --sim
            skip_next = False
            continue
        if tok == "--sim":
            skip_next = True
            continue
        if tok.startswith("--sim="):
            continue
        if tok in _KNOWN_BACKENDS and idx > 0:
            # idx == 0 is the documented positional backend; anything later
            # is a swallow victim (see docstring).
            parser.error(
                "bare backend token '%s' will NOT select a backend (it gets "
                "swallowed by the options around it); pass it explicitly as "
                "`--sim=%s`, or place it as the first positional argument." % (tok, tok))


def main(argv=None):
    parser = argparse.ArgumentParser(
        prog="cocotb_runner.py",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("sim", nargs="?", default=None,
                        help="Simulator backend (e.g. verilator, icarus, vcs).")
    parser.add_argument("--sim", dest="sim_opt", default=None,
                        help="Simulator backend, alternative to the positional argument.")
    parser.add_argument("--toplevel", required=True, help="DUT top-level module name.")
    parser.add_argument("--test-module", required=True,
                        help="Python module(s) holding the cocotb tests.")
    parser.add_argument("--sources", nargs="+", default=[],
                        help="Verilog/SystemVerilog sources for the DUT (plus the TB if a .v).")
    parser.add_argument("positional", nargs="*",
                        help="Sources passed after a `--` separator.")
    parser.add_argument("--pythonpath", nargs="+", default=[],
                        help="Directories to add to PYTHONPATH for the test module import.")
    parser.add_argument("--timescale", default="/".join(DEFAULT_TIMESCALE),
                        help="Simulation timescale, e.g. 1ns/1ps.")
    parser.add_argument("--build-only", action="store_true", help="Only build the DUT.")
    parser.add_argument("--test-only", action="store_true",
                        help="Reuse a previously built DUT; only run the tests.")
    parser.add_argument("--build-args", type=str, default="",
                        help="Extra args forwarded to run.build(), space/comma separated "
                             "(e.g. --build-args \"-Wno-WIDTH -Wno-COMBDLY\").")
    parser.add_argument("--test-args", type=str, default="",
                        help="Extra args forwarded to run.test(), space/comma separated.")
    parser.add_argument("--verbose", action="store_true", help="Enable debug logging.")
    if argv is None:
        argv = sys.argv[1:]
    _check_bare_backend(argv, parser)
    args = parser.parse_args(argv)

    # Split the raw build/test-arg strings into a list of flags.
    args.build_args = args.build_args.replace(",", " ").split()
    args.test_args = args.test_args.replace(",", " ").split()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s %(message)s",
    )

    # Resolve the simulator: positional > --sim > default.
    args.sim = args.sim_opt or args.sim or DEFAULT_SIM

    # Merge positional sources (from a trailing `--`) into --sources.
    sources = list(args.sources)
    for tok in args.positional:
        if not tok.startswith("-"):
            sources.append(tok)
    if not sources:
        parser.error("no DUT sources given (pass them via --sources or after --)")
    args.sources = sources

    # cocotb expects a timescale tuple.
    if "," in args.timescale:
        args.timescale = tuple(args.timescale.split(","))
    else:
        args.timescale = tuple(args.timescale.split("/"))

    _run(args)
    return 0


if __name__ == "__main__":
    sys.exit(main())
