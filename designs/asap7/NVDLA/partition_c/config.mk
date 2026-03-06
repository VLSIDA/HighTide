export DESIGN_NAME = NV_NVDLA_partition_c
export PLATFORM    = asap7
export DESIGN_NICKNAME = NVDLA
export DESIGN_RESULTS_NAME = NVDLA_partition_c

-include $(BENCH_DESIGN_HOME)/src/NVDLA/verilog.mk

export SYNTH_HIERARCHICAL = 0

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/NVDLA/partition_c/constraint.sdc

export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x256_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x16_1r1w.lef \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_6x128_1r1w.lef \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_66x8_1r1w.lef \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_11x128_1r1w.lef

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x256_1r1w.lib \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x16_1r1w.lib \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_6x128_1r1w.lib \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_66x8_1r1w.lib \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_11x128_1r1w.lib

export CORE_UTILIZATION = 40

export PLACE_DENSITY_LB_ADDON = 0.33

export MACRO_PLACE_HALO    = 6 6

export TNS_END_PERCENT     = 100