CNN_DEV_DIR := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev
CNN_BUILD_DIR := $(CNN_DEV_DIR)/cnn
CNN_DEV_RTL := $(CNN_BUILD_DIR)/cnn.v
CNN_DEV_FAKE_RTL = $(sort $(wildcard $(CNN_BUILD_DIR)/fakeram_*.v))
CNN_GEN_SCRIPT := $(CNN_DEV_DIR)/generate_cnn_verilog.sh

CNN_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/cnn.v
CNN_RELEASE_FAKE_RTL = $(sort $(wildcard $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/fakeram_*.v))

# Allow clean_design to prune dev-generated artifacts when desired.
export DEV_SRC := $(CNN_BUILD_DIR)

ifneq ($(wildcard $(DEV_FLAG)),)
$(CNN_DEV_RTL): $(CNN_GEN_SCRIPT)
	@echo "Generating CNN RTL via $(CNN_GEN_SCRIPT)"
	@cd $(CNN_DEV_DIR) && ./generate_cnn_verilog.sh

export VERILOG_FILES = $(CNN_DEV_RTL) $(CNN_DEV_FAKE_RTL)
else
# Prefer checked-in RTL; fall back to dev output if it has not been promoted yet.
ifeq ($(wildcard $(CNN_RELEASE_RTL)),)
$(warning $(CNN_RELEASE_RTL) is missing; using dev RTL. Run 'make dev' to regenerate and promote.)
export VERILOG_FILES = $(CNN_DEV_RTL) $(CNN_DEV_FAKE_RTL)
else
export VERILOG_FILES = $(CNN_RELEASE_RTL) $(CNN_RELEASE_FAKE_RTL)
endif
endif
