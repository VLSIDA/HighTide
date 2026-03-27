export DESIGN_NAME     = service_ihp_chip
export PLATFORM        = sky130hd
export DESIGN_NICKNAME = SYNtzulA

-include $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)/verilog.mk

export SDC_FILE      =   ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export DIE_AREA  =  0    0  2290 2290
export CORE_AREA = 40   40  2250 2250

export PLACE_DENSITY = 0.60

export HOLD_SLACK_MARGIN = 0.2 
