export VERILOG_FILES = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/$(DESIGN_NAME).v
ifneq ($(wildcard $(DEV_FLAG)),)
REPO_FILES = $(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/repo/rtl/$(DESIGN_NAME).v

$(VERILOG_FILES): $(REPO_FILES)
	@echo "Translating $(REPO_FILES)  ->  $@"
	$(BENCH_DESIGN_HOME)/src/$(DESIGN_NAME)/dev/sv2v -w $@ $(REPO_FILES)
	@echo "Done."

endif