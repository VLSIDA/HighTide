

# Write file list to disk, don't expand into env
export HW = $(BENCH_DESIGN_HOME)/src/vortex/rtl
export SYNTH_HDL_FRONTEND = slang
export VERILOG_INCLUDE_DIRS = \
  $(HW) \
  $(HW)/cache \
  $(HW)/core \
  $(HW)/fpu \
  $(HW)/interfaces \
  $(HW)/libs \
  $(HW)/mem
export VERILOG_DEFINES = -DSYNTHESIS -DSV_DPI -DMEM_BLOCK_SIZE=16 -DMAX_FANOUT=32 -DLATENCY_IMUL=5
# Ordering: packages → interfaces → libs → design modules → top
#
# Excluded directories:
#   afu/     — vendor AFU wrappers (OPAE/XRT), need external headers
#   tcu/     — optional tensor core extension (needs EXT_TCU_ENABLE)
#
# Excluded files:
#   Vortex_axi.sv          — AXI wrapper around Vortex, not needed for this top
#   VX_avs_adapter.sv      — Avalon adapter, only used by OPAE AFU
#   VX_axi_adapter.sv      — AXI adapter, only used by Vortex_axi.sv
#   VX_axi_write_ack.sv    — AXI helper, only used by VX_axi_adapter
#   VX_mem_bank_adapter.sv — not instantiated in Vortex hierarchy
#   VX_mem_data_adapter.sv — only used by AFU / Vortex_axi
 
# 1) Packages
_PKG_FILES = \
  $(HW)/VX_gpu_pkg.sv \
  $(HW)/VX_trace_pkg.sv \
  $(HW)/fpu/VX_fpu_pkg.sv
 
# 2) Interfaces (rtl/interfaces/ + scattered _if.sv in fpu/ and mem/)
_INTF_FILES = \
  $(wildcard $(HW)/interfaces/*.sv) \
  $(HW)/fpu/VX_fpu_csr_if.sv \
  $(HW)/mem/VX_gbar_bus_if.sv \
  $(HW)/mem/VX_lsu_mem_if.sv \
  $(HW)/mem/VX_mem_bus_if.sv
 
# 3) Library modules (excluding adapter files not in our hierarchy)
_LIB_FILES = $(filter-out \
  $(HW)/libs/VX_avs_adapter.sv \
  $(HW)/libs/VX_axi_adapter.sv \
  $(HW)/libs/VX_axi_write_ack.sv \
  $(HW)/libs/VX_mem_bank_adapter.sv \
  $(HW)/libs/VX_mem_data_adapter.sv, \
  $(wildcard $(HW)/libs/*.sv))
 
# 4) Cache
_CACHE_FILES = $(wildcard $(HW)/cache/*.sv)
 
# 5) FPU (VX_fpu_dpi.sv and VX_fpu_fpnew.sv are ifdef-gated out by SYNTHESIS)
_FPU_FILES = $(filter-out \
  $(HW)/fpu/VX_fpu_csr_if.sv \
  $(HW)/fpu/VX_fpu_pkg.sv, \
  $(wildcard $(HW)/fpu/*.sv))
 
# 6) Memory subsystem (excluding interface files already listed)
_MEM_FILES = $(filter-out \
  $(HW)/mem/VX_gbar_bus_if.sv \
  $(HW)/mem/VX_lsu_mem_if.sv \
  $(HW)/mem/VX_mem_bus_if.sv, \
  $(wildcard $(HW)/mem/*.sv))
 
# 7) Core
_CORE_FILES = $(wildcard $(HW)/core/*.sv)
 
# 8) Top-level
_TOP_FILES = \
  $(HW)/VX_cluster.sv \
  $(HW)/VX_socket.sv \
  $(HW)/Vortex.sv
 
export VERILOG_FILES = \
  $(_PKG_FILES) \
  $(_INTF_FILES) \
  $(_LIB_FILES) \
  $(_CACHE_FILES) \
  $(_FPU_FILES) \
  $(_MEM_FILES) \
  $(_CORE_FILES) \
  $(_TOP_FILES)

#export VERILOG_INCLUDE_DIRS := $(sort $(shell find $(VMOD) -type f -name "*.vh" -printf "%h\n" | sort -u))

