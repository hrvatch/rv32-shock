module picorv32_soc_top 
  import picorv32_soc_pkg::*;
(
  // Nexys Video clock (fclk = 100 MHz)
  input logic i_clk,

  // Nexys Video CPU reset
  input logic i_btn_rst_n,

  // Nexys Video LEDs
  output logic [7:0] o_led,

  // Nexys Video UART
  output logic o_uart_rx,
  input logic i_uart_tx
);

  `ifndef BOOTLOADER_INIT_FILE
    `define BOOTLOADER_INIT_FILE ""
  `endif

  `ifndef RAM_INIT_FILE
    `define RAM_INIT_FILE ""
  `endif

  // Clock and reset
  logic s_rst_n;
  logic s_clk;
  
  // CPU trap
  logic s_trap;

  // CPU IRQ
  logic [31:0] s_irq;
  logic [31:0] s_eoi;

  assign s_irq[2:0]  = '0;
  assign s_irq[31:6] = '0;

  AXI_LITE #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_BW_p ),
    .AXI_DATA_WIDTH ( AXI_DATA_BW_p )
  ) axi_master_intf[AXI_MASTER_NBR_p-1:0] ();

  AXI_LITE #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_BW_p ),
    .AXI_DATA_WIDTH ( AXI_DATA_BW_p )
  ) axi_slave_intf[AXI_SLAVE_NBR_p-1:0] ();

  AXI_LITE #(
    .AXI_ADDR_WIDTH ( AXI_ADDR_BW_p ),
    .AXI_DATA_WIDTH ( AXI_DATA_BW_p )
  ) cut_to_xbar[AXI_MASTER_NBR_p-1:0]();

  // Insert cut (slice register) between PicoRV32 and crossbar, this improves timing by 
  // roughly 10%
  axi_lite_cut_intf #(
    .ADDR_WIDTH ( AXI_ADDR_BW_p ),
    .DATA_WIDTH ( AXI_DATA_BW_p )
  ) i_response_cut (
    .clk_i  ( s_clk               ),
    .rst_ni ( s_rst_n             ),
    .in     ( axi_master_intf[0]  ),  // From your PicoRV32 bridge
    .out    ( cut_to_xbar[0]      )   // To crossbar
  ); 

  // Common clock and reset (CCR) instance
  ccr #(
`ifdef SIM
    .BTN_DEBOUNCE_COUNTER_VALUE_p ( 10 ),
    .PLL_LOCK_COUNTER_VALUE_p     ( 15 )
`else
    .BTN_DEBOUNCE_COUNTER_VALUE_p ( 100000 ),
    .PLL_LOCK_COUNTER_VALUE_p     ( 100000 )
