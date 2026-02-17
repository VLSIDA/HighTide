export DESIGN_NICKNAME ?= cnn
export DESIGN_NAME = cnn
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

#export SYNTH_HIERARCHICAL ?= 1

export SYNTH_HIERARCHICAL = 1
export RTLMP_RPT_DIR = reports/$(PLATFORM)/cnn/base/rtlmp/
#export SYNTH_MINIMUM_KEEP_SIZE ?= 10000

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/cnn/constraint.sdc

ifeq ($(BLOCKS),)
	export ADDITIONAL_LEFS = $(sort $(wildcard $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/fakeram_*.lef))
	export ADDITIONAL_LIBS = $(sort $(wildcard $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/fakeram_*.lib))
endif

#export CORE_UTILIZATION       = 40
export DIE_AREA = 0 0 600 600
export CORE_AREA = 10 10 590 590 
#
#export PLACE_DENSITY_LB_ADDON = 0.10

#export IO_CONSTRAINTS     = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/io.tcl
export PLACE_PINS_ARGS = -min_distance 30 -min_distance_in_tracks
export MACRO_PLACE_HALO = 6 6
export MACRO_BLOCKAGE_HALO = 0.5
#export MACRO_ROWS_HALO_X = 0.5
#export MACRO_ROWS_HALO_Y = 0.5

#export MACRO_PLACEMENT = $(BENCH_DESIGN_HOME)/$(PLATFORM)/cnn/macro.cfg

#export TNS_END_PERCENT   = 100
#
#export CTS_CLUSTER_SIZE = 10
#export CTS_CLUSTER_DIAMETER = 50
