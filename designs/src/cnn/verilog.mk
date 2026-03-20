CNN_RELEASE_RTL := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/cnn.v
CNN_RELEASE_FAKE_RTL = $(sort $(wildcard $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/fakeram_*.v))

# Allow clean_design to prune dev-generated artifacts when desired.

export VERILOG_FILES = $(CNN_RELEASE_RTL) $(CNN_RELEASE_FAKE_RTL)

