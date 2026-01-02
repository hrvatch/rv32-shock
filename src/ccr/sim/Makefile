ifndef CCR_PROJ_ROOT
$(error CCR_PROJ_ROOT is not set)
endif
	
ifndef XIL_XCELIUM_COMP_LIB
$(error XIL_XCELIUM_COMP_LIB is not set)
endif

XRUN_ARGS=  -access +rwc -sv -f $(CCR_PROJ_ROOT)/tb/ccr_tb_top.f -top ccr_tb_top -top glbl -64bit
XRUN_ARGS+= -timescale 1ns/1ps
XRUN_ARGS+= -errormax 10
XRUN_ARGS+= -nowarn CUVWSP # Suppress common Xilinx warnings
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unisim:unisim
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unisims_ver:unisims_ver
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/secureip:secureip
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unimacro:unimacro
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unimacro_ver:unimacro_ver

.PHONY: batch gui clean help

batch:
	xrun $(XRUN_ARGS)

gui:
	xrun $(XRUN_ARGS) -gui -input $(CCR_PROJ_ROOT)/sim/probe.tcl

clean:
	rm -rf xcelium.d xrun.log waves.shm xrun.history xrun.key .simvision

help:
	@echo "Available targets:"
	@echo "  batch - Run simulation in batch mode"
	@echo "  gui   - Run simulation with GUI"
	@echo "  clean - Remove simulation artifacts"
