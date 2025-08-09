export DESIGN_NAME = liteeth_mac_wb_mii
export DESIGN_NICKNAME = liteeth
export PLATFORM    = sky130hd

PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)
REPO_SRC_DIR = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)

TARGET_FILE = $(REPO_SRC_DIR)/$(DESIGN_NAME).v

# Target yml file to be generated
export YML_FILE=$(REPO_SRC_DIR)/repo/examples/wishbone_mii.yml

USED_REPO_FILES=$(YML_FILE)
$(TARGET_FILE) : $(USED_REPO_FILES) 
	bash $(REPO_SRC_DIR)/gen.sh && echo "Starting Generation..."
	patch --silent -N -l $(TARGET_FILE) < $(REPO_SRC_DIR)/patch/mac_wb_mii.patch && echo "Converting to ASIC..."

export VERILOG_FILES = $(TARGET_FILE) \
                       $(PLATFORM_DESIGN_DIR)/xilinx2asic/FDPE.v \
                       $(PLATFORM_DESIGN_DIR)/sram/verilog/fakeram_1rw1r_32w384d_sram.v \
                       $(PLATFORM_DESIGN_DIR)/sram/verilog/fakeram_1rw1r_32w384d_8wm_sram.v

export SDC_FILE            = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_32w384d_sram.lef \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_32w384d_8wm_sram.lef

export ADDITIONAL_LIBS = \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_32w384d_sram.lib \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_32w384d_8wm_sram.lib

export GDS_ALLOW_EMPTY=fakeram*
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.15
export MACRO_PLACE_HALO = 20 20
export ROUTING_LAYER_ADJUSTMENT = 0.2