export DESIGN_NICKNAME ?= floonoc
export DESIGN_NAME = floo_floonoc_mesh_noc
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/floonoc/constraint.sdc

# Skip SVA assertions (guarded by ifndef VERILATOR in PULP sources)
export VERILOG_DEFINES = -D VERILATOR

export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.65
