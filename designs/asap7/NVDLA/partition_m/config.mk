export DESIGN_NAME = NV_NVDLA_partition_m
export PLATFORM    = asap7
export DESIGN_NICKNAME = NVDLA
export DESIGN_RESULTS_NAME = NVDLA_partition_m

-include $(BENCH_DESIGN_HOME)/src/NVDLA/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/NVDLA/partition_m/constraint.sdc

export CORE_UTILIZATION = 55

export PLACE_DENSITY_LB_ADDON = 0.2

export MACRO_PLACE_HALO    = 5 5

export TNS_END_PERCENT     = 100