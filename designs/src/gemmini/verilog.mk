GEMMINI_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev
GEMMINI_DEV_RTL := $(GEMMINI_DEV_DIR)/generated/$(DESIGN_NAME).v

GEMMINI_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v

# Allow clean_design to prune dev-generated artifacts when desired.
export DEV_SRC := $(GEMMINI_DEV_DIR)/generated

ifneq ($(wildcard $(DEV_FLAG)),)
$(GEMMINI_DEV_RTL): $(GEMMINI_DEV_DIR)/setup.sh
	@echo "Generating Gemmini RTL via setup.sh"
	@cd $(GEMMINI_DEV_DIR) && bash setup.sh

export VERILOG_FILES = $(GEMMINI_DEV_RTL)
else
# Prefer checked-in RTL; fall back to dev output if it has not been promoted yet.
ifeq ($(wildcard $(GEMMINI_RELEASE_RTL)),)
$(warning $(GEMMINI_RELEASE_RTL) is missing; using dev RTL. Run 'make dev' to regenerate and promote.)
export VERILOG_FILES = $(GEMMINI_DEV_RTL)
else
export VERILOG_FILES = $(GEMMINI_RELEASE_RTL)
endif
endif
