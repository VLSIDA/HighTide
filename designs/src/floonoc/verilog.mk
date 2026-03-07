FLOONOC_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)/dev
FLOONOC_DEV_FILES := $(FLOONOC_DEV_DIR)/generated/files.txt

# Allow clean_design to prune dev-generated artifacts when desired.
export DEV_SRC := $(FLOONOC_DEV_DIR)/generated

# Use yosys-slang to read SystemVerilog directly (no sv2v needed)
export SYNTH_HDL_FRONTEND = slang

ifneq ($(wildcard $(DEV_FLAG)),)
$(FLOONOC_DEV_FILES): $(FLOONOC_DEV_DIR)/setup.sh
	@echo "Generating FlooNoC RTL via setup.sh"
	@cd $(FLOONOC_DEV_DIR) && bash setup.sh
endif

ifneq ($(wildcard $(FLOONOC_DEV_FILES)),)
# File lists contain paths relative to the dev directory; prepend it.
export VERILOG_FILES = $(addprefix $(FLOONOC_DEV_DIR)/,$(shell cat $(FLOONOC_DEV_DIR)/generated/files.txt))
export VERILOG_INCLUDE_DIRS = $(addprefix $(FLOONOC_DEV_DIR)/,$(shell cat $(FLOONOC_DEV_DIR)/generated/includes.txt))
else
$(warning FlooNoC file lists not found. Run 'make dev DESIGN_CONFIG=...' to generate.)
endif
