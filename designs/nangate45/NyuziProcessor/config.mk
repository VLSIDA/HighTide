export DESIGN_NAME = NyuziProcessor
export PLATFORM    = nangate45

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

export CORE_UTILIZATION = 55

export PLACE_DENSITY_LB_ADDON = 0.25

export MACRO_PLACE_HALO    = 50 50

export TNS_END_PERCENT     = 100

export FASTROUTE_TCL = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/fastroute.tcl