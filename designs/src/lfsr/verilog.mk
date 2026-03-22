ifneq ($(wildcard $(DEV_FLAG)),)
export VERILOG_FILES = \
  $(wildcard $(BENCH_DESIGN_HOME)/src/lfsr/dev/repo/rtl/*.v)
else
export VERILOG_FILES = $(wildcard $(BENCH_DESIGN_HOME)/src/lfsr/*.v)
endif