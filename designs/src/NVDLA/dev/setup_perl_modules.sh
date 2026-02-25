#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PKG_ROOT="${ROOT_DIR}/packages"
PERL_PREFIX="${PKG_ROOT}/perl-5.10.1"
MARKERS="${PKG_ROOT}/_installed"
NAME="perl-mods-tmake-deps"

mkdir -p "${MARKERS}"

die() { echo "ERROR: $*" >&2; exit 1; }
is_done() { [[ -f "${MARKERS}/${1}.done" ]]; }
mark_done() { touch "${MARKERS}/${1}.done"; }

PERL_BIN="${PERL_PREFIX}/bin/perl"
CPANM_BIN="${PERL_PREFIX}/bin/cpanm"

[[ -x "${PERL_BIN}" ]] || die "Local perl not found at ${PERL_BIN}. Run install_perl-5.10.1.sh first."
[[ -x "${CPANM_BIN}" ]] || die "cpanm not found at ${CPANM_BIN}. Run install_perl-5.10.1.sh first."

if is_done "${NAME}"; then
  echo "[${NAME}] already installed"
  exit 0
fi

# Force we use this perl/cpanm
export PATH="${PERL_PREFIX}/bin:${PATH}"

# CRITICAL: do NOT use INSTALL_BASE / local-lib here, because @INC doesn't include lib/perl5
unset PERL_MM_OPT
unset PERL_MB_OPT
unset PERL_LOCAL_LIB_ROOT
unset PERL5LIB

# Install deps that tmake has complained about + your requested modules
"${CPANM_BIN}" --notest YAML IO::Tee XML::Simple Capture::Tiny

# Hard verify (fail immediately if not visible)
"${PERL_BIN}" -MYAML -e 'print "YAML OK\n"' >/dev/null || die "YAML.pm not loadable after install."
"${PERL_BIN}" -MIO::Tee -e 'print "IO::Tee OK\n"' >/dev/null || die "IO::Tee not loadable after install."

# Debug: show resolution paths
"${PERL_BIN}" -MYAML -e 'print "YAML.pm => $INC{\"YAML.pm\"}\n"'
"${PERL_BIN}" -MIO::Tee -e 'print "IO/Tee.pm => $INC{\"IO/Tee.pm\"}\n"'

mark_done "${NAME}"
echo "[${NAME}] installed into ${PERL_PREFIX}"