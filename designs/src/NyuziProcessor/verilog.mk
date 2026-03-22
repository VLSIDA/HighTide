export VERILOG_FILES = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/NyuziProcessor.v \
                       $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/macros.v \
                       $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/cache_lru.v

export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_3x64_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_1x256_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_7x256_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_16x52_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_18x256_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_20x64_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_20x64_2r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_32x128_2r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_512x256_1r1w.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lef/fakeram_512x2048_1r1w.lef 

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_3x64_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_1x256_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_7x256_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_16x52_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_20x64_1r1w.lib \
						            $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_18x256_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_20x64_2r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_32x128_2r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_512x256_1r1w.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/sram/lib/fakeram_512x2048_1r1w.lib 
						 
ifneq ($(wildcard $(DEV_FLAG)),)
export DEV_SRC = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/nyuziTop.v \
				 $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/repo
REPO_SRC_DIR    = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/repo/hardware/core
ALL_REPO_FILES  = $(wildcard $(REPO_SRC_DIR)/*.sv) \
				  $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/nyuziTop.sv
REPO_FILES  = $(filter-out \
  $(REPO_SRC_DIR)/sram_1r1w.sv \
  $(REPO_SRC_DIR)/sram_2r1w.sv \
  $(REPO_SRC_DIR)/cache_lru.sv, \
  $(ALL_REPO_FILES))
REPO_INCLUDE_FILES = $(REPO_SRC_DIR)/defines.svh

TARGET_FILE_OVERWRITE = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/NyuziProcessor.v

$(TARGET_FILE_OVERWRITE) : $(REPO_FILES) 
  # Bypass error if patch has already been applied (prone to cause failure if repo code has changed)
	patch -p0 -N --silent --directory=$(REPO_SRC_DIR) < $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/patch-all.patch > /dev/null 2>&1 || [[ $$? == 1 ]]
	$(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/sv2v --top NyuziProcessor -w $@ -I $(REPO_INCLUDE_FILES) $(REPO_FILES)
                       
endif

