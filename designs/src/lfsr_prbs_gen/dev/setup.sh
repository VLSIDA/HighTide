#!/bin/bash

set -euo pipefail

cd -- "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

cp repo/rtl/lfsr_prbs_gen.v repo/rtl/lfsr.v repo/rtl/lfsr_prbs_check.v ../