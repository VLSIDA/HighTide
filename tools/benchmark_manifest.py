"""Write portable design and platform manifests for a benchmark bundle."""

import json
import os
import shlex
import subprocess
from pathlib import Path

_DESIGN_SCRIPTS = {
    "io_constraints": "IO_CONSTRAINTS",
    "footprint": "FOOTPRINT_TCL",
    "pdn": "PDN_TCL",
    "macro_placement": "MACRO_PLACEMENT_TCL",
    "fastroute": "FASTROUTE_TCL",
    "pre_cts": "PRE_CTS_TCL",
    "pre_global_route": "PRE_GLOBAL_ROUTE_TCL",
}
_FLOORPLAN_SCALARS = {
    "core_utilization": "CORE_UTILIZATION",
    "core_aspect_ratio": "CORE_ASPECT_RATIO",
    "core_margin": "CORE_MARGIN",
    "place_density": "PLACE_DENSITY",
    "place_density_lb_addon": "PLACE_DENSITY_LB_ADDON",
}
_FLOORPLAN_LISTS = {
    "die_area": "DIE_AREA",
    "core_area": "CORE_AREA",
    "macro_place_halo": "MACRO_PLACE_HALO",
    "macro_blockage_halo": "MACRO_BLOCKAGE_HALO",
}
_ROUTING_LAYERS = {
    "minimum_signal_layer": "MIN_ROUTING_LAYER",
    "maximum_signal_layer": "MAX_ROUTING_LAYER",
    "minimum_clock_layer": "MIN_CLK_ROUTING_LAYER",
    "maximum_clock_layer": "MAX_CLK_ROUTING_LAYER",
}
_PLATFORM_PATH_LISTS = {
    "technology_lef": ("TECH_LEF",),
    "cell_lefs": ("SC_LEF", "ADDITIONAL_LEFS"),
    "liberty_files": ("LIB_FILES",),
    "gds_files": ("GDS_FILES",),
}
_PLATFORM_SCRIPTS = {
    "make_tracks": "MAKE_TRACKS",
    "tapcell": "TAPCELL_TCL",
    "pdn": "PDN_TCL",
    "set_rc": "SET_RC_TCL",
    "fastroute": "FASTROUTE_TCL",
}
_PLATFORM_VARIABLES = (
    *(key for keys in _PLATFORM_PATH_LISTS.values() for key in keys),
    "PLACE_SITE",
    *_ROUTING_LAYERS.values(),
    "RCX_RULES",
    "PWR_NETS_VOLTAGES",
    "GND_NETS_VOLTAGES",
    *_PLATFORM_SCRIPTS.values(),
)


def _number(value):
    if value is None or value == "":
        return None
    number = float(value)
    return int(number) if number.is_integer() else number


def _numbers(value):
    return [_number(token) for token in value.split()] if value else []


def _bool(value):
    return {"0": False, "1": True}[value] if value is not None else None


def _design_path(token, inputs, manifest_dir):
    prefix = "$(PREPARED_INPUTS)/"
    if not token.startswith(prefix):
        raise ValueError(f"Input was not staged: {token}")
    path = Path(inputs) / token[len(prefix) :]
    if not path.exists():
        raise FileNotFoundError(path)
    return os.path.relpath(path, manifest_dir)


def _design_paths(values, key, inputs, manifest_dir):
    return [
        _design_path(token, inputs, manifest_dir)
        for token in values.get(key, "").split()
    ]


def _one_design_path(values, key, inputs, manifest_dir):
    paths = _design_paths(values, key, inputs, manifest_dir)
    return paths[0] if paths else None


def _platform_paths(variables, keys, platform_dir):
    paths = []
    for key in keys:
        for token in variables.get(key, "").split():
            if not (Path(platform_dir) / token).is_file():
                raise FileNotFoundError(f"{key}: {token}")
            if os.path.isabs(token):
                token = os.path.relpath(token, platform_dir)
            if token and token not in paths:
                paths.append(token)
    return paths


def resolve_platform_variables(platform_dir):
    """Evaluate exported platform defaults while Make is available."""
    prefix = "__HIGHTIDE_PLATFORM__"
    makefile = (
        "include $(PLATFORM_DIR)/config.mk\n"
        + "$(foreach v,"
        + " ".join(_PLATFORM_VARIABLES)
        + ",$(info "
        + prefix
        + "$(v)=$($(v))))\n.PHONY: all\nall:\n\t@:\n"
    )
    result = subprocess.run(
        [
            "make",
            "--no-print-directory",
            "-s",
            "-f",
            "-",
            f"PLATFORM_DIR={os.path.abspath(platform_dir)}",
            "all",
        ],
        input=makefile,
        text=True,
        capture_output=True,
        check=True,
        # Shell overrides (including MAKEFLAGS) must not affect a pinned export.
        env={"PATH": os.environ.get("PATH", os.defpath)},
    )
    variables = {}
    for line in result.stdout.splitlines():
        if line.startswith(prefix):
            key, value = line[len(prefix) :].split("=", 1)
            variables[key] = value.strip()
    return variables


