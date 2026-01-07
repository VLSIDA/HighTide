export DESIGN_NAME = NyuziProcessor
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

export CORE_AREA = 3 3 500 497
export DIE_AREA  = 0 0 500 497

export PLACE_DENSITY_LB_ADDON = 0.22

export MACRO_PLACE_HALO    = 6 6

export TNS_END_PERCENT     = 100