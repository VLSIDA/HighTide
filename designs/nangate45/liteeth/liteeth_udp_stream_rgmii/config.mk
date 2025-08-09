export DESIGN_NAME = liteeth_udp_stream_rgmii
export DESIGN_NICKNAME = liteeth
export PLATFORM    = nangate45

PLATFORM_DESIGN_DIR=$(BENCH_DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)
REPO_SRC_DIR = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NICKNAME)

TARGET_FILE = $(REPO_SRC_DIR)/$(DESIGN_NAME).v

# Target yml file to be generated
export YML_FILE=$(REPO_SRC_DIR)/repo/examples/udp_s7phyrgmii.yml

USED_REPO_FILES=$(YML_FILE)
$(TARGET_FILE) : $(USED_REPO_FILES) 
	bash $(REPO_SRC_DIR)/gen.sh && echo "Starting Generation..."
	patch --silent -N -l $(TARGET_FILE) < $(REPO_SRC_DIR)/patch/udp_stream_rgmii.patch && echo "Converting to ASIC..."

export SYNTH_HIERARCHICAL = 1

export VERILOG_FILES = $(TARGET_FILE) \
                       $(PLATFORM_DESIGN_DIR)/sram/verilog/fakeram_1rw1r_12w128d_sram.v \
                       $(PLATFORM_DESIGN_DIR)/sram/verilog/fakeram_1rw1r_64w64d_sram.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/PLLE2_DUMMY.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/IDELAYE2.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/IBUF.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/OBUF.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/BUFG.v \
                       $(PLATFORM_DESIGN_DIR)/xilinx2asic/FDPE.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/FDCE.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/ODDR.v \
					   $(PLATFORM_DESIGN_DIR)/xilinx2asic/IDDR.v \

export SDC_FILE      = $(PLATFORM_DESIGN_DIR)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_12w128d_sram.lef \
  $(PLATFORM_DESIGN_DIR)/sram/lef/fakeram_1rw1r_64w64d_sram.lef

export ADDITIONAL_LIBS = \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_12w128d_sram.lib \
  $(PLATFORM_DESIGN_DIR)/sram/lib/fakeram_1rw1r_64w64d_sram.lib

export GDS_ALLOW_EMPTY=fakeram*
export CORE_UTILIZATION = 45
export PLACE_DENSITY = 0.7
export CELL_PAD_IN_SITES_DETAIL_PLACEMENT=3
export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT=3
export CAP_MARGIN = 0