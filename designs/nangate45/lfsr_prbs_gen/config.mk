export DESIGN_NAME = lfsr_prbs_gen
export PLATFORM    = nangate45

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

export CORE_UTILIZATION = 20
export PLACE_DENSITY_LB_ADDON = 0.20
export TNS_END_PERCENT        = 100