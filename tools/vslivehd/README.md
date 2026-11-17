# ASAP7 pre-CTS comparison

Build the tracked `//designs/asap7/...:*_place` targets and
`//tools/vslivehd:measurement_tools`. Stop at placement; CTS and routing are
outside this comparison. Freeze the source-built LiveHD and OpenROAD binaries
(and their runfiles) before measuring. The measurement_tools.paths output names
the OpenROAD executable used by the reference flow.

Pass the exact output directory for that build; a convenience bazel-bin symlink
can still point at another configuration. For example:

```sh
python3 tools/vslivehd/lhdsweep.py \
  --bin-dir /absolute/output-base/execroot/_main/bazel-out/k8-fastbuild/bin \
  --out artifacts/my-prects-run \
  --lhd /absolute/frozen/lhd --openroad /absolute/frozen/openroad \
  snapshot lfsr
```

Use the same global arguments with `run lfsr baseline --threads 8 --warm-runs 2`.
Each run tag must be new. Without --warm-runs the original single-run behavior
is preserved. With it, the runner checks two further invocations in the same
workdir: every mapped color must be a cache hit, with zero misses/store failures,
and exported placements must remain byte-identical. It also checks bare
`lhd synth` replay from workdir/synth. Filelist-based replay inspects dependencies
again and must reuse all mapped colors; safe whole-flow replay may do no work.

result.cold.json, result.warmN.json, result.replay.json and incremental.json keep
the evidence. lhd.run.json times only the cold invocation; incremental validation
has separate timing. Guard logs retain each command, memory use and exit status.
A failed synthesis, reuse check, placement legality check or common OpenSTA
scoring step gives a nonzero exit. Both flows use the same SDC, Liberty set,
placement RC and ideal clocks. Unknown timing does not count as meeting timing.

Run `python3 tools/vslivehd/test_incremental.py` to check the reuse acceptance gates.
