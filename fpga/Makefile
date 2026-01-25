# Makefile for PicoRV32 SoC Vivado build

# Paths
TCL_DIR := vivado/tcl
PROJECT_NAME := Picorv32_SoC

# Optional: RAM initialization file path
# Usage: make vivado_batch_gen_bitstream RAM_INIT_FILE=/path/to/init.hex
RAM_INIT_FILE ?=
BOOTLOADER_INIT_FILE ?=

# Vivado commands
VIVADO := vivado
VIVADO_FLAGS := -mode batch -notrace

# Bitstream location
BITSTREAM := $(PROJECT_NAME).runs/impl_1/picorv32_soc_top.bit

# Targets
.PHONY: all vivado_gui vivado_batch_syn vivado_batch_pnr vivado_batch_gen_bitstream program program_custom generate_mcs program_flash clean help

# Default target
all: vivado_batch_gen_bitstream

# Help target
help:
	@echo "Available targets:"
	@echo ""
	@echo "Build targets:"
	@echo "  vivado_gui                  - Open Vivado GUI with project"
	@echo "  vivado_batch_syn            - Run synthesis in batch mode"
	@echo "  vivado_batch_pnr            - Run synthesis + place & route in batch mode"
	@echo "  vivado_batch_gen_bitstream  - Run full flow + bitstream generation"
	@echo ""
	@echo "Programming targets:"
	@echo "  program                     - Program FPGA with bitstream (volatile, lost on power cycle)"
	@echo "  program_custom              - Program FPGA with custom bitstream (specify BIT=<path>)"
	@echo ""
	@echo "Maintenance targets:"
	@echo "  clean                       - Clean generated files and project"
	@echo "  help                        - Show this help message"
	@echo ""
	@echo "Optional variables:"
	@echo "  RAM_INIT_FILE               - Path to RAM initialization file"
	@echo "                                Example: make vivado_batch_gen_bitstream RAM_INIT_FILE=/path/to/init.hex"
	@echo "  BOOTLOADER_INIT_FILE        - Path to bootloader initialization file"
	@echo "                                Example: make vivado_batch_gen_bitstream BOOTLOADER_INIT_FILE=/path/to/init.hex"
	@echo "  BIT                         - Custom bitstream path for program_custom"
	@echo "                                Example: make program_custom BIT=my_design.bit"
	@echo ""
	@echo "Common workflows:"
	@echo "  Development (fast, volatile):"
	@echo "    make vivado_batch_gen_bitstream && make program"
	@echo ""
	@echo "  Deployment (permanent, flash):"
	@echo "    make vivado_batch_gen_bitstream && make program_flash"

# Open Vivado GUI
vivado_gui:
	@echo "Opening Vivado GUI..."
	$(VIVADO) -mode gui -source $(TCL_DIR)/vivado.tcl

# Batch synthesis
vivado_batch_syn:
	@echo "Running synthesis in batch mode..."
	@export RAM_INIT_FILE="$(RAM_INIT_FILE)"; \
	export BOOTLOADER_INIT_FILE="$(BOOTLOADER_INIT_FILE)"; \
	$(VIVADO) $(VIVADO_FLAGS) -source $(TCL_DIR)/vivado_batch.tcl -tclargs synth

# Batch place and route (implementation)
vivado_batch_pnr:
	@echo "Running synthesis + implementation in batch mode..."
	@export RAM_INIT_FILE="$(RAM_INIT_FILE)"; \
	export BOOTLOADER_INIT_FILE="$(BOOTLOADER_INIT_FILE)"; \
	$(VIVADO) $(VIVADO_FLAGS) -source $(TCL_DIR)/vivado_batch.tcl -tclargs impl

# Batch bitstream generation
vivado_batch_gen_bitstream:
	@echo "Running full flow + bitstream generation in batch mode..."
	@export RAM_INIT_FILE="$(RAM_INIT_FILE)"; \
	export BOOTLOADER_INIT_FILE="$(BOOTLOADER_INIT_FILE)"; \
	$(VIVADO) $(VIVADO_FLAGS) -source $(TCL_DIR)/vivado_batch.tcl -tclargs bitstream

# Program FPGA (volatile - lost on power cycle)
program:
	@echo "Programming FPGA with bitstream..."
	@if [ ! -f "$(BITSTREAM)" ]; then \
		echo "ERROR: Bitstream not found at $(BITSTREAM)"; \
		echo "Run 'make vivado_batch_gen_bitstream' first"; \
		exit 1; \
	fi
	$(VIVADO) -mode batch -source $(TCL_DIR)/program_fpga.tcl -tclargs $(BITSTREAM) -notrace -quiet -nojournal

# Program FPGA with custom bitstream
program_custom:
	@if [ -z "$(BIT)" ]; then \
		echo "ERROR: Please specify bitstream file with BIT=<path>"; \
		echo "Example: make program_custom BIT=my_design.bit"; \
		exit 1; \
	fi
	@if [ ! -f "$(BIT)" ]; then \
		echo "ERROR: Bitstream not found at $(BIT)"; \
		exit 1; \
	fi
	$(VIVADO) -mode batch -source $(TCL_DIR)/program_fpga.tcl -tclargs $(BIT)

# Clean project
clean:
	@echo "Cleaning project..."
	@rm -rf $(PROJECT_NAME).xpr
	@rm -rf $(PROJECT_NAME).cache
	@rm -rf $(PROJECT_NAME).hw
	@rm -rf $(PROJECT_NAME).ip_user_files
	@rm -rf $(PROJECT_NAME).runs
	@rm -rf $(PROJECT_NAME).sim
	@rm -rf $(PROJECT_NAME).gen
	@rm -rf .Xil
	@rm -rf *.jou
	@rm -rf *.log
	@rm -rf *.rpt
	@echo "Clean complete."
