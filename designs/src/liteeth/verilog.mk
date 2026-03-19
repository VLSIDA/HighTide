ROOT_DIR := $(shell git rev-parse --show-toplevel)

-include $(ROOT_DIR)/settings.mk

export LITEETH_DIR=$(BENCH_DESIGN_HOME)/src/liteeth
export PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)
export YML_PATH=$(LITEETH_DIR)/dev/repo/examples
export TARGET_FILE=$(LITEETH_DIR)/$(DESIGN_NAME).v
export BUILD_DIR_NAME:=liteeth_builds

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

ifeq ($(MAKELEVEL),1)
ifneq ($(wildcard $(DEV_FLAG)),)
ifeq ($(DESIGN_NAME),liteeth_mac_axi_mii)
    YAML_FILE = axi-lite-mii.yml
    PATCH_FILE = mac_axi_mii.patch
endif
ifeq ($(DESIGN_NAME),liteeth_mac_wb_mii)
    YAML_FILE = wishbone_mii.yml
    PATCH_FILE = mac_wb_mii.patch
endif
ifeq ($(DESIGN_NAME),liteeth_udp_raw_rgmii)
    YAML_FILE = udp_raw_ecp5rgmii.yml
    PATCH_FILE = udp_raw_rgmii.patch
endif
ifeq ($(DESIGN_NAME),liteeth_udp_stream_rgmii)
    YAML_FILE = udp_s7phyrgmii.yml
    PATCH_FILE = udp_stream_rgmii.patch
endif
ifeq ($(DESIGN_NAME),liteeth_udp_stream_sgmii)
    YAML_FILE = udp_a7_gtp_sgmii.yml
    PATCH_FILE = udp_stream_sgmii.patch
endif
ifeq ($(DESIGN_NAME),liteeth_udp_usp_gth_sgmii)
    YAML_FILE = udp_usp_gth_sgmii.yml
    PATCH_FILE = udp_usp_gth_sgmii.patch
endif
# Inputs (pick the one you actually use)
export TARGET_YML      = $(YML_PATH)/$(YAML_FILE)
export PATCH_FILE_PATH = $(LITEETH_DIR)/patch/$(PATCH_FILE)
# Re-generate whenever make update-rtl is called
.PHONY: $(TARGET_FILE)
$(TARGET_FILE): $(TARGET_YML) $(PATCH_FILE_PATH)
	@echo "Regenerating $(DESIGN_NAME)..."
	bash "$(LITEETH_DIR)/gen.sh" "$(TARGET_YML)" "$(YML_PATH)" "$(LITEETH_DIR)" "$(DESIGN_NAME)"
	patch --silent -N -l "$(TARGET_FILE)" < "$(PATCH_FILE_PATH)"
endif
endif

export VERILOG_DEFINES
export VERILOG_FILES
