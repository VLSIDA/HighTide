#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"
export USER=${USER:-no_user}
if [ "$HOME" = "/" ]; then
  HOME=/tmp/
fi

# Prerequisite Setup
bash "$(pwd)/install/install_jdk11.sh"
bash "$(pwd)/install/install_openssl.sh"
bash "$(pwd)/install/install_perl5_10.sh"
bash "$(pwd)/install/install_py2_6.sh"
bash "$(pwd)/install/install_systemc2_3_0.sh"

cp tree.make ./repo/tree.make

PKG_ROOT="${DIR}/packages"
PERL_PREFIX="${PKG_ROOT}/perl-5.10.1"
PY_PREFIX="${PKG_ROOT}/python-2.7.18"
PERL="${PERL_PREFIX}/bin/perl"
PYTHON="${PY_PREFIX}/bin/python"
export LD_LIBRARY_PATH="${PY_PREFIX}/lib:${LD_LIBRARY_PATH:-}"

cd repo
${PERL} ./tools/bin/tmake -build vmod
rm outdir/nv_small/vmod/nvdla/cfgrom/*
cp ../NV_NVDLA_cfgrom_REPLACE.v outdir/nv_small/vmod/nvdla/cfgrom/NV_NVDLA_cfgrom.v
cp -r outdir/nv_small/vmod ../../
