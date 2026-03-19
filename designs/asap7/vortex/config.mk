export DESIGN_NAME = Vortex
export PLATFORM    = asap7
export DESIGN_NICKNAME = vortex
export DESIGN_RESULTS_NAME = vortex

-include $(BENCH_DESIGN_HOME)/src/vortex/verilog.mk

export SYNTH_HIERARCHICAL = 0

export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_32x1024_1rw.lef \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_128x64_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_193x16_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_512x64_1rw.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_21x256_1r1w.lef \
 						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_128x256_1rw.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_85x16_1r1w.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_192x16_1r1w.lef
						 

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_32x1024_1rw.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_128x64_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_193x16_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_512x64_1rw.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_21x256_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_128x256_1rw.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_85x16_1r1w.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_192x16_1r1w.lib

export SDC_FILE      = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION = 50

export MACRO_PLACE_HALO    = 5 5

export PLACE_DENSITY_LB_ADDON = 0.46

export TNS_END_PERCENT     = 100

export IO_CONSTRAINTS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/vortex/io.tcl

# FOOTPRINT_TCL causes io_placement.tcl to skip place_pins (which would
# reorder our manually-placed pins). Pins are placed by IO_CONSTRAINTS
# during the floorplan step using place_pin (singular).
export FOOTPRINT_TCL = $(BENCH_DESIGN_HOME)/$(PLATFORM)/vortex/io.tcl