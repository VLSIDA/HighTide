# Platform default (platforms/gt2n/setRC.tcl) models clock wire RC at M5
# (166.95 ohm/um, top of the local tier). Re-model at M6, the first
# intermediate-tier layer (26.55 ohm/um), to match MIN_CLK_ROUTING_LAYER=M6.
set_wire_rc -clock -layer M6
