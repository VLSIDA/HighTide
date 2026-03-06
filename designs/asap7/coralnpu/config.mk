export DESIGN_NAME = CoreMiniAxi
export PLATFORM    = asap7
export DESIGN_NICKNAME = coralnpu
export DESIGN_RESULTS_NAME = coralnpu

-include $(BENCH_DESIGN_HOME)/src/coralnpu/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/coralnpu/constraint.sdc

export CORE_AREA = 3 3 460 320
export DIE_AREA  = 0 0 463 323

export PLACE_DENSITY_LB_ADDON = 0.25

export MACRO_PLACE_HALO    = 5 5

export TNS_END_PERCENT     = 100