#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
TARBALLS="${PKG_ROOT}/_tarballs"
BUILD="${PKG_ROOT}/_build"
MARKERS="${PKG_ROOT}/_installed"

NAME="jdk1.7"
MARKER="${MARKERS}/${NAME}.done"

mkdir -p "${PKG_ROOT}" "${TARBALLS}" "${BUILD}" "${MARKERS}"

die() { echo "ERROR: $*" >&2; exit 1; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }
need_cmd() { have_cmd "$1" || die "Missing required command: $1"; }

fetch() {
  # fetch <url> <out>
  local url="$1" out="$2"
  if [[ -f "$out" ]]; then
    echo "[fetch] already exists: $out"
    return 0
  fi

  echo "[fetch] downloading: $url"
  if have_cmd curl; then
    # Optional: pass Oracle cookie header via ORACLE_COOKIE (entire Cookie: string)
    # Example:
    #   export ORACLE_COOKIE='oraclelicense=accept-securebackup-cookie; s_cc=true; ...'
    if [[ -n "${ORACLE_COOKIE:-}" ]]; then
      curl -L --fail --retry 3 --retry-delay 2 \
        -H "Cookie: ${ORACLE_COOKIE}" \
        -H "User-Agent: Mozilla/5.0" \
        -o "$out" "$url"
    else
      curl -L --fail --retry 3 --retry-delay 2 \
        -H "User-Agent: Mozilla/5.0" \
        -o "$out" "$url"
    fi
  elif have_cmd wget; then
    if [[ -n "${ORACLE_COOKIE:-}" ]]; then
      wget --header="Cookie: ${ORACLE_COOKIE}" --header="User-Agent: Mozilla/5.0" -O "$out" "$url"
    else
      wget --header="User-Agent: Mozilla/5.0" -O "$out" "$url"
    fi
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

# -----------------------------
# Main
# -----------------------------
if [[ -f "$MARKER" ]]; then
  echo "[${NAME}] already installed (marker: ${MARKER})"
  exit 0
fi

need_cmd tar
need_cmd sed
need_cmd awk
need_cmd grep
need_cmd curl || need_cmd wget

# You must provide a URL that yields the actual tar.gz bytes.
# If the URL is Oracle-gated, also set ORACLE_COOKIE.
: "${JDK_URL:?Set JDK_URL to the JDK7 tarball URL (e.g., export JDK_URL='https://.../jdk-7u80-linux-x64.tar.gz')}"

# Filename can be overridden; default assumes 7u80 x64 tarball name.
JDK_TARBALL_NAME="${JDK_TARBALL_NAME:-jdk-7u80-linux-x64.tar.gz}"
TB="${TARBALLS}/${JDK_TARBALL_NAME}"

fetch "${JDK_URL}" "${TB}"

# Basic sanity: reject HTML error pages downloaded as .tar.gz
if file "${TB}" | grep -qiE 'HTML|text'; then
  head -n 5 "${TB}" >&2 || true
  rm -f "${TB}"
  die "Downloaded file is not a gzip tarball (likely Oracle login/license gate). Provide ORACLE_COOKIE or use a direct-access mirror URL."
fi

# Verify tarball is readable (quick check)
if ! tar -tzf "${TB}" >/dev/null 2>&1; then
  rm -f "${TB}"
  die "Downloaded file is not a valid .tar.gz tarball."
fi

TMPDIR="${BUILD}/jdk1.7-extract"
rm -rf "${TMPDIR}"
mkdir -p "${TMPDIR}"
extract "${TB}" "${TMPDIR}"

# Oracle/OpenJDK tarball should contain a top directory like jdk1.7.0_80
JDK_DIR="$(find "${TMPDIR}" -maxdepth 1 -type d -name 'jdk1.7.0_*' | head -n 1 || true)"
[[ -n "${JDK_DIR}" ]] || die "Could not find extracted jdk1.7.0_* directory in ${TMPDIR}"

REAL_DIR="${PKG_ROOT}/$(basename "${JDK_DIR}")"
rm -rf "${REAL_DIR}"
cp -a "${JDK_DIR}" "${REAL_DIR}"

# Stable symlink
ln -sfn "$(basename "${REAL_DIR}")" "${PKG_ROOT}/jdk1.7"

touch "${MARKER}"
echo "[${NAME}] installed to ${REAL_DIR}"
echo "JAVA_HOME can be set to: ${PKG_ROOT}/jdk1.7"
echo "Add to PATH via: export PATH=\"${PKG_ROOT}/jdk1.7/bin:\$PATH\""