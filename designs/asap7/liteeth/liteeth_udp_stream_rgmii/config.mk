export DESIGN_NAME = liteeth_udp_stream_rgmii
export DESIGN_RESULTS_NAME = $(DESIGN_NAME)
export DESIGN_NICKNAME = liteeth
export PLATFORM    = asap7

export USE_XILINX = 1

-include $(BENCH_DESIGN_HOME)/src/liteeth/build.mk

$(eval $(call build,udp_s7phyrgmii.yml,udp_stream_rgmii.patch))

export SDC_FILE      = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_12w128d_sram.lef \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_64w64d_sram.lef

export ADDITIONAL_LIBS = \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_12w128d_sram.lib \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_64w64d_sram.lib

export GDS_ALLOW_EMPTY=fakeram*

export CORE_UTILIZATION = 35

export PLACE_DENSITY = 0.5

export MACRO_PLACE_HALO = 5 5
