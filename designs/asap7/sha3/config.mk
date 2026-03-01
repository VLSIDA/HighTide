export DESIGN_NICKNAME ?= sha3
export DESIGN_NAME = sha3
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/sha3/constraint.sdc

export CORE_UTILIZATION = 70
export PLACE_DENSITY = 0.75
