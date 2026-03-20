export PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)

BP_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev
BP_DEV_RTL := $(BP_DEV_DIR)/generated/$(DESIGN_NAME).v

BP_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v

# DEV_SRC intentionally left empty — regenerating BP RTL via sv2v is expensive.
# Use 'rm -rf designs/src/bp_processor/dev/generated' to manually clean.
export DEV_SRC :=

ifeq ($(DO_UPDATE),1)
$(BP_DEV_RTL): $(BP_DEV_DIR)/setup.sh
	@echo "Generating Black-Parrot RTL via setup.sh"
	@cd $(BP_DEV_DIR) && bash setup.sh

export VERILOG_FILES = $(BP_DEV_RTL) \
                       $(PLATFORM_DESIGN_DIR)/macros.v
else
# Prefer checked-in RTL; fall back to dev output if it has not been promoted yet.
ifeq ($(wildcard $(BP_RELEASE_RTL)),)
$(warning $(BP_RELEASE_RTL) is missing; using dev RTL. Run 'make update-rtl' to regenerate and promote.)
export VERILOG_FILES = $(BP_DEV_RTL) \
                       $(PLATFORM_DESIGN_DIR)/macros.v
else
export VERILOG_FILES = $(BP_RELEASE_RTL) \
                       $(PLATFORM_DESIGN_DIR)/macros.v
endif
endif
