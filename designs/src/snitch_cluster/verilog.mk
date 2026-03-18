SNITCH_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)/dev
SNITCH_DEV_FILES := $(SNITCH_DEV_DIR)/generated/files.txt

# Allow clean_design to prune dev-generated artifacts when desired.
export DEV_SRC := $(SNITCH_DEV_DIR)/generated

# Use yosys-slang to read SystemVerilog directly (no sv2v needed)
export SYNTH_HDL_FRONTEND = slang

ifneq ($(wildcard $(DEV_FLAG)),)
$(SNITCH_DEV_FILES): $(SNITCH_DEV_DIR)/setup.sh
	@echo "Generating Snitch Cluster RTL via setup.sh"
	@cd $(SNITCH_DEV_DIR) && bash setup.sh
endif

ifneq ($(wildcard $(SNITCH_DEV_FILES)),)
# File lists contain paths relative to the dev directory; prepend it.
export VERILOG_FILES = $(addprefix $(SNITCH_DEV_DIR)/,$(shell cat $(SNITCH_DEV_DIR)/generated/files.txt))
export VERILOG_INCLUDE_DIRS = $(addprefix $(SNITCH_DEV_DIR)/,$(shell cat $(SNITCH_DEV_DIR)/generated/includes.txt))
else
$(warning Snitch Cluster file lists not found. Run 'make dev DESIGN_CONFIG=...' to generate.)
endif
