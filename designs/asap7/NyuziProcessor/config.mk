export DESIGN_NAME = NyuziProcessor
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

export CORE_UTILIZATION = 45

export PLACE_DENSITY_LB_ADDON = 0.15

export MACRO_PLACE_HALO    = 3 3

export TNS_END_PERCENT     = 100

do-3_3_place_gp: NUM_CORES = 1