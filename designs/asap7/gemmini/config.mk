export DESIGN_NICKNAME ?= gemmini
export DESIGN_NAME = gemmini
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/gemmini/constraint.sdc

export CORE_UTILIZATION = 60

export PLACE_PINS_ARGS = -min_distance 2 -min_distance_in_tracks
