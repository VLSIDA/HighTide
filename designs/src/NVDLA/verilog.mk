VMOD_RAM_DIR   := $(BENCH_DESIGN_HOME)/src/NVDLA/vmod/rams/synth
VMOD_VLIBS_DIR := $(BENCH_DESIGN_HOME)/src/NVDLA/vmod/vlibs
VMOD_NVDLA_DIR := $(BENCH_DESIGN_HOME)/src/NVDLA/vmod/nvdla

# Write file list to disk, don't expand into env

export VERILOG_FILES := $(shell find $(VMOD_RAM_DIR) $(VMOD_VLIBS_DIR) $(VMOD_NVDLA_DIR) -type f -name "*.v") \
						$(BENCH_DESIGN_HOME)/src/NVDLA/macros.v

export VERILOG_INCLUDE_DIRS := $(sort $(shell find $(VMOD) -type f -name "*.vh" -printf "%h\n" | sort -u))