`endif // SIM
  ) ccr_inst (
    .i_clk       ( i_clk        ),
    .i_btn_rst_n ( i_btn_rst_n  ),
    .o_clk       ( s_clk        ),
    .o_rst_n     ( s_rst_n      )
  );

  // AXI crossbar
  axi_lite_xbar_intf #(
    .Cfg    ( AXI_XBAR_CFG_p ),
    .rule_t ( rule_t         )
  ) axi_lite_xbar_intf_inst (
    .clk_i                  ( s_clk           ),
    .rst_ni                 ( s_rst_n         ),
    .test_i                 ( 1'b0            ),
    .slv_ports              ( cut_to_xbar     ),
    .mst_ports              ( axi_slave_intf  ),
    .addr_map_i             ( AXI_ADDR_MAP_p  ),
    .en_default_mst_port_i  ( '0              ),
    .default_mst_port_i     ( '0              )
  );
  
  // Bootloader memory
  axi_lite_scratchpad #(
    .MEMORY_BW_p    ( BOOTLOADER_ROM_WIDTH_p     ),
    .MEMORY_DEPTH_p ( BOOTLOADER_ROM_DEPTH_p     ),
    .MEM_FILE_p     ( `BOOTLOADER_INIT_FILE      )
  ) axi_lite_bootloader_inst (
    .clk            ( s_clk                            ),
    .rst_n          ( s_rst_n                          ),
    .i_axi_awaddr   ( '0                               ),
    .i_axi_awvalid  ( 1'b0                             ),
    .i_axi_wdata    ( '0                               ),
    .i_axi_wvalid   ( 1'b0                             ),
    .i_axi_wstrb    ( '0                               ),
    .i_axi_bready   ( 1'b0                             ),
    .i_axi_araddr   ( axi_slave_intf[4].ar_addr[11:0]  ),
    .i_axi_arvalid  ( axi_slave_intf[4].ar_valid       ),
    .i_axi_rready   ( axi_slave_intf[4].r_ready        ),
    .o_axi_awready  (          /* OPEN */              ),
    .o_axi_wready   (          /* OPEN */              ),
    .o_axi_bresp    (          /* OPEN */              ),
    .o_axi_bvalid   (          /* OPEN */              ),
    .o_axi_arready  ( axi_slave_intf[4].ar_ready       ),
    .o_axi_rdata    ( axi_slave_intf[4].r_data         ),
    .o_axi_rresp    ( axi_slave_intf[4].r_resp         ),
    .o_axi_rvalid   ( axi_slave_intf[4].r_valid        )
  ); 
    
  assign axi_slave_intf[4].aw_ready = 1'b1; 
  assign axi_slave_intf[4].w_ready  = 1'b1; 
  assign axi_slave_intf[4].b_resp   = picorv32_soc_pkg::RESP_SLVERR;
  assign axi_slave_intf[4].b_valid  = 1'b1; 
  
  // Scratchpad memory
  axi_lite_scratchpad #(
    .MEMORY_BW_p    ( SRAM_WIDTH                 ),
    .MEMORY_DEPTH_p ( SRAM_DEPTH                 ),
    .MEM_FILE_p     ( `RAM_INIT_FILE             )
  ) axi_lite_scratchpad_inst (
    .clk            ( s_clk                            ),
    .rst_n          ( s_rst_n                          ),
    .i_axi_awaddr   ( axi_slave_intf[3].aw_addr[13:0]  ),
    .i_axi_awvalid  ( axi_slave_intf[3].aw_valid       ),
    .i_axi_wdata    ( axi_slave_intf[3].w_data         ),
    .i_axi_wvalid   ( axi_slave_intf[3].w_valid        ),
    .i_axi_wstrb    ( axi_slave_intf[3].w_strb         ),
    .i_axi_bready   ( axi_slave_intf[3].b_ready        ),
    .i_axi_araddr   ( axi_slave_intf[3].ar_addr[13:0]  ),
    .i_axi_arvalid  ( axi_slave_intf[3].ar_valid       ),
    .i_axi_rready   ( axi_slave_intf[3].r_ready        ),
    .o_axi_awready  ( axi_slave_intf[3].aw_ready       ),
    .o_axi_wready   ( axi_slave_intf[3].w_ready        ),
    .o_axi_bresp    ( axi_slave_intf[3].b_resp         ),
    .o_axi_bvalid   ( axi_slave_intf[3].b_valid        ),
    .o_axi_arready  ( axi_slave_intf[3].ar_ready       ),
    .o_axi_rdata    ( axi_slave_intf[3].r_data         ),
    .o_axi_rresp    ( axi_slave_intf[3].r_resp         ),
    .o_axi_rvalid   ( axi_slave_intf[3].r_valid        )
  ); 
  
  // AXI UART
  uart_top #(
    .CLK_FREQ_p         ( 100_000_000         ),
    .UART_FIFO_DEPTH_p  ( 16                  ),
    .AXI_ADDR_BW_p      ( 12                  )
  ) uart_inst (
    .clk            ( s_clk                           ),
    .rst_n          ( s_rst_n                         ),
    .i_axi_awaddr   ( axi_slave_intf[2].aw_addr[11:0] ),
    .i_axi_awvalid  ( axi_slave_intf[2].aw_valid      ),
    .i_axi_wdata    ( axi_slave_intf[2].w_data        ),
    .i_axi_wvalid   ( axi_slave_intf[2].w_valid       ),
    .i_axi_bready   ( axi_slave_intf[2].b_ready       ),
    .i_axi_araddr   ( axi_slave_intf[2].ar_addr[11:0] ),
    .i_axi_arvalid  ( axi_slave_intf[2].ar_valid      ),
    .i_axi_rready   ( axi_slave_intf[2].r_ready       ),
    .o_axi_awready  ( axi_slave_intf[2].aw_ready      ),
    .o_axi_wready   ( axi_slave_intf[2].w_ready       ),
    .o_axi_bresp    ( axi_slave_intf[2].b_resp        ),
    .o_axi_bvalid   ( axi_slave_intf[2].b_valid       ),
    .o_axi_arready  ( axi_slave_intf[2].ar_ready      ),
    .o_axi_rdata    ( axi_slave_intf[2].r_data        ),
    .o_axi_rresp    ( axi_slave_intf[2].r_resp        ),
    .o_axi_rvalid   ( axi_slave_intf[2].r_valid       ),
    .i_uart_rx      ( i_uart_tx                       ),
    .o_uart_tx      ( o_uart_rx                       ),
    .o_irq          ( s_irq[5]                        )
  );

  // AXI LED module
  axi_led #(
    .AXI_ADDR_BW_p ( 12  ),
    .LED_NBR_p     ( 8  )
  ) axi_led_inst (
    .clk            ( s_clk                            ),
    .rst_n          ( s_rst_n                          ),
    .i_axi_awaddr   ( axi_slave_intf[1].aw_addr[11:0]  ),
    .i_axi_awvalid  ( axi_slave_intf[1].aw_valid       ),
    .i_axi_wdata    ( axi_slave_intf[1].w_data         ),
    .i_axi_wvalid   ( axi_slave_intf[1].w_valid        ),
    .i_axi_bready   ( axi_slave_intf[1].b_ready        ),
    .i_axi_araddr   ( axi_slave_intf[1].ar_addr[11:0]  ),
    .i_axi_arvalid  ( axi_slave_intf[1].ar_valid       ),
    .i_axi_rready   ( axi_slave_intf[1].r_ready        ),
    .o_axi_awready  ( axi_slave_intf[1].aw_ready       ),
    .o_axi_wready   ( axi_slave_intf[1].w_ready        ),
    .o_axi_bresp    ( axi_slave_intf[1].b_resp         ),
    .o_axi_bvalid   ( axi_slave_intf[1].b_valid        ),
    .o_axi_arready  ( axi_slave_intf[1].ar_ready       ),
    .o_axi_rdata    ( axi_slave_intf[1].r_data         ),
    .o_axi_rresp    ( axi_slave_intf[1].r_resp         ),
    .o_axi_rvalid   ( axi_slave_intf[1].r_valid        ),
    .o_led          ( o_led                            )
  );
  
  // AXI Timer/Compare
  axi_timer_counter_top #(
    .AXI_ADDR_BW_p ( 12 )
  ) axi_timer_counter_inst (
    .clk            ( s_clk                            ),
    .rst_n          ( s_rst_n                          ),
    .i_axi_awaddr   ( axi_slave_intf[0].aw_addr[11:0]  ),
    .i_axi_awvalid  ( axi_slave_intf[0].aw_valid       ),
    .i_axi_wdata    ( axi_slave_intf[0].w_data         ),
    .i_axi_wvalid   ( axi_slave_intf[0].w_valid        ),
    .i_axi_bready   ( axi_slave_intf[0].b_ready        ),
    .i_axi_araddr   ( axi_slave_intf[0].ar_addr[11:0]  ),
    .i_axi_arvalid  ( axi_slave_intf[0].ar_valid       ),
    .i_axi_rready   ( axi_slave_intf[0].r_ready        ),
    .o_axi_awready  ( axi_slave_intf[0].aw_ready       ),
    .o_axi_wready   ( axi_slave_intf[0].w_ready        ),
    .o_axi_bresp    ( axi_slave_intf[0].b_resp         ),
    .o_axi_bvalid   ( axi_slave_intf[0].b_valid        ),
    .o_axi_arready  ( axi_slave_intf[0].ar_ready       ),
    .o_axi_rdata    ( axi_slave_intf[0].r_data         ),
    .o_axi_rresp    ( axi_slave_intf[0].r_resp         ),
    .o_axi_rvalid   ( axi_slave_intf[0].r_valid        ),
    .o_cnt0_done    ( s_irq[3]                         ),
    .o_cnt1_done    ( s_irq[4]                         )
  );

  // PicoRV32 instance
  picorv32_axi #(
    .ENABLE_COUNTERS      ( ENABLE_COUNTERS_p       ),
    .ENABLE_COUNTERS64    ( ENABLE_COUNTERS64_p     ),
    .ENABLE_REGS_16_31    ( ENABLE_REGS_16_31_p     ),
    .ENABLE_REGS_DUALPORT ( ENABLE_REGS_DUALPORT_p  ),
    .TWO_STAGE_SHIFT      ( TWO_STAGE_SHIFT_p       ),
    .BARREL_SHIFTER       ( BARREL_SHIFTER_p        ),
    .TWO_CYCLE_COMPARE    ( TWO_CYCLE_COMPARE_p     ),
    .TWO_CYCLE_ALU        ( TWO_CYCLE_ALU_p         ), 
    .COMPRESSED_ISA       ( COMPRESSED_ISA_p        ),
    .CATCH_MISALIGN       ( CATCH_MISALIGN_p        ),
    .CATCH_ILLINSN        ( CATCH_ILLINSN_p         ),
    .ENABLE_PCPI          ( ENABLE_PCPI_p           ),
    .ENABLE_MUL           ( ENABLE_MUL_p            ),
    .ENABLE_FAST_MUL      ( ENABLE_FAST_MUL_p       ),
    .ENABLE_DIV           ( ENABLE_DIV_p            ),
    .ENABLE_IRQ           ( ENABLE_IRQ_p            ),
    .ENABLE_IRQ_QREGS     ( ENABLE_IRQ_QREGS_p      ),
    .ENABLE_IRQ_TIMER     ( ENABLE_IRQ_TIMER_p      ),
    .ENABLE_TRACE         ( ENABLE_TRACE_p          ),
    .REGS_INIT_ZERO       ( REGS_INIT_ZERO_p        ),
    .MASKED_IRQ           ( MASKED_IRQ_p            ),
    .LATCHED_IRQ          ( LATCHED_IRQ_p           ),
    .PROGADDR_RESET       ( PROGADDR_RESET_p        ),
    .PROGADDR_IRQ         ( PROGADDR_IRQ_p          ),
    .STACKADDR            ( STACKADDR_p             )
  ) picorv32_axi_inst (
    .clk    ( s_clk      ), 
    .resetn ( s_rst_n    ),
    .trap   ( s_trap     ), 
    // AXI4-lite master memory interface
    .mem_axi_awvalid    ( axi_master_intf[0].aw_valid   ),
    .mem_axi_awready    ( axi_master_intf[0].aw_ready   ),
    .mem_axi_awaddr     ( axi_master_intf[0].aw_addr    ),
    .mem_axi_awprot     ( axi_master_intf[0].aw_prot    ),
    .mem_axi_wvalid     ( axi_master_intf[0].w_valid    ),
    .mem_axi_wready     ( axi_master_intf[0].w_ready    ),
    .mem_axi_wdata      ( axi_master_intf[0].w_data     ),
    .mem_axi_wstrb      ( axi_master_intf[0].w_strb     ),
    .mem_axi_bvalid     ( axi_master_intf[0].b_valid    ),
    .mem_axi_bready     ( axi_master_intf[0].b_ready    ),
    .mem_axi_arvalid    ( axi_master_intf[0].ar_valid   ),
    .mem_axi_arready    ( axi_master_intf[0].ar_ready   ),
    .mem_axi_araddr     ( axi_master_intf[0].ar_addr    ),
    .mem_axi_arprot     ( axi_master_intf[0].ar_prot    ),
    .mem_axi_rvalid     ( axi_master_intf[0].r_valid    ),
    .mem_axi_rready     ( axi_master_intf[0].r_ready    ),
    .mem_axi_rdata      ( axi_master_intf[0].r_data     ),

    // Pico Co-Processor Interface (PCPI)
    .pcpi_valid   ( /* OPEN */    ),
    .pcpi_insn    ( /* OPEN */    ),
    .pcpi_rs1     ( /* OPEN */    ),
    .pcpi_rs2     ( /* OPEN */    ),
    .pcpi_wr      ( 1'b0          ),
    .pcpi_rd      ( '0            ),
    .pcpi_wait    ( 1'b0          ),
    .pcpi_ready   ( 1'b0          ),

    // IRQ interface
    .irq          ( s_irq         ),
    .eoi          ( s_eoi         ),
  
    // Trace Interface
    .trace_valid  ( /* OPEN */    ),
    .trace_data   ( /* OPEN */    )
  );


endmodule : picorv32_soc_top
