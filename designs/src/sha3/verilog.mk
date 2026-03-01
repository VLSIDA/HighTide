SHA3_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev
SHA3_DEV_RTL := $(SHA3_DEV_DIR)/generated/$(DESIGN_NAME).v

SHA3_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v

ifneq ($(wildcard $(DEV_FLAG)),)
$(SHA3_DEV_RTL): $(SHA3_DEV_DIR)/setup.sh
	@echo "Generating SHA3 RTL via setup.sh"
	@cd $(SHA3_DEV_DIR) && bash setup.sh

export VERILOG_FILES = $(SHA3_DEV_RTL)
else
# Prefer checked-in RTL; fall back to dev output if it has not been promoted yet.
ifeq ($(wildcard $(SHA3_RELEASE_RTL)),)
$(warning $(SHA3_RELEASE_RTL) is missing; using dev RTL. Run 'make dev' to regenerate and promote.)
export VERILOG_FILES = $(SHA3_DEV_RTL)
else
export VERILOG_FILES = $(SHA3_RELEASE_RTL)
endif
endif
