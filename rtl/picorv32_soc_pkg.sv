package picorv32_soc_pkg;
  import axi_pkg::*;

  // AXI constants
  localparam logic [1:0] RESP_OKAY   = 2'b00;
  localparam logic [1:0] RESP_EXOKAY = 2'b01;
  localparam logic [1:0] RESP_SLVERR = 2'b10;
  localparam logic [1:0] RESP_DECERR = 2'b11;

  // SRAM size 16k
  parameter int unsigned SRAM_WIDTH = 32;
  parameter int unsigned SRAM_DEPTH = 4096;

  // Bootloader ROM size 4k
  parameter int unsigned BOOTLOADER_ROM_WIDTH_p = 32;
  parameter int unsigned BOOTLOADER_ROM_DEPTH_p = 1024;

  // Number of masters
  // We have only one master: picorv32
  parameter int unsigned AXI_MASTER_NBR_p = 1;

  // Number of Slaves
  // We have 5 slaves:
  // 1. Scratchpad memory (SRAM)
  // 2. UART
  // 3. LEDs
  // 4. Timer/Counter
  parameter int unsigned AXI_SLAVE_NBR_p = 5;

  // AXI address width
  parameter int unsigned AXI_ADDR_BW_p = 16;

  // AXI data width
  parameter int unsigned AXI_DATA_BW_p = 32;

  // Configuration and typedefs for the AXI
  parameter axi_pkg::xbar_cfg_t AXI_XBAR_CFG_p = '{
    NoSlvPorts:   AXI_MASTER_NBR_p,
    NoMstPorts:   AXI_SLAVE_NBR_p, 
    MaxMstTrans:  8,
    MaxSlvTrans:  2,
    FallThrough:  1'b0,
    LatencyMode:  axi_pkg::CUT_ALL_AX,
    AxiAddrWidth: AXI_ADDR_BW_p,
    AxiDataWidth: AXI_DATA_BW_p,
    NoAddrRules:  AXI_SLAVE_NBR_p,
    default: '0
  };

  typedef axi_pkg::xbar_rule_32_t rule_t; // Has to be the same width as axi addr

  // AXI address map
  parameter rule_t [AXI_XBAR_CFG_p.NoAddrRules-1:0] AXI_ADDR_MAP_p = '{
    '{idx: 32'd4, start_addr: 32'h0000_8000, end_addr: 32'h0000_9000}, // Bootloader (4k)
    '{idx: 32'd3, start_addr: 32'h0000_4000, end_addr: 32'h0000_8000}, // SRAM (16k) 
    '{idx: 32'd2, start_addr: 32'h0000_3000, end_addr: 32'h0000_4000}, // UART (4k)
    '{idx: 32'd1, start_addr: 32'h0000_2000, end_addr: 32'h0000_3000}, // LEDs (4k)
    '{idx: 32'd0, start_addr: 32'h0000_1000, end_addr: 32'h0000_2000}  // Timer/Counter (4k)
  };

  // Parameters used for picorv32_axi instantiation
  // For more details check https://github.com/YosysHQ/picorv32

  // This parameter enables support for the RDCYCLE[H], RDTIME[H], and RDINSTRET[H] instructions.
  // This instructions will cause a hardware trap (like any other unsupported instruction) if 
  // ENABLE_COUNTERS is set to zero.
  parameter bit ENABLE_COUNTERS_p = 1;

  // This parameter enables support for the RDCYCLEH, RDTIMEH, and RDINSTRETH instructions. 
  // If this parameter is set to 0, and ENABLE_COUNTERS is set to 1, then only the RDCYCLE, 
  // RDTIME, and RDINSTRET instructions are available.
  parameter bit ENABLE_COUNTERS64_p = 1;         

  // This parameter enables support for registers the x16..x31. The RV32E ISA excludes this 
  // registers. However, the RV32E ISA spec requires a hardware trap for when code tries to access 
  // this registers. This is not implemented in PicoRV32.
  parameter bit ENABLE_REGS_16_31_p = 1;

  // The register file can be implemented with two or one read ports. A dual ported register file
  // improves performance a bit, but can also increase the size of the core.
  parameter bit ENABLE_REGS_DUALPORT_p = 1;

  // Set this to 1 if the mem_rdata is kept stable by the external circuit after a transaction. In
  // the default configuration the PicoRV32 core only expects the mem_rdata input to be valid in the
  // cycle with mem_valid && mem_ready and latches the value internally.
  parameter bit LATCHED_MEM_RDATA_p = 1;

  // By default shift operations are performed in two stages: first shifts in units of 4 bits and
  // then shifts in units of 1 bit. This speeds up shift operations, but adds additional hardware.
  // Set this parameter to 0 to disable the two-stage shift to further reduce the size of the core.
  parameter bit TWO_STAGE_SHIFT_p = 1;

  // By default shift operations are performed by successively shifting by a small amount
  // (see TWO_STAGE_SHIFT above). With this option set, a barrel shifter is used instead.
  parameter bit BARREL_SHIFTER_p = 1;

  // This relaxes the longest data path a bit by adding an additional FF stage at the cost of 
  // adding an additional clock cycle delay to the conditional branch instructions.
  // Note: Enabling this parameter will be most effective when retiming (aka "register balancing") 
  // is enabled in the synthesis flow.
  parameter bit TWO_CYCLE_COMPARE_p = 0;

  // This adds an additional FF stage in the ALU data path, improving timing at the cost of an
  // additional clock cycle for all instructions that use the ALU.
  // Note: Enabling this parameter will be most effective when retiming (aka "register balancing")
  // is enabled in the synthesis flow.
  parameter bit TWO_CYCLE_ALU_p = 0;

  // This enables support for the RISC-V Compressed Instruction Set.
  parameter bit COMPRESSED_ISA_p = 1;

  // Set this to 0 to disable the circuitry for catching misaligned memory accesses.
  parameter bit CATCH_MISALIGN_p = 1;

  // Set this to 0 to disable the circuitry for catching illegal instructions.
  // The core will still trap on EBREAK instructions with this option set to 0. With IRQs enabled,
  // an EBREAK normally triggers an IRQ 1. With this option set to 0, an EBREAK will trap the
  // processor without triggering an interrupt.
  parameter bit CATCH_ILLINSN_p = 1;

  // Set this to 1 to enable the external Pico Co-Processor Interface (PCPI). The external interface
  // is not required for the internal PCPI cores, such as picorv32_pcpi_mul.
  parameter bit ENABLE_PCPI_p = 0;

  // This parameter internally enables PCPI and instantiates the picorv32_pcpi_mul core that
  // implements the MUL[H[SU|U]] instructions. The external PCPI interface only becomes functional
  // when ENABLE_PCPI is set as well.
  parameter bit ENABLE_MUL_p = 0;
  
  // This parameter internally enables PCPI and instantiates the picorv32_pcpi_fast_mul core that
  // implements the MUL[H[SU|U]] instructions. The external PCPI interface only becomes functional
  // when ENABLE_PCPI is set as well.
  // If both ENABLE_MUL and ENABLE_FAST_MUL are set then the ENABLE_MUL setting will be ignored and
  // the fast multiplier core will be instantiated.
  parameter bit ENABLE_FAST_MUL_p = 1;
  
  // This parameter internally enables PCPI and instantiates the picorv32_pcpi_div core that
  // implements the DIV[U]/REM[U] instructions. The external PCPI interface only becomes functional
  // when ENABLE_PCPI is set as well.
  parameter bit ENABLE_DIV_p = 1;
  
  // Set this to 1 to enable IRQs. (see "Custom Instructions for IRQ Handling" for
  // a discussion of IRQs: 
  // https://github.com/YosysHQ/picorv32?tab=readme-ov-file#custom-instructions-for-irq-handling )
  parameter bit ENABLE_IRQ_p = 1;

  // Set this to 0 to disable support for the getq and setq instructions. Without the q-registers,
  // the irq return address will be stored in x3 (gp) and the IRQ bitmask in x4 (tp), the global
  // pointer and thread pointer registers according to the RISC-V ABI. Code generated from ordinary
  // C code will not interact with those registers.
  // Support for q-registers is always disabled when ENABLE_IRQ is set to 0.
  parameter bit ENABLE_IRQ_QREGS_p = 1;

  // Set this to 0 to disable support for the timer instruction.
  // Support for the timer is always disabled when ENABLE_IRQ is set to 0.
  parameter bit ENABLE_IRQ_TIMER_p = 1;

  // Produce an execution trace using the trace_valid and trace_data output ports.
  parameter bit ENABLE_TRACE_p = 0;

  // Set this to 1 to initialize all registers to zero (using a Verilog initial block). This can be
  // useful for simulation or formal verification.
  parameter bit REGS_INIT_ZERO_p = 0;
  
  // A 1 bit in this bitmask corresponds to a permanently disabled IRQ.
  parameter bit [31:0] MASKED_IRQ_p = 32'h 0000_0000;

  // A 1 bit in this bitmask indicates that the corresponding IRQ is "latched", i.e. when the IRQ
  // line is high for only one cycle, the interrupt will be marked as pending and stay pending until
  // the interrupt handler is called (aka "pulse interrupts" or "edge-triggered interrupts").
  // Set a bit in this bitmask to 0 to convert an interrupt line to operate as "level sensitive"
  // interrupt.
  parameter bit [31:0] LATCHED_IRQ_p = 32'h ffff_ffff;

  // The start address of the program.
  parameter bit [31:0] PROGADDR_RESET_p = 32'h 0000_8000;
  
  // The start address of the interrupt handler.
  parameter bit [31:0] PROGADDR_IRQ_p = 32'h 0000_4010;

  // When this parameter has a value different from 0xffffffff, then register x2 (the stack pointer)
  // is initialized to this value on reset. (All other registers remain uninitialized.) Note that
  // the RISC-V calling convention requires the stack pointer to be aligned on 16 bytes boundaries
  // (4 bytes for the RV32I soft float calling convention).
  parameter bit [31:0] STACKADDR_p = 32'h ffff_ffff;
endpackage : picorv32_soc_pkg
