#!/usr/bin/env python3
"""Stage one pinned ORFS platform into a shared benchmark export.

The destination is a generated ``platforms/`` directory shared by every
design bundle.  The ORFS ``common`` platform files are copied once alongside
the requested platform, and symlinks are dereferenced so the export remains
portable after it leaves the Bazel output base.

Usage: stage_platform.py <orfs-platforms-dir> <platform> <destination> <source-id>
"""

import json
import shutil
import sys
import tempfile
from pathlib import Path


SOURCE_FILE = ".hightide-platform-source.json"


def _copy_tree(source: Path, destination: Path) -> None:
    temporary = Path(
        tempfile.mkdtemp(prefix=f".{destination.name}.", dir=destination.parent)
    )
    try:
        shutil.rmtree(temporary)
        shutil.copytree(
            source,
            temporary,
            symlinks=False,
        )
        temporary.replace(destination)
    finally:
        if temporary.exists():
            shutil.rmtree(temporary)


def stage_platform(
    source_root: Path, platform: str, destination_root: Path, source_id: str
) -> bool:
    """Copy ``platform`` and common files, returning true when files changed."""
    source_root = source_root.resolve()
    source_platform = source_root / platform
    if not (source_platform / "config.mk").is_file():
        raise FileNotFoundError(
            f"ORFS platform {platform!r} has no config.mk under {source_root}"
        )

    destination_root.mkdir(parents=True, exist_ok=True)
    marker = destination_root / SOURCE_FILE
    previous_id = None
    if marker.is_file():
        previous_id = json.loads(marker.read_text()).get("source_id")

    if previous_id not in (None, source_id):
        # Replacing shared platforms would invalidate designs already exported
        # against the old pin, including designs outside this invocation.
        raise RuntimeError("platform source changed; use a new --benchmark-dir")
    if previous_id is None and any(destination_root.iterdir()):
        raise RuntimeError(
            f"refusing to replace non-HighTide platform directory: {destination_root}"
        )

    changed = False
    common_source = source_root / "common"
    common_destination = destination_root / "common"
    if common_source.is_dir() and not common_destination.exists():
        _copy_tree(common_source, common_destination)
        changed = True

    platform_destination = destination_root / platform
    if not platform_destination.exists():
        _copy_tree(source_platform, platform_destination)
        changed = True

    orfs_root = source_root.parent.parent
    for license_name in ("LICENSE", "LICENSE.md", "COPYING"):
        license_source = orfs_root / license_name
        license_destination = destination_root / f"ORFS_{license_name}"
        if license_source.is_file():
            if not license_destination.exists():
                shutil.copy2(license_source, license_destination)
                changed = True
            break

    marker.write_text(
        json.dumps(
            {
                "source_id": source_id,
                "source": "OpenROAD-flow-scripts",
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )
    return changed


def main() -> None:
    if len(sys.argv) != 5:
        sys.exit(
            "usage: stage_platform.py <orfs-platforms-dir> "
            "<platform> <destination> <source-id>"
        )

    source_root, platform, destination_root, source_id = sys.argv[1:]
    try:
        changed = stage_platform(
            Path(source_root), platform, Path(destination_root), source_id
        )
    except (FileNotFoundError, RuntimeError) as error:
        sys.exit(f"error: {error}")

    action = "Staged" if changed else "Reused"
    print(f"{action} platform {platform} in {destination_root}", file=sys.stderr)


if __name__ == "__main__":
    main()
