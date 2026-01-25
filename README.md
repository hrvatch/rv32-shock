# Shock - Simple PicoRV32-based SoC

## Overview

Shock is a simple PicoRV32-based System-on-Chip (SoC) designed for FPGA implementation. The SoC contains basic peripherals essential for embedded systems development:

- **Timer/Counter** - Programmable timer with interrupt support
- **GPIO** - Simple GPIO for controlling LEDs
- **UART** - Serial communication peripheral with configurable baud rate
- **SRAM** - 16KB scratchpad memory for program execution
- **Bootloader ROM** - 4KB ROM containing UART-based bootloader

This project targets the **Digilent Nexys Video** platform but is designed for portability. Only the PLL (wrapped in the Common Clock and Reset block) uses vendor-specific primitives, making it straightforward to retarget to other FPGA families.

### Key Features

- **RISC-V ISA**: RV32IMC instruction set
- **AXI4-Lite Interconnect**: Industry-standard on-chip bus
- **Formal Verification**: Critical peripherals are formally verified
- **Hardware Validation**: Tested on Nexys Video FPGA board
- **Maximum Frequency**: ~110 MHz on Xilinx XC7A200T-1 (Speed Grade -1)
- **UART Bootloader**: Upload programs to SRAM without reprogramming FPGA

## Shock Block Diagram

![PicoRV32 block diagram](../img/shock_soc.drawio.svg)

### Memory Map

| Address Range        | Size | Peripheral          | Description                    |
|---------------------|------|---------------------|--------------------------------|
| `0x1000 - 0x1FFF`   | 4KB  | Timer/Counter       | Programmable timer with IRQ    |
| `0x2000 - 0x2FFF`   | 4KB  | GPIO (LEDs)         | LED control interface          |
| `0x3000 - 0x3FFF`   | 4KB  | UART                | Serial communication           |
| `0x4000 - 0x7FFF`   | 16KB | SRAM                | Main program memory            |
| `0x8000 - 0x8FFF`   | 4KB  | Bootloader ROM      | UART bootloader                |

**Boot Sequence**: CPU starts execution at `0x8000` (Bootloader ROM). The bootloader waits for UART 
trigger ('R' character) to receive a new program.

## Component Reuse

Shock leverages high-quality, proven IP cores:

### PicoRV32 CPU Core

**PicoRV32** is a size-optimized RISC-V CPU core supporting the RV32IMC instruction set. It's an excellent choice for embedded SoCs due to its small footprint and proven reliability.

- **Repository**: https://github.com/YosysHQ/picorv32
- **License**: ISC License (permissive)
- **Features**: Formally verified, highly configurable
- **Configuration**: 
  - RV32IMC ISA (Integer, Multiply, Compressed)
  - Fast multiplier enabled
  - Division enabled
  - IRQ support enabled
  - Compressed instruction support enabled

### AXI4-Lite Crossbar

**AXI Crossbar** from ETH Zurich's PULP Platform provides a flexible, parameterizable interconnect.

- **Repository**: https://github.com/pulp-platform/axi
- **License**: Apache License 2.0
- **Features**: Multiple master/slave support, configurable address decoding
- **Note**: Originally ASIC-optimized with long combinatorial paths. Register slices are inserted to meet FPGA timing requirements.

### Custom Peripherals

The following peripherals were developed specifically for this project and are included as git submodules:

