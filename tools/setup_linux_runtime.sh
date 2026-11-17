#!/usr/bin/env bash
# Supply Qt's host runtime libraries locally on minimal Debian/Ubuntu hosts.
# No sudo or system package installation. Package versions and hashes are saved
# so the exact runtime can be retained with a timing/QoR baseline.
set -euo pipefail

root=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
if [[ $(uname -s) != Linux || $(dpkg --print-architecture) != amd64 ]]; then
  echo "This helper supports Debian/Ubuntu amd64; install the Qt runtime for your host." >&2
  exit 1
fi
runtime="$root/scratch/qt-runtime"
mkdir -p "$runtime/debs" "$runtime/root"
(
  cd "$runtime/debs"
  apt-get download \
    libx11-xcb1 libsm6 libice6 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-randr0 libxcb-render0 libxcb-render-util0 \
    libxcb-shape0 libxcb-shm0 libxcb-sync1 libxcb-util1 libxcb-xfixes0 \
    libxcb-xkb1 libxkbcommon0 libxkbcommon-x11-0
  for package in ./*.deb; do
    dpkg-deb -x "$package" "$runtime/root"
  done
  sha256sum ./*.deb > "$runtime/packages.sha256"
  for package in ./*.deb; do
    dpkg-deb -f "$package" Package Version Architecture
  done > "$runtime/package-versions.txt"
)

# The flow actions intentionally sanitize their environment. An executable
# RUNPATH lets the loader find the local GUI libraries inside Bazel's sandbox
# without changing OpenROAD source or weakening the action environment.
libdir="$runtime/root/usr/lib/x86_64-linux-gnu"
touch "$root/.bazelrc.user"
for option in --linkopt --host_linkopt; do
  line="build $option=\"-Wl,-rpath,$libdir\""
  if ! grep -Fqx -- "$line" "$root/.bazelrc.user"; then
    printf '%s\n' "$line" >> "$root/.bazelrc.user"
  fi
done
echo "Local Qt libraries: $libdir"
echo "Bazel link settings appended to .bazelrc.user; retain scratch/qt-runtime with the baseline."
