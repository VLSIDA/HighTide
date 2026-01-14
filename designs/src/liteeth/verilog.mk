ROOT_DIR := $(shell git rev-parse --show-toplevel)

-include $(ROOT_DIR)/settings.mk

export LITEETH_DIR=$(BENCH_DESIGN_HOME)/src/liteeth
export PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)
export YML_PATH=$(LITEETH_DIR)/dev/repo/examples
export TARGET_FILE=$(LITEETH_DIR)/$(DESIGN_NAME).v
export BUILD_DIR_NAME:=liteeth_builds

define build
TARGET_YML := $(strip $(1))
PATCH_FILE := $(strip $(2))

$(shell \
	export LITEETH_DIR="$(LITEETH_DIR)"; \
	export YML_PATH="$(YML_PATH)"; \
	export BUILD_DIR_NAME="$(BUILD_DIR_NAME)"; \
	export DESIGN_NAME="$(DESIGN_NAME)"; \
	if [ ! -f "$(TARGET_FILE)" ] || \
	   [ "$(LITEETH_DIR)/dev/repo/examples/$(TARGET_YML)" -nt "$(TARGET_FILE)" ]; then \
		echo "Regenerating $(DESIGN_NAME)..." >&2; \
		bash "$(LITEETH_DIR)/gen.sh" "$(TARGET_YML)" && \
		patch --silent -N -l "$(TARGET_FILE)" < "$(LITEETH_DIR)/patch/$(PATCH_FILE)"; \
	fi \
)
endef

ifeq ($(PLATFORM),asap7)
    VERILOG_DEFINES = -D USE_ASAP7_CELLS
else ifeq ($(PLATFORM),nangate45)
    VERILOG_DEFINES = -D USE_NANGATE45_CELLS
else ifeq ($(PLATFORM),sky130hd)
    VERILOG_DEFINES = -D USE_SKY130HD_CELLS
endif

ifeq ($(USE_XILINX),1)
    VERILOG_FILES += \
        $(wildcard $(LITEETH_DIR)/libraries/xilinx/*.v)
else ifeq ($(USE_LATTICE),1)
    VERILOG_FILES += \
        $(wildcard $(LITEETH_DIR)/libraries/lattice/*.v)
endif

VERILOG_FILES += $(TARGET_FILE) $(LITEETH_DIR)/macros.v

export VERILOG_DEFINES
export VERILOG_FILES
