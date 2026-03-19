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
PKG_ROOT ?= $(BENCH_DESIGN_HOME)/src/NVDLA/dev/packages
PERL_PREFIX ?= $(PKG_ROOT)/perl-5.10.1
PY_PREFIX   ?= $(PKG_ROOT)/python-2.7.18
USE_DESIGNWARE  := 0
CPP  := $(shell command -v cpp)
GCC  := $(shell command -v gcc)
CXX  := $(shell command -v g++)
JAVA := $(PKG_ROOT)/openjdk-11/bin/java
SYSTEMC_HOME ?= $(PKG_ROOT)/systemc-2.3.0
PERL    ?= $(PERL_PREFIX)/bin/perl
PYTHON  ?= $(PY_PREFIX)/bin/python
SYSTEMC ?= $(SYSTEMC_HOME)/lib-linux64
VERILATOR := verilator