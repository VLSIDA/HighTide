export DESIGN_NAME = liteeth_mac_axi_mii
export DESIGN_RESULTS_NAME = $(DESIGN_NAME)
export DESIGN_NICKNAME = liteeth
export PLATFORM    = nangate45

export USE_XILINX = 1

-include $(BENCH_DESIGN_HOME)/src/liteeth/build.mk

$(eval $(call build,axi-lite-mii.yml,mac_axi_mii.patch))

export SDC_FILE      = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_32w384d_sram.lef \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_32w384d_8wm_sram.lef

export ADDITIONAL_LIBS = \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_32w384d_sram.lib \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_32w384d_8wm_sram.lib

export GDS_ALLOW_EMPTY=fakeram*

export DIE_AREA = 0 0 700 700

export CORE_AREA = 15 15 685 685

export PLACE_DENSITY = 0.4

export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT = 2

export CELL_PAD_IN_SITES_DETAIL_PLACEMENT = 2

export MACRO_PLACE_HALO = 30 30

export ROUTING_LAYER_ADJUSTMENT = 0.25