| Peripheral | Repository | Description |
|-----------|------------|-------------|
| **AXI4-Lite Timer** | [hrvatch/axi4_lite_timer](https://github.com/hrvatch/axi4_lite_timer) | Programmable timer/counter with interrupt generation |
| **AXI4-Lite UART** | [hrvatch/axi4_lite_uart](https://github.com/hrvatch/axi4_lite_uart) | Universal asynchronous receiver-transmitter |
| **AXI4-Lite Scratchpad** | [hrvatch/axi4_lite_scratchpad](https://github.com/hrvatch/axi4_lite_scratchpad) | SRAM memory controller |
| **AXI LED** | [hrvatch/axi_led](https://github.com/hrvatch/axi_led) | Simple GPIO for LED control |

All custom peripherals include:
- Formal verification testbenches
- Simulation testbenches
- Complete RTL documentation

## Repository Structure

```
shock/
├── fpga/                     # FPGA build files
│   ├── Makefile              # Build and programming automation
│   ├── sim/                  # FPGA simulation files
│   └── vivado/               # Vivado project scripts
│       ├── tcl/              # Vivado TCL scripts
│       └── xdc/              # Constraint files
├── rtl/                      # Top-level RTL
│   ├── picorv32_soc_pkg.sv   # Package with configuration
│   ├── picorv32_soc_top.sv   # Top-level module
│   └── picorv32_soc.f        # File list
├── sim/                      # Simulation environment
│   ├── Makefile              # Xcelium simulation
│   └── probe.tcl             # Waveform configuration
├── src/                      # IP components (submodules)
│   ├── axi/                  # PULP AXI crossbar
│   ├── picorv32/             # PicoRV32 CPU
│   ├── axi4_lite_timer/      # Timer peripheral
│   ├── axi4_lite_uart/       # UART peripheral
│   ├── axi4_lite_scratchpad/ # SRAM controller
│   ├── axi_led/              # LED GPIO
│   └── ccr/                  # Clock & Reset (vendor-specific)
├── sw/                       # Software
│   ├── bootloader/           # UART bootloader
│   ├── hello_world/          # Example application
│   └── tools/                # Upload scripts and binary to hex program conversion for simulation
└── tb/                       # Testbenches
    └── src/                  # Testbench sources
```

## Prerequisites

### Hardware Requirements

- **Digilent Nexys Video** FPGA board (XC7A200T) - Optionally any other board can be used, but
  design must be resynthesized for the target board, and CCR needs to be updated for the target
  vendor.
- USB cable for FPGA programming
- USB-UART cable or on-board UART interface

### Software Requirements

1. **Vivado Design Suite** (tested with 2025.2)
   - Free WebPACK edition is sufficient

2. **Cadence Xcelium** (for simulation, optional)
   - Required only for RTL simulation
   - Alternatives: ModelSim, Verilator (requires adaptation)

3. **RISC-V GNU Toolchain**
   - Target: `riscv32-unknown-elf`
   - Installation instructions in the [RISC-V GNU Toolchain Github repo](https://github.com/riscv-collab/riscv-gnu-toolchain)

4. **Python 3** (for upload script)
   - Required packages: `pyserial`
   ```bash
   pip3 install pyserial
   ```

5. **Bender** (for AXI dependency management)
   ```bash
   cargo install bender
   # Or download from https://github.com/pulp-platform/bender/releases
   ```

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/hrvatch/shock.git
cd shock
```

### 2. Initialize Submodules

```bash
git submodule update --init --recursive
```

This downloads all IP components:
- PicoRV32 CPU
- PULP AXI crossbar
- Custom peripherals (UART, Timer, SRAM, LEDs)

### 3. Set Environment Variables

Create a script to set up your environment (e.g., `setup_env.sh`):

```bash
#!/bin/bash

# Set Shock repository root
export PICORV32_SOC_ROOT=$(pwd)

# Xilinx Vivado (adjust path to your installation)
export XILINX_VIVADO=/tools/Xilinx/2025.2/Vivado
source $XILINX_VIVADO/settings64.sh

# Xcelium compiled libraries (for simulation)
export XIL_XCELIUM_COMP_LIB=/path/to/xcelium/compiled/xilinx/libs

# RISC-V toolchain (if not in system PATH)
export PATH=/opt/riscv/bin:$PATH

echo "Shock environment configured"
echo "PICORV32_SOC_ROOT: $PICORV32_SOC_ROOT"
```

Load the environment:
```bash
source setup_env.sh
```

### 4. Pull the PULP platform sources

The PULP patform AXI4-Lite Xbar has numerous dependencies. Luckily, PULP platform
uses Bender tool for dependency management (see Prerequisites) which clones correct repos
and pulls all the files we need:

```bash
cd src/axi
bender update
cd ../..
```

### 5. Build the Bootloader

The bootloader must be built first and embedded into the FPGA bitstream:

```bash
cd sw/bootloader
make clean
make
```

This generates `bootloader.hex` which will be synthesized into block RAM.

## Running Simulation

### Prerequisites

- Cadence Xcelium installed and in PATH
- Xilinx libraries compiled for Xcelium (for PLL simulation)
- Environment variables set (see Initial Setup)

### Running Xcelium Simulation

```bash
cd sim
make sim_batch      # Run in batch mode
# or
make sim_gui        # Run with GUI for waveform viewing
```

The simulation:
1. Generates AXI file list using Bender
2. Compiles all RTL sources
3. Runs the testbench (`picorv32_soc_tb_top`)
4. Displays waveforms (GUI mode) or generates log (batch mode)

### Makefile Targets

```bash
make axi_file_list  # Generate AXI IP file list only
make sim_batch      # Run simulation in batch mode
make sim_gui        # Run simulation with GUI
make clean          # Remove simulation artifacts
make help           # Show available targets
```

### Troubleshooting Simulation

**Error: `XIL_XCELIUM_COMP_LIB` not set**
- Solution: Set environment variable to Xcelium-compiled Xilinx libraries

**Error: Bender not found**
- Solution: Install Bender or add to PATH

**Waveform not appearing in GUI**
- The `probe.tcl` script configures waveform signals
- Edit `sim/probe.tcl` to add/remove signals

## Bitstream Generation

### Build the Software First

Before generating the bitstream, build the bootloader (mandatory) and optionally the hello_world application:

```bash
# Build bootloader (required)
cd sw/bootloader
make

# Optionally build and embed hello_world
cd ../hello_world
make
```

### Generate Bitstream

```bash
cd fpga
make vivado_batch_gen_bitstream BOOTLOADER_INIT_FILE=/path/to/bootloader.hex
```

This command:
1. Creates Vivado project
2. Adds all RTL sources
3. Runs synthesis
4. Performs place and route
5. Generates bitstream at `Picorv32_SoC.runs/impl_1/picorv32_soc_top.bit`

### Build Stages

You can run individual stages:

```bash
make vivado_batch_syn    # Synthesis only
make vivado_batch_pnr    # Synthesis + Place & Route
make vivado_gui          # Open Vivado GUI
```

### Embedding Software in Bitstream

To embed a program directly in SRAM (useful for standalone operation):

```bash
# Embed hello_world in SRAM
make vivado_batch_gen_bitstream RAM_INIT_FILE=/path/to/firmware.hex

# Embed custom bootloader
make vivado_batch_gen_bitstream BOOTLOADER_INIT_FILE=/path/to/bootloader.hex
```

NOTE: Use absolute paths.

### Timing Analysis

After bitstream generation, check timing:

```bash
cat Picorv32_SoC.runs/impl_1/*_timing_summary_routed.rpt
```

Look for:
- **WNS (Worst Negative Slack)**: Should be positive
- **WHS (Worst Hold Slack)**: Should be positive
- **WPWS (Worst Pulse Width Slack)**: Should be positive

### Clean Build Artifacts

```bash
make clean
```

## Programming FPGA

### Volatile Programming (Recommended for Development)

Program the FPGA directly (configuration lost on power cycle):

```bash
cd fpga
make program
```

This is the fastest method for development iterations.

### Programming with Custom Bitstream

```bash
make program_custom BIT=/path/to/custom.bit
```

### Verification

After programming, the bootloader will:
1. Initialize UART (115200 baud, 8N1)
2. Turn on LED0 signaling UART has been initialized and it's waiting for a program
3. Wait for 'R' character on UART to receive new program
4. After receiving 'R' character, bootloader expect 16k-bytes of data. If your program is less
   than 16k, it should be padded with zeros. The included `uploader.py` script does exactly that.
5. After receiving 16k of data, bootloader will jump to 0x4000 (SRAM start address, where startup code begins).

## Software Development and Upload

### Development Workflow

1. **Write your application** in C or assembly
2. **Build** using the provided Makefile
3. **Upload** to FPGA via UART bootloader
4. **Debug** using UART printf statements

### Hello World Example

The `hello_world` example demonstrates basic functionality:

```bash
cd sw/hello_world
make clean
make
```

This produces:
- `firmware.elf` - Executable with debug symbols
- `firmware.bin` - Raw binary
- `firmware.hex` - Hex format for embedding in bitstream or using in simulation
- `firmware.lst` - Disassembly listing

### Program Structure

Every program must include:

1. **Startup code** (`start.S`): Initializes stack, clears BSS, calls main
2. **Linker script** (`picorv32.ld`): Defines memory layout
3. **Application code** (`main.c`): Your application logic
4. **Peripheral drivers** (optional): UART, timer, etc.

Example `main.c`:

```c
#include "uart.h"

int main() {
    uart_init();
    uart_puts("Hello from Shock SoC!\n");
    
    while (1) {
        // Your code here
    }
    
    return 0;
}
```

### Memory Layout

The linker script defines:
```
MEMORY {
    SRAM (rwx) : ORIGIN = 0x00004000, LENGTH = 16K
}
```

**Memory Organization:**
- SRAM range: `0x4000 - 0x7FFF` (16KB total)
- Program entry point: `0x4000` (startup code in `start.S`)
- IRQ handler: `0x4010` (also in `start.S`, at +16 byte offset)
- Application code: Follows startup code
- Maximum program size: 16KB
- Stack: Grows downward from `0x8000` (top of SRAM)

**Note:** The startup code (`start.S`) is placed at 0x4000 with the IRQ handler at 0x4010, matching PicoRV32's `PROGADDR_IRQ` configuration.

### Peripheral Access

Peripherals are memory-mapped and accessed via pointers:

```c
// UART registers
#define UART_BASE    0x3000
#define UART_TX_DATA (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))

// Timer registers
#define TIMER_BASE   0x1000
#define TIMER_VALUE  (*(volatile uint32_t *)(TIMER_BASE + 0x00))
#define TIMER_CTRL   (*(volatile uint32_t *)(TIMER_BASE + 0x04))

// LED registers
#define LED_BASE     0x2000
#define LED_CONTROL  (*(volatile uint32_t *)(LED_BASE + 0x00))
```

### Uploading Programs via UART

The bootloader allows uploading new programs without reprogramming the FPGA.

#### 1. Connect UART

Connect USB-UART adapter to the FPGA board:
- **TX** → FPGA RX
- **RX** → FPGA TX
- **GND** → GND

Find the serial device:
```bash
# Linux
ls /dev/ttyUSB*

# macOS
ls /dev/tty.usbserial*
```

#### 2. Upload the Program

```bash
cd sw/hello_world
python3 ../tools/upload.py -f firmware.bin -d /dev/ttyUSB0 -b 115200
```

The upload process:
1. Sends 'R' trigger character
2. Uploads 16KB (program + padding) in 1KB chunks
3. Bootloader writes data to SRAM
4. Bootloader jumps to SRAM and executes program

#### 3. Monitor Output

Use a serial terminal to see program output:

```bash
# Using screen
screen /dev/ttyUSB0 115200

# Using minicom
minicom -D /dev/ttyUSB0 -b 115200

# Using Python
python3 -m serial.tools.miniterm /dev/ttyUSB0 115200
```

### Upload Script Options

```bash
python3 upload.py [options]

Required:
  -f, --file FILE       Binary file to upload
  -d, --device DEVICE   Serial device (e.g., /dev/ttyUSB0)

Optional:
  -b, --baud RATE       Baud rate (default: 115200)
```

### Creating Your Own Application

1. Copy the hello_world template:
   ```bash
   cp -r sw/hello_world sw/my_app
   cd sw/my_app
   ```

2. Modify `main.c` with your application logic

3. Update Makefile if adding source files:
   ```makefile
   firmware.elf: start.o main.o my_driver.o uart.o picorv32.ld
       $(CC) $(LDFLAGS) -o $@ start.o main.o my_driver.o uart.o
   ```

4. Build and upload:
   ```bash
   make
   python3 ../tools/upload.py -f firmware.bin -d /dev/ttyUSB0
   ```

### Debugging Tips

1. **Use UART for printf debugging**:
   ```c
   uart_printf("Variable x = %d\n", x);
   ```

2. **Check return address on exceptions**:
   The bootloader preserves crash information in registers

3. **Analyze disassembly**:
   ```bash
   riscv32-unknown-elf-objdump -d firmware.elf > firmware.lst
   ```

4. **Monitor program size**:
   ```bash
   riscv32-unknown-elf-size firmware.elf
   ```
   Ensure it fits in 16KB SRAM

5. **Use LEDs for status indication**:
   ```c
   LED_CONTROL = 0x55;  // Light up pattern
   ```

## Customization

### Changing Target FPGA Board

To port to a different FPGA board:

1. **Update CCR (Clock & Reset) block**:
   - Modify `src/ccr/` to use target FPGA's PLL/MMCM
   - Adjust clock frequencies as needed

2. **Update constraint file**:
   - Copy `fpga/vivado/xdc/nexys_video.xdc`
   - Modify pin assignments for target board

3. **Update Vivado TCL scripts**:
   - Modify `fpga/vivado/tcl/vivado.tcl`
   - Change FPGA part number

### Adding Custom Peripherals

1. Create peripheral as AXI4-Lite slave
2. Add peripheral repository as submodule
3. Update `picorv32_soc_pkg.sv`:
   - Increment `AXI_SLAVE_NBR_p`
   - Add address range to `AXI_ADDR_MAP_p`
4. Instantiate in `picorv32_soc_top.sv`
5. Connect to AXI crossbar

### Modifying CPU Configuration

Edit `rtl/picorv32_soc_pkg.sv` to change PicoRV32 parameters:

- `ENABLE_MUL_p`: Enable/disable multiply instructions
- `ENABLE_DIV_p`: Enable/disable divide instructions
- `COMPRESSED_ISA_p`: Enable/disable RV32C (compressed instructions)
- `BARREL_SHIFTER_p`: Use barrel shifter vs sequential shift

Consult [PicoRV32 documentation](https://github.com/YosysHQ/picorv32) for all options.

### Increasing SRAM Size

1. Modify `SRAM_DEPTH` in `picorv32_soc_pkg.sv`
2. Update address range in `AXI_ADDR_MAP_p`
3. Update linker script `sw/*/picorv32.ld`
4. Rebuild bootloader and bitstream

## Performance Characteristics

### Resource Utilization (Nexys Video, XC7A200T)

Based on post-implementation reports from Vivado 2025.2:

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 3,261 | 134,600 | 2.42% |
| Slice Registers (FFs) | 2,260 | 269,200 | 0.84% |
| Block RAM (36Kb) | 5 | 365 | 1.37% |
| DSP48E1 | 4 | 740 | 0.54% |

**LUT Breakdown:**
- LUT as Logic: 3,117 (2.32%)
- LUT as Distributed RAM: 144 (0.31%)

**BRAM Usage:**
- Bootloader ROM: ~1 BRAM (4KB)
- SRAM: ~4 BRAM (16KB)

**DSP Usage:**
- Fast Multiplier (PicoRV32): 4 DSP48E1 blocks

### Timing Performance

Based on post-route timing analysis (Vivado 2025.2, Speed Grade -1):

| Parameter | Value | Status |
|-----------|-------|--------|
| **Target Clock Period** | 10.000 ns (100 MHz) | - |
| **Worst Negative Slack (WNS)** | +0.814 ns | ✅ MET |
| **Worst Hold Slack (WHS)** | +0.890 ns | ✅ MET |
| **Maximum Achievable Frequency** | ~109 MHz | - |

**Timing Analysis:**
- All timing constraints met with adequate margins
- WNS of +0.814 ns indicates critical path of 9.186 ns
- Maximum frequency: 1 / 9.186 ns = 108.86 MHz ~ 109 MHz
- Design validated at 100 MHz with roughly 8% timing margin

**Critical Path:**
- **Source**: AXI crossbar register slice (B channel spill register)
- **Destination**: CPU memory read data register (mem_rdata_q[26] clock enable)
- **Path Type**: AXI response → CPU register
- **Logic Levels**: 7 (5× LUT5, 2× LUT6)
- **Delay Breakdown**:
  - Logic: 1.984 ns (22.3%)
  - Routing: 6.925 ns (77.7%)
  - Total: 8.909 ns

The critical path shows the AXI register slicing is working as intended to break up combinatorial 
paths, with the bottleneck now in the control logic generating the CPU's memory read data register 
clock enable.

### Bootloader Performance

- **Upload Speed**: ~11KB/s at 115200 baud
- **16KB Upload Time**: ~1.5 seconds
- **Overhead**: 1KB chunks with acknowledgment

## Known Issues and Limitations

1. **UART Upload Limitations**:
   - Maximum program size: 16KB (SRAM size)
   - Must use 115200 baud (bootloader hardcoded)
   - No error correction (use reliable USB-UART adapter)

2. **Bootloader Behavior**:
   - Waits indefinitely for 'R' trigger
   - No timeout to auto-boot from SRAM
   - Can't re-upload after first upload without reset

3. **Memory Map Constraints**:
   - 16-bit address space (64KB maximum)
   - No instruction cache (all code from SRAM)
   - No data cache

4. **Simulation**:
   - Requires Xcelium (or modification for other simulators)
   - Xilinx PLL simulation requires compiled libraries

## Contributing

Contributions are welcome! Areas for improvement:

- Port to other FPGA boards (Arty, ULX3S, etc.)
- Add more peripherals (SPI, I2C, GPIO expansion)
- Improve bootloader (timeout, error checking)
- Create more example applications
- Add formal verification for top-level SoC

## License

This project consists of multiple components with different licenses:

- **PicoRV32**: ISC License
- **PULP AXI**: Apache License 2.0
- **Custom peripherals**: MIT License
- **Shock integration code**: MIT License

See individual component repositories for detailed license information.

## References

- [PicoRV32 GitHub](https://github.com/YosysHQ/picorv32)
- [PULP Platform AXI](https://github.com/pulp-platform/axi)
- [RISC-V ISA Specification](https://riscv.org/specifications/)
- [Digilent Nexys Video](https://digilent.com/reference/programmable-logic/nexys-video/start)

## Contact

For questions, issues, or contributions:
- Open an issue on GitHub
- Visit the project page: https://github.com/hrvatch/shock

