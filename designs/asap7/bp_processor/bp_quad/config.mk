export DESIGN_NICKNAME ?= bp_quad
export DESIGN_NAME = bp_processor
export PLATFORM    = asap7

export DEV_DESIGN_HOME = $(DESIGN_NAME)/dev

export SYNTH_HIERARCHICAL = 1
export SYNTH_MINIMUM_KEEP_SIZE = 500

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export VERILOG_TOP_PARAMS = bp_params_p 11

export ABC_AREA = 1

export SDC_FILE      = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NICKNAME)/constraint.sdc

export ADDITIONAL_LEFS = $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_8x174_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_32x48_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_32x66_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_64x50_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_64x184_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_128x8_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_512x8_1rw.lef \
                         $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_512x64_1rw.lef

export ADDITIONAL_LIBS = $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_8x174_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_32x48_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_32x66_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_64x50_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_64x184_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_128x8_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_512x8_1rw.lib \
                         $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_512x64_1rw.lib

export SYNTH_MEMORY_MAX_BITS = 65536

export DIE_AREA  = 0 0 1200 1200
export CORE_AREA = 10 10 1190 1190

export PLACE_PINS_ARGS = -min_distance 30 -min_distance_in_tracks
export MACRO_PLACE_HALO    = 6 6
export MACRO_BLOCKAGE_HALO = 0.5
export PLACE_DENSITY_LB_ADDON = 0.10
export TNS_END_PERCENT     = 100
