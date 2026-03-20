GEMMINI_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v

# Allow clean_design to prune dev-generated artifacts when desired.
export DEV_SRC := $(GEMMINI_DEV_DIR)/generated

export VERILOG_FILES = $(GEMMINI_RELEASE_RTL)
