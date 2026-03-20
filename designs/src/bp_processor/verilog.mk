export PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)

BP_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v

# DEV_SRC intentionally left empty — regenerating BP RTL via sv2v is expensive.
# Use 'rm -rf designs/src/bp_processor/dev/generated' to manually clean.

# Prefer checked-in RTL; fall back to dev output if it has not been promoted yet.
export VERILOG_FILES = $(BP_RELEASE_RTL) \
                       $(PLATFORM_DESIGN_DIR)/macros.v

