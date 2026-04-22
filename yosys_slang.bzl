"""Module extension to fetch and build the yosys-slang plugin.

Mirrors the pattern in bazel-orfs/test/downstream.  The plugin is
compiled as a cc_binary(name = "slang.so", linkshared = True) and
merged into the yosys share tree via merge_yosys_share in
//:BUILD.bazel.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def _yosys_slang_impl(_module_ctx):
    new_git_repository(
        name = "yosys-slang",
        remote = "https://github.com/povik/yosys-slang.git",
        commit = "4e53d772996184b07e9bfe784060f96e6cb0a267",
        init_submodules = True,
        build_file = Label("//:yosys_slang.BUILD.bazel"),
    )

yosys_slang = module_extension(
    implementation = _yosys_slang_impl,
)
