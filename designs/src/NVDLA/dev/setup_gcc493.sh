#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
PREFIX="${PKG_ROOT}/gcc-4.9.3"
TARBALLS="${PKG_ROOT}/_tarballs"
BUILD="${PKG_ROOT}/_build"
MARKERS="${PKG_ROOT}/_installed"
NAME="gcc-4.9.3"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "${PREFIX}" "${TARBALLS}" "${BUILD}" "${MARKERS}"

die() { echo "ERROR: $*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }
is_done() { [[ -f "${MARKERS}/${1}.done" ]]; }
mark_done() { touch "${MARKERS}/${1}.done"; }

fetch() {
  local url="$1" out="$2"
  if [[ -f "$out" ]]; then echo "[fetch] already exists: $out"; return 0; fi
  echo "[fetch] downloading: $url"
  if have_cmd curl; then
    curl -L --fail --retry 3 --retry-delay 2 -o "$out" "$url"
  elif have_cmd wget; then
    wget -O "$out" "$url"
  else
    die "Need curl or wget"
  fi
}

extract() {
  local tb="$1" dest="$2"
  mkdir -p "$dest"
  case "$tb" in
    *.tar.bz2) tar -xjf "$tb" -C "$dest" ;;
    *.tar.gz|*.tgz) tar -xzf "$tb" -C "$dest" ;;
    *.tar.xz) tar -xJf "$tb" -C "$dest" ;;
    *) die "Don't know how to extract: $tb" ;;
  esac
}

if is_done "${NAME}"; then
  echo "[${NAME}] already installed at ${PREFIX}"
  exit 0
fi

need_cmd tar
need_cmd make
need_cmd gcc
need_cmd g++
need_cmd curl || need_cmd wget

TB="${TARBALLS}/gcc-4.9.3.tar.bz2"
URL="https://ftp.gnu.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2"
fetch "$URL" "$TB"

SRC="${BUILD}/${NAME}-src"
rm -rf "$SRC"
mkdir -p "$SRC"
extract "$TB" "$SRC"

GCC_SRC="${SRC}/gcc-4.9.3"
cd "$GCC_SRC"

# Downloads GMP/MPFR/MPC/ISL into the source tree (preferred for legacy GCC)
if [[ -x ./contrib/download_prerequisites ]]; then
  ./contrib/download_prerequisites
else
  echo "[${NAME}] WARNING: contrib/download_prerequisites missing; you may need system libgmp/libmpfr/libmpc/libisl dev packages."
fi

BUILD_DIR="${BUILD}/${NAME}-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

"$GCC_SRC/configure" \
  --prefix="${PREFIX}" \
  --disable-multilib \
  --enable-languages=c,c++ \
  --disable-bootstrap

make -j"${JOBS}"
make install

mark_done "${NAME}"
echo "[${NAME}] installed to ${PREFIX}"
echo "Use it via: export PATH=\"${PREFIX}/bin:\$PATH\""