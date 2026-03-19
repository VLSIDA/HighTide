###            Comprehensive Design List (nangate45, sky130hd, asap7)            ###
#
# DESIGN_CONFIG=./designs/nangate45/minimax/config.mk
# DESIGN_CONFIG=./designs/nangate45/NyuziProcessor/config.mk
# 
# DESIGN_CONFIG=./designs/sky130hd/minimax/config.mk
# 
# DESIGN_CONFIG=./designs/asap7/sha3/config.mk
# DESIGN_CONFIG=./designs/asap7/gemmini/config.mk
# DESIGN_CONFIG=./designs/asap7/NVDLA/NVDLA_partition_a/config.mk
# DESIGN_CONFIG=./designs/asap7/NVDLA/NVDLA_partition_c/config.mk
# DESIGN_CONFIG=./designs/asap7/NVDLA/NVDLA_partition_m/config.mk
# DESIGN_CONFIG=./designs/asap7/NVDLA/NVDLA_partition_o/config.mk
# DESIGN_CONFIG=./designs/asap7/NVDLA/NVDLA_partition_p/config.mk
# DESIGN_CONFIG=./designs/asap7/coralnpu/config.mk
# DESIGN_CONFIG=./designs/asap7/minimax/config.mk
# DESIGN_CONFIG=./designs/asap7/NyuziProcessor/config.mk

DESIGN_CONFIG ?= ./designs/asap7/sha3/config.mk
=======
# DESIGN_CONFIG=./designs/asap7/bp_processor/bp_quad/config.mk

-include OpenROAD-flow-scripts/flow/Makefile
.PHONY: update_rtl
update_rtl:
	@$(MAKE) DO_UPDATE=1 do-update

.PHONY: do-update
do-update:
	git submodule init $(BENCH_DESIGN_HOME)/src/$(DEV_DESIGN_HOME)/repo
	git submodule update $(BENCH_DESIGN_HOME)/src/$(DEV_DESIGN_HOME)/repo
	@if [ -f "$(BENCH_DESIGN_HOME)/src/$(DEV_DESIGN_HOME)/setup.sh" ]; then \
		bash $(BENCH_DESIGN_HOME)/src/$(DEV_DESIGN_HOME)/setup.sh; \
	fi
	@echo "Successfully updated Verilog RTL!"
