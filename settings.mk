export BENCH_DESIGN_HOME    = $(abspath $(dir $(firstword $(MAKEFILE_LIST)))/designs)
export DESIGN_RESULTS_NAME ?= $(DESIGN_NICKNAME)
export DEV_FLAG             = $(abspath $(dir $(firstword $(MAKEFILE_LIST)))/.dev-run-$(DESIGN_NAME)-$(DEV_RUN_TAG))
export DEV_DESIGN_HOME     := $(DESIGN_RESULTS_NAME)/dev


# Override log, object, reports, and results subdir names (since OpenROAD bases it off of DESIGN_NICKNAME alone)
override LOG_DIR     = $(WORK_HOME)/logs/$(PLATFORM)/$(DESIGN_RESULTS_NAME)/$(FLOW_VARIANT)
override OBJECTS_DIR = $(WORK_HOME)/objects/$(PLATFORM)/$(DESIGN_RESULTS_NAME)/$(FLOW_VARIANT)
override REPORTS_DIR = $(WORK_HOME)/reports/$(PLATFORM)/$(DESIGN_RESULTS_NAME)/$(FLOW_VARIANT)
override RESULTS_DIR = $(WORK_HOME)/results/$(PLATFORM)/$(DESIGN_RESULTS_NAME)/$(FLOW_VARIANT)

export GDS_ALLOW_EMPTY := fakeram.*