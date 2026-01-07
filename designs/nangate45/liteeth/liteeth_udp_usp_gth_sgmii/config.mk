export DESIGN_NAME = liteeth_udp_usp_gth_sgmii
export DESIGN_RESULTS_NAME = $(DESIGN_NAME)
export DESIGN_NICKNAME = liteeth
export PLATFORM    = nangate45

export USE_XILINX = 1

-include $(BENCH_DESIGN_HOME)/src/liteeth/build.mk

$(eval $(call build,udp_usp_gth_sgmii.yml,udp_usp_gth_sgmii.patch))

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_64w64d_sram.lef \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_64w1024d_sram.lef

export ADDITIONAL_LIBS = \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_64w64d_sram.lib \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_64w1024d_sram.lib

export GDS_ALLOW_EMPTY=fakeram*

export CORE_UTILIZATION = 45

export PLACE_DENSITY = 0.4

export ROUTING_LAYER_ADJUSTMENT = 0.2
