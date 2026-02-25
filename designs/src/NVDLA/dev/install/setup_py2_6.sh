#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
PREFIX="${PKG_ROOT}/python-2.6.9"
OPENSSL_PREFIX="${PKG_ROOT}/openssl-1.0.2u"
TARBALLS="${PKG_ROOT}/_tarballs"
BUILD="${PKG_ROOT}/_build"
MARKERS="${PKG_ROOT}/_installed"
NAME="python-2.6.9"
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

need_cmd tar
need_cmd make
need_cmd gcc
need_cmd curl || need_cmd wget

# Require OpenSSL 1.0.2u installed (Python 2.6 ssl on modern Ubuntu otherwise breaks)
[[ -d "${OPENSSL_PREFIX}/include" ]] || die "OpenSSL 1.0.2u not found at ${OPENSSL_PREFIX}. Run install_openssl-1.0.2u.sh first."

TB="${TARBALLS}/Python-2.6.9.tgz"
URL="https://www.python.org/ftp/python/2.6.9/Python-2.6.9.tgz"
fetch "$URL" "$TB"

SRC="${BUILD}/${NAME}-src"
rm -rf "$SRC"
mkdir -p "$SRC"
extract "$TB" "$SRC"

cd "${SRC}/Python-2.6.9"

export CPPFLAGS="-I${OPENSSL_PREFIX}/include"
export LDFLAGS="-L${OPENSSL_PREFIX}/lib"
export LD_LIBRARY_PATH="${OPENSSL_PREFIX}/lib:${LD_LIBRARY_PATH:-}"

./configure --prefix="${PREFIX}" --enable-shared
make -j"${JOBS}"
make install

mark_done "${NAME}"
echo "[${NAME}] installed to ${PREFIX}"
echo "Runtime note: set LD_LIBRARY_PATH so libpython can be found:"
echo "  export LD_LIBRARY_PATH=\"${PREFIX}/lib:${OPENSSL_PREFIX}/lib:\$LD_LIBRARY_PATH\""