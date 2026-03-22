"""Shared Starlark helpers for HighTide2 design definitions."""

load("@bazel-orfs//:openroad.bzl", "orfs_flow")

# PDK label mapping per platform
PDKS = {
    "asap7": "@docker_orfs//:asap7",
    "nangate45": "//:nangate45",
    "sky130hd": "@docker_orfs//:sky130hd",
}

def hightide_design(name, platform, verilog_files, top = None, arguments = {}, sources = {}, **kwargs):
    """Wraps orfs_flow with HighTide2 defaults.

    Automatically sets GDS_ALLOW_EMPTY for FakeRAM and maps platform
    names to PDK labels.

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
