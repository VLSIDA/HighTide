## ================================================================
## NVDLA Open Source Project
## 
## Copyright(c) 2016 - 2017 NVIDIA Corporation.  Licensed under the
## NVDLA Open Hardware License; Check LICENSE which comes with     
## this distribution for more information. 
## ================================================================


##======================= 										  
## Project Name Setup, multiple projects supported			  	  
##======================= 										  
PROJECTS := nv_small
														  
##======================= 										  
##Linux Environment Setup 										  
##======================= 										  
# Tool paths are overridable (?=) so the Bazel gen_vmod genrule can supply
# modern hermetic tools (rules_python python3, rules_java JDK, system perl with
# the vendored dev/perl_lib modules) via the environment.  The legacy
# perl-5.10 / python-2.7 / JDK11 / SystemC pins are NOT required — the vmod
# build reproduces byte-for-byte with modern versions.
PKG_ROOT ?= $(BENCH_DESIGN_HOME)/src/NVDLA/dev/packages
PERL_PREFIX ?= /usr
PY_PREFIX   ?= /usr
USE_DESIGNWARE  := 0
CPP  := $(if $(NVDLA_CPP),$(NVDLA_CPP),$(shell command -v cpp))
GCC  := $(shell command -v gcc)
CXX  := $(shell command -v g++)
JAVA ?= java
SYSTEMC_HOME ?= $(PKG_ROOT)/systemc-2.3.0
PERL    ?= perl
PYTHON  ?= python3
SYSTEMC ?= $(SYSTEMC_HOME)/lib-linux64
VERILATOR := verilator
