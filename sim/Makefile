ifndef PICORV32_SOC_ROOT
$(error PICORV32_SOC_ROOT is not set)
endif

ifndef XIL_XCELIUM_COMP_LIB
$(error XIL_XCELIUM_COMP_LIB is not set)
endif

# Optional: RAM initialization file path
# Usage: make sim_batch RAM_INIT_FILE=/path/to/init.hex BOOTLOADER_INIT_FILE=/path/to/init.hex
RAM_INIT_FILE ?=
BOOTLOADER_INIT_FILE ?=

AXI_FLIST_FILE=$(PICORV32_SOC_ROOT)/src/axi/axi.f

XRUN_ARGS=
XRUN_ARGS+= -access +rwc 
XRUN_ARGS+= -sv
XRUN_ARGS+= -f $(AXI_FLIST_FILE)
XRUN_ARGS+= -f $(PICORV32_SOC_ROOT)/tb/picorv32_soc_tb.f 
XRUN_ARGS+= -top picorv32_soc_tb_top -top glbl -64bit
XRUN_ARGS+= -timescale 1ns/1ps
XRUN_ARGS+= -errormax 10
XRUN_ARGS+= -nowarn CUVWSP
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unisim:unisim
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unisims_ver:unisims_ver
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/secureip:secureip
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unimacro:unimacro
XRUN_ARGS+= -reflib $(XIL_XCELIUM_COMP_LIB)/unimacro_ver:unimacro_ver
XRUN_ARGS+= +define+SIM
XRUN_ARGS+= +define+ASSERTS_OFF
XRUN_ARGS+= +define+BOOTLOADER_INIT_FILE=\\\"$(BOOTLOADER_INIT_FILE)\\\"
XRUN_ARGS+= +define+RAM_INIT_FILE=\\\"$(RAM_INIT_FILE)\\\"

.PHONY: axi_file_list sim_batch sim_gui clean help

axi_file_list:
	@echo "Generating AXI file list from Bender..."
	cd $(PICORV32_SOC_ROOT)/src/axi/ && bender script flist-plus --suppress all > $(AXI_FLIST_FILE)

sim_batch: axi_file_list
	@echo "Running Xcelium..."
	xrun $(XRUN_ARGS)

sim_gui: axi_file_list
	@echo "Running Xcelium in gui mode!"
	xrun $(XRUN_ARGS) -gui -input $(PICORV32_SOC_ROOT)/sim/probe.tcl

clean:
	rm -rf xcelium.d xrun.log waves.shm xrun.history xrun.key .simvision $(AXI_FLIST_FILE)

help:
	@echo "Available targets:"
	@echo "  axi_file_list - Generate AXI IP file list from Bender"
	@echo "  sim_batch     - Run simulation in batch mode"
	@echo "  sim_gui       - Run simulation with GUI"
	@echo "  clean         - Remove simulation artifacts"
	@echo ""
	@echo "Optional variables:"
	@echo "  RAM_INIT_FILE               - Path to RAM initialization file"
	@echo "                                Example: make sim_gui RAM_INIT_FILE=/path/to/init.hex"
	@echo "  BOOTLOADER_INIT_FILE        - Path to bootloader initialization file"
	@echo "                                Example: make sim_gui BOOTLOADER_INIT_FILE=/path/to/init.hex"
