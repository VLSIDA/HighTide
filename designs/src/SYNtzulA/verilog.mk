export ADDITIONAL_LEFS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x64_1rw.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_48x256_1rw.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x256_1rw.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x512_1rw.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x1024_1rw.lef \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lef/fakeram_64x2048_1rw.lef

export ADDITIONAL_LIBS = $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x64_1rw.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_48x256_1rw.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x256_1rw.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x512_1rw.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x1024_1rw.lib \
                         $(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram/lib/fakeram_64x2048_1rw.lib

SYNSNN_SRC_DIR  := $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)
SYNSNN_TOP_V    := $(SYNSNN_SRC_DIR)/SYNtzulATop.v

ifneq ($(wildcard $(DEV_FLAG)),)

SYNSNN_DEV_DIR := $(SYNSNN_SRC_DIR)/dev

SYNSNN_REPO_RTL_DIR   = $(SYNSNN_DEV_DIR)/repo/rtl

SYNSNN_ALL_REPO_FILES = $(shell find $(SYNSNN_REPO_RTL_DIR) -mindepth 2 -maxdepth 2 -type f \
                            -not -name "*.rej") \
                        $(SYNSNN_REPO_RTL_DIR)/define.v

SYNSNN_REPO_INCLUDE_FILES := $(SYNSNN_REPO_RTL_DIR)/define.v

SYNSNN_REPO_SV_FILES = $(filter-out \
                       $(wildcard $(SYNSNN_REPO_RTL_DIR)/*/*.v) \
                       $(wildcard $(SYNSNN_REPO_RTL_DIR)/*.v) \
                       $(SYNSNN_REPO_INCLUDE_FILES), \
                       $(SYNSNN_ALL_REPO_FILES))

SYNSNN_REPO_V_FILES = $(filter-out \
                      $(wildcard $(SYNSNN_REPO_RTL_DIR)/*/*.sv) \
                      $(wildcard $(SYNSNN_REPO_RTL_DIR)/*.sv) \
                      $(SYNSNN_REPO_INCLUDE_FILES), \
                      $(SYNSNN_ALL_REPO_FILES))

$(SYNSNN_TOP_V): $(SYNSNN_ALL_REPO_FILES)
	@bash $(SYNSNN_DEV_DIR)/setup.sh
	patch -p1 -N --directory=$(SYNSNN_DEV_DIR)/repo \
		< $(SYNSNN_DEV_DIR)/patch-synsnn.patch; \
		RET=$$?; [ $$RET -eq 0 ] || [ $$RET -eq 1 ]
	cat $(SYNSNN_REPO_INCLUDE_FILES) > $(SYNSNN_TOP_V)
	$(SYNSNN_DEV_DIR)/sv2v -w stdout \
		-I $(SYNSNN_REPO_RTL_DIR) \
		$(SYNSNN_REPO_SV_FILES) \
		>> $(SYNSNN_TOP_V)
	cat $(SYNSNN_REPO_V_FILES) >> $(SYNSNN_TOP_V)

export VERILOG_FILES = $(SYNSNN_TOP_V) \
                       $(SYNSNN_SRC_DIR)/macros.v

else
export VERILOG_FILES = $(SYNSNN_TOP_V) \
                       $(SYNSNN_SRC_DIR)/macros.v

endif
