export DESIGN_NICKNAME ?= gemmini
export DESIGN_NAME = gemmini
export PLATFORM    = asap7

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/verilog.mk

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/gemmini/constraint.sdc

export CORE_UTILIZATION = 35

export PDN_TCL = $(BENCH_DESIGN_HOME)/$(PLATFORM)/gemmini/pdn.tcl

export IO_CONSTRAINTS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/gemmini/io.tcl

# FOOTPRINT_TCL causes io_placement.tcl to skip place_pins (which would
# reorder our manually-placed pins). Pins are placed by IO_CONSTRAINTS
# during the floorplan step using place_pin (singular).
export FOOTPRINT_TCL = $(BENCH_DESIGN_HOME)/$(PLATFORM)/gemmini/io.tcl
