export DESIGN_NAME = lfsr_prbs_gen
export PLATFORM    = sky130hd

-include $(BENCH_DESIGN_HOME)/src/lfsr/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/lfsr/constraint.sdc

export CORE_UTILIZATION 	= 40
export TNS_END_PERCENT      = 100
