export VERILOG_FILES = $(BENCH_DESIGN_HOME)/src/coralnpu/CoreMiniAxi.v \
                       $(BENCH_DESIGN_HOME)/src/coralnpu/macros.v 

export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/coralnpu/sram/lef/fakeram_512x128_1rw.lef \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/coralnpu/sram/lef/fakeram_2048x128_1rw.lef 

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/coralnpu/sram/lib/fakeram_512x128_1rw.lib \
						 $(BENCH_DESIGN_HOME)/$(PLATFORM)/coralnpu/sram/lib/fakeram_2048x128_1rw.lib 