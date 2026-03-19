"""Shared Starlark helpers for HighTide2 design definitions."""

load("@bazel-orfs//:openroad.bzl", "orfs_flow")

# PDK label mapping per platform
PDKS = {
    "asap7": "@docker_orfs//:asap7",
    "nangate45": "//:nangate45",
    "sky130hd": "@docker_orfs//:sky130hd",
}

def hightide_design(name, platform, verilog_files, arguments = {}, sources = {}, **kwargs):
    """Wraps orfs_flow with HighTide2 defaults.

    Automatically sets GDS_ALLOW_EMPTY for FakeRAM and maps platform
    names to PDK labels.

    Args:
        name: Design name (becomes the ORFS DESIGN_NAME).
        platform: Target platform (asap7, nangate45, sky130hd).
        verilog_files: Verilog source file labels.
        arguments: ORFS flow arguments dict.
        sources: ORFS source file mappings (SDC_FILE, ADDITIONAL_LEFS, etc.).
        **kwargs: Additional arguments passed to orfs_flow.
    """
    merged_arguments = dict(arguments)
    merged_arguments.setdefault("GDS_ALLOW_EMPTY", "fakeram.*")

    orfs_flow(
        name = name,
        verilog_files = verilog_files,
        arguments = merged_arguments,
        sources = sources,
        pdk = PDKS[platform],
        **kwargs
    )
