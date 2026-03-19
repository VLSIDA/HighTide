# Add a design to the suite (using the `update_rtl` environment)

Adding a design to HighTide requires the usage of the `update_rtl` environment. The suite has required formatting to track design sources for maintaining upstream changes. Files for setting up the design reside in the `src/<design-name>/` and `src/<design-name>/dev/` dirs.  The required files for design setup within HighTide are:

- `dev/setup.sh`
- `verilog.mk`
- `<design-name>.v`

GitHub submodule tracking is also required, `.gitmodules` needs to be updated to track a design repo (in the `src/<design-name>/dev/` directory) and relative RTL updates.

## `setup.sh` - Design setup file

`setup.sh` is a per-design setup script that is to be created by a developer adding a design to HighTide. It consists of pre-requisite installation for generating the necessary verilog RTL from the project source. Our [minimax design](../designs/src/minimax/dev/setup.sh) offers a good example as to how the `setup.sh` script should be used. In the case of minimax, it's used to setup [sv2v](https://github.com/zachjs/sv2v) to translate SystemVerilog to Verilog.

## `verilog.mk` - Technology independent Verilog setup

`verilog.mk` should call the necessary commands for generating the verilog RTL from source files, assuming `make update_rtl` is called. The two commands, `make` and `make update_rtl` differ in behavior:

- `make update_rtl` - Attempts to generate Verilog RTL from an up-to-date source repo
- `make` - Expects pre-existing Verilog RTL for immediately running the RTL-to-GDS flow on a design

These two behaviors are separated with a conditional `ifeq (DO_UPDATE,1)`, inside of a design's `verilog.mk`. The expected behaviors are:


- `make` command was called and pre-generated Verilog files are used by default 
    - This assumes that pre-generated Verilog RTL already exists in the `src/<design-name>/` directory, added by the developer working on the design.
- Otherwise, `DO_UPDATE` is 1 and Verilog RTL is re-generated from an up-to-date source (e.g. `make update_rtl` was called)
    - This Verilog RTL will replace the existing RTL in the `src/<design-name>/` directory
See the [minimax verilog.mk](../designs/src/minimax/verilog.mk) for a simple example demonstrating the above behavior.

## Per-Technology Instructions

Per-Technology instructions require, at bare minimum, a `config.mk` and a `constraint.sdc` file. Following the [ORFS documentation for adding a new design](https://openroad-flow-scripts.readthedocs.io/en/latest/user/AddingNewDesign.html)  should acquaint the user with both `config.mk` and `constraint.sdc` files. The only notable difference is that `VERILOG_FILES` logic resides under `verilog.mk` in HighTide, for Verilog RTL generation (which is often independent of technology, and minimizes clutter for per-technology `config.mk` files).
