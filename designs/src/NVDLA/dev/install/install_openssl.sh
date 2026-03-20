#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
PREFIX="${PKG_ROOT}/openssl-1.0.2u"
TARBALLS="${PKG_ROOT}/_tarballs"
BUILD="${PKG_ROOT}/_build"
MARKERS="${PKG_ROOT}/_installed"
NAME="openssl-1.0.2u"
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
    *.tar.gz|*.tgz) tar -xzf "$tb" -C "$dest" ;;
    *.tar.bz2)      tar -xjf "$tb" -C "$dest" ;;
    *.tar.xz)       tar -xJf "$tb" -C "$dest" ;;
    *) die "Don't know how to extract: $tb" ;;
  esac
}

if is_done "${NAME}"; then
  echo "[${NAME}] already installed at ${PREFIX}"
  exit 0
fi
unset MAKEFLAGS MFLAGS MAKELEVEL 
need_cmd tar
need_cmd make
need_cmd gcc
need_cmd curl || need_cmd wget

TB="${TARBALLS}/openssl-1.0.2u.tar.gz"
URL="https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz"
fetch "$URL" "$TB"

SRC="${BUILD}/${NAME}-src"
rm -rf "$SRC"
mkdir -p "$SRC"
extract "$TB" "$SRC"

cd "${SRC}/openssl-1.0.2u"
./config shared --prefix="${PREFIX}" --openssldir="${PREFIX}/ssl"
make -j"${JOBS}"
make install_sw

mark_done "${NAME}"
echo "[${NAME}] installed to ${PREFIX}"