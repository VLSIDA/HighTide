"""Shared Starlark helpers for HighTide design definitions."""

load("@bazel-orfs//:openroad.bzl", "orfs_flow", "orfs_run")

# PDK label mapping per platform
PDKS = {
    "asap7": "@orfs//flow:asap7",
    "gt2n": "@orfs//flow:gt2n",
    "nangate45": "@orfs//flow:nangate45",
    "sky130hd": "@orfs//flow:sky130hd",
}

def _gallery_image(name, src):
    """Render a final-stage screenshot from a routed ODB.

    Produces <name>.png via xvfb-run + OpenROAD GUI.
    """
    orfs_run(
        name = name,
        src = src,
        outs = [name + ".png"],
        arguments = {
            "GALLERY_IMAGE": "$(location :" + name + ".png)",
            "OR_ARGS": "-gui",
        },
        extra_args = "OPENROAD_CMD='xvfb-run -a $(OPENROAD_EXE) -exit $(OPENROAD_ARGS)'",
        script = "//tools/gallery:final_image.tcl",
    )

# Stages for which we emit a <name>_gui_<stage> bazel-run launcher.
# Mirrors orfs_flow's per-stage output targets (synth … final).
_GUI_STAGES = ("synth", "floorplan", "place", "cts", "grt", "route", "final")

def _gui_launcher(name, stage):
    """Emit a `bazel run :<name>_gui_<stage>` shortcut.

    Loads the stage ODB (and matching SDC, if any) into the OpenROAD GUI
    directly — no ORFS Makefile, no `bazel run @bazel-orfs//:deps -- …`
    incantation. The launcher works as long as the stage target has been
    built (or is buildable as a runfiles dep).
    """
    native.sh_binary(
        name = name + "_gui_" + stage,
        srcs = ["//tools/gui:launch_gui.sh"],
        data = [
            ":" + name + "_" + stage,
            "//tools/gui:open_db.tcl",
            "@openroad//:openroad",
        ],
        args = [
            "$(rootpath @openroad//:openroad)",
            "$(rootpath //tools/gui:open_db.tcl)",
        ],
        tags = ["manual"],
    )

def hightide_design(name, platform, verilog_files, top = None, arguments = {}, sources = {}, **kwargs):
    """Wraps orfs_flow with HighTide defaults.

    Automatically sets GDS_ALLOW_EMPTY for FakeRAM, maps platform
    names to PDK labels, and emits a <name>_gallery target rendering
    a final-stage screenshot from the routed ODB.

    Args:
        name: Base name for Bazel targets.
        platform: Target platform (asap7, nangate45, sky130hd).
        verilog_files: Verilog source file labels.
        top: Verilog top-level module name. Defaults to name.
        arguments: ORFS flow arguments dict.
        sources: ORFS source file mappings (SDC_FILE, ADDITIONAL_LEFS, etc.).
        **kwargs: Additional arguments passed to orfs_flow.
    """
    merged_arguments = dict(arguments)
    merged_arguments.setdefault("GDS_ALLOW_EMPTY", "fakeram.*")

    flow_kwargs = dict(
        name = name,
        verilog_files = verilog_files,
        arguments = merged_arguments,
        sources = sources,
        pdk = PDKS[platform],
    )
    if top:
        flow_kwargs["top"] = top
    flow_kwargs.update(kwargs)

    orfs_flow(**flow_kwargs)

    _gallery_image(
        name = name + "_gallery",
        src = ":" + name + "_final",
    )

    for stage in _GUI_STAGES:
        _gui_launcher(name, stage)
