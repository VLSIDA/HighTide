export DESIGN_NAME = NV_NVDLA_partition_p
export PLATFORM    = asap7
export DESIGN_NICKNAME = NVDLA
export DESIGN_RESULTS_NAME = NVDLA_partition_p

-include $(BENCH_DESIGN_HOME)/src/NVDLA/verilog.mk

export SYNTH_HIERARCHICAL = 1

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/NVDLA/partition_p/constraint.sdc

export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_16x160_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_65x160_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_14x80_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_66x80_1r1w.lef

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_16x160_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_65x160_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_14x80_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_66x80_1r1w.lib

export CORE_UTILIZATION = 45

export PLACE_DENSITY_LB_ADDON = 0.35

export MACRO_PLACE_HALO    = 5 5

export TNS_END_PERCENT     = 100