export DESIGN_NICKNAME ?= floonoc
export DESIGN_NAME = floonoc_mesh_top
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/floonoc/constraint.sdc

# Skip SVA assertions (guarded by ifndef VERILATOR in PULP sources)
export VERILOG_DEFINES = -D VERILATOR

export DIE_AREA  = 0 0 1500 1500
export CORE_AREA = 2 2 1498 1498

export PLACE_DENSITY = 0.40