def _write_platform_manifest(platform_dir, platform):
    destination = os.path.join(platform_dir, "manifest.json")
    variables = resolve_platform_variables(platform_dir)
    scripts = {
        name: paths[0]
        for name, key in _PLATFORM_SCRIPTS.items()
        if (paths := _platform_paths(variables, (key,), platform_dir))
    }
    manifest = {
        "schema_version": 1,
        "kind": "hightide-platform",
        "platform": platform,
        "files": {
            name: _platform_paths(variables, keys, platform_dir)
            for name, keys in _PLATFORM_PATH_LISTS.items()
        },
        "place_site": variables.get("PLACE_SITE") or None,
        "routing": {
            **{
                name: variables.get(key) or None
                for name, key in _ROUTING_LAYERS.items()
            },
            "rcx_rules": (
                _platform_paths(variables, ("RCX_RULES",), platform_dir) or [None]
            )[0],
        },
        "power": {
            "power_nets_and_voltages": shlex.split(
                variables.get("PWR_NETS_VOLTAGES", "")
            ),
            "ground_nets_and_voltages": shlex.split(
                variables.get("GND_NETS_VOLTAGES", "")
            ),
        },
        "scripts": scripts,
    }
    with open(destination, "w") as manifest_file:
        json.dump(manifest, manifest_file, indent=2, sort_keys=True)
        manifest_file.write("\n")
    return destination


def write_manifests(destination, inputs, values, platform_dir):
    """Write one design manifest and its shared platform manifest."""
    slang_arguments = shlex.split(values.get("SYNTH_SLANG_ARGS", ""))
    if any(argument.startswith("-I") for argument in slang_arguments):
        raise ValueError("Move Slang -I paths to VERILOG_INCLUDE_DIRS before staging")
    manifest_dir = os.path.dirname(os.path.abspath(destination))
    platform = values["PLATFORM"]
    platform_manifest = _write_platform_manifest(platform_dir, platform)

    scripts = {
        name: path
        for name, key in _DESIGN_SCRIPTS.items()
        if (path := _one_design_path(values, key, inputs, manifest_dir))
    }
    floorplan = {
        name: value
        for name, key in _FLOORPLAN_SCALARS.items()
        if (value := _number(values.get(key))) is not None
    }
    floorplan.update(
        {
            name: value
            for name, key in _FLOORPLAN_LISTS.items()
            if (value := _numbers(values.get(key, "")))
        }
    )
    floorplan["scripts"] = scripts

    manifest = {
        "schema_version": 1,
        "kind": "hightide-design",
        "design": {"name": values["DESIGN_NAME"], "platform": platform},
        "platform_manifest": os.path.relpath(platform_manifest, manifest_dir),
        "rtl": {
            "files": _design_paths(values, "VERILOG_FILES", inputs, manifest_dir),
            "include_directories": _design_paths(
                values, "VERILOG_INCLUDE_DIRS", inputs, manifest_dir
            ),
            "defines": shlex.split(values.get("VERILOG_DEFINES", "")),
            "top_parameters": shlex.split(values.get("VERILOG_TOP_PARAMS", "")),
            "frontend": values.get("SYNTH_HDL_FRONTEND") or None,
        },
        "constraints": {
            "sdc": _one_design_path(values, "SDC_FILE", inputs, manifest_dir),
        },
        "macros": {
            "lef_files": _design_paths(values, "ADDITIONAL_LEFS", inputs, manifest_dir),
            "liberty_files": _design_paths(
                values, "ADDITIONAL_LIBS", inputs, manifest_dir
            ),
            "gds_files": _design_paths(values, "ADDITIONAL_GDS", inputs, manifest_dir),
            "allow_missing_gds": values.get("GDS_ALLOW_EMPTY") or None,
        },
        "synthesis": {
            "hierarchical": _bool(values.get("SYNTH_HIERARCHICAL")),
            "arguments": shlex.split(values.get("SYNTH_ARGS", "")),
            "slang_arguments": slang_arguments,
            "memory_max_bits": _number(values.get("SYNTH_MEMORY_MAX_BITS")),
        },
        "floorplan": floorplan,
        "routing": {
            name: values[key] for name, key in _ROUTING_LAYERS.items() if key in values
        },
    }
    with open(destination, "w") as manifest_file:
        json.dump(manifest, manifest_file, indent=2, sort_keys=True)
        manifest_file.write("\n")
