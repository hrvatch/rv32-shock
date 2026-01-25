start_gui
create_project Picorv32_SoC . -part xc7a200tsbg484-1
set_property board_part digilentinc.com:nexys_video:part0:1.2 [current_project]

# Set PATHs
set ROOT $env(PICORV32_SOC_ROOT)
set PICORV32_SOC_PATH $ROOT
set PICORV32_CORE_PATH $ROOT/src/picorv32
set AXI_XBAR_PATH $ROOT/src/axi
set CCR_PATH $ROOT/src/ccr
set AXI_SRAM_PATH $ROOT/src/axi4_lite_scratchpad
set AXI_LED_PATH $ROOT/src/axi_led
set AXI_UART_PATH $ROOT/src/axi4_lite_uart
set AXI_TIMER_PATH $ROOT/src/axi4_lite_timer

# ============================================
# CCR
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $CCR_PATH/rtl/ccr.sv \
]

# ============================================
# AXI-Lite SRAM (Scratchpad)
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $AXI_SRAM_PATH/rtl/axi_lite_scratchpad.sv \
]

# ============================================
# AXI-Lite LEDs
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $AXI_LED_PATH/rtl/axi_led.sv \
]

# ============================================
# AXI-Lite UART
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $AXI_UART_PATH/submodules/common_blocks/sync_fifo/rtl/sync_fifo_with_clear.sv \
  $AXI_UART_PATH/submodules/common_blocks/sync_fifo/rtl/sync_fifo_fwft_with_clear.sv \
  $AXI_UART_PATH/rtl/uart_axi_lite.sv \
  $AXI_UART_PATH/rtl/uart_baudgen.sv \
  $AXI_UART_PATH/rtl/uart_rx.sv \
  $AXI_UART_PATH/rtl/uart_tx.sv \
  $AXI_UART_PATH/rtl/uart_top.sv \
]

# ============================================
# AXI-Lite TIMER
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $AXI_TIMER_PATH/rtl/axi_timer.sv \
  $AXI_TIMER_PATH/rtl/timer_counter.sv \
  $AXI_TIMER_PATH/rtl/axi_timer_counter_top.sv \
]

# ============================================
# PULP AXI-Lite Xbar
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/fpga/pad_functional_xilinx.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/fpga/tc_clk_xilinx.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/fpga/tc_sram_xilinx.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/rtl/tc_sram_impl.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/deprecated/pulp_clock_gating_async.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/deprecated/cluster_clk_cells.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/tech_cells_generic-6e6736c6cf5dbb6b/src/deprecated/pulp_clk_cells.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/binary_to_gray.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cb_filter_pkg.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cc_onehot.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_reset_ctrlr_pkg.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cf_math_pkg.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/clk_int_div.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/credit_counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/delta_counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/ecc_pkg.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_propagator_tx.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/exp_backoff.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/fifo_v3.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/gray_to_binary.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/heaviside.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/isochronous_4phase_handshake.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/isochronous_spill_register.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr_16bit.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr_8bit.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lossy_valid_to_stream.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/mv_filter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/onehot_to_bin.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/plru_tree.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/passthrough_stream_fifo.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/popcount.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/ring_buffer.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/rr_arb_tree.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/rstgen_bypass.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/serial_deglitch.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/shift_reg.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/shift_reg_gated.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/spill_register_flushable.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_demux.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_filter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_fork.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_intf.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_join_dynamic.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_mux.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_throttle.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sub_per_hash.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sync.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sync_wedge.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/unread.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/read.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode_dync.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/boxcar.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_2phase.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_4phase.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/clk_int_div_static.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/trip_counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode_napot.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/multiaddr_decode.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cb_filter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_fifo_2phase.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/clk_mux_glitch_free.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/ecc_decode.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/ecc_encode.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_detect.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lzc.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/max_counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/rstgen.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/spill_register.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_delay.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_fifo.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_fork_dynamic.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_join.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_reset_ctrlr.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_fifo_gray.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/fall_through_register.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/id_queue.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_to_mem.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_arbiter_flushable.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_fifo_optimal_wrap.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_register.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_xbar.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_fifo_gray_clearable.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_2phase_clearable.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/mem_to_banks_detailed.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_arbiter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_omega_net.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/mem_to_banks.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/clock_divider_counter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/clk_div.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/find_first_one.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/generic_LFSR_8bit.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/generic_fifo.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/prioarbiter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/pulp_sync.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/pulp_sync_wedge.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/rrarbiter.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/clock_divider.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/fifo_v2.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/deprecated/fifo_v1.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_propagator_ack.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_propagator.sv \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_propagator_rx.sv \
]
add_files -norecurse -fileset [current_fileset] [list \
    $AXI_XBAR_PATH/src/axi_pkg.sv \
    $AXI_XBAR_PATH/src/axi_intf.sv \
    $AXI_XBAR_PATH/src/axi_atop_filter.sv \
    $AXI_XBAR_PATH/src/axi_burst_splitter_gran.sv \
    $AXI_XBAR_PATH/src/axi_burst_unwrap.sv \
    $AXI_XBAR_PATH/src/axi_bus_compare.sv \
    $AXI_XBAR_PATH/src/axi_cdc_dst.sv \
    $AXI_XBAR_PATH/src/axi_cdc_src.sv \
    $AXI_XBAR_PATH/src/axi_cut.sv \
    $AXI_XBAR_PATH/src/axi_delayer.sv \
    $AXI_XBAR_PATH/src/axi_demux_simple.sv \
    $AXI_XBAR_PATH/src/axi_dw_downsizer.sv \
    $AXI_XBAR_PATH/src/axi_dw_upsizer.sv \
    $AXI_XBAR_PATH/src/axi_fifo.sv \
    $AXI_XBAR_PATH/src/axi_fifo_delay_dyn.sv \
    $AXI_XBAR_PATH/src/axi_id_remap.sv \
    $AXI_XBAR_PATH/src/axi_id_prepend.sv \
    $AXI_XBAR_PATH/src/axi_inval_filter.sv \
    $AXI_XBAR_PATH/src/axi_isolate.sv \
    $AXI_XBAR_PATH/src/axi_join.sv \
    $AXI_XBAR_PATH/src/axi_lite_demux.sv \
    $AXI_XBAR_PATH/src/axi_lite_dw_converter.sv \
    $AXI_XBAR_PATH/src/axi_lite_from_mem.sv \
    $AXI_XBAR_PATH/src/axi_lite_join.sv \
    $AXI_XBAR_PATH/src/axi_lite_lfsr.sv \
    $AXI_XBAR_PATH/src/axi_lite_mailbox.sv \
    $AXI_XBAR_PATH/src/axi_lite_mux.sv \
    $AXI_XBAR_PATH/src/axi_lite_regs.sv \
    $AXI_XBAR_PATH/src/axi_lite_to_apb.sv \
    $AXI_XBAR_PATH/src/axi_lite_to_axi.sv \
    $AXI_XBAR_PATH/src/axi_modify_address.sv \
    $AXI_XBAR_PATH/src/axi_mux.sv \
    $AXI_XBAR_PATH/src/axi_rw_join.sv \
    $AXI_XBAR_PATH/src/axi_rw_split.sv \
    $AXI_XBAR_PATH/src/axi_serializer.sv \
    $AXI_XBAR_PATH/src/axi_slave_compare.sv \
    $AXI_XBAR_PATH/src/axi_throttle.sv \
    $AXI_XBAR_PATH/src/axi_to_detailed_mem.sv \
    $AXI_XBAR_PATH/src/axi_burst_splitter.sv \
    $AXI_XBAR_PATH/src/axi_cdc.sv \
    $AXI_XBAR_PATH/src/axi_demux.sv \
    $AXI_XBAR_PATH/src/axi_err_slv.sv \
    $AXI_XBAR_PATH/src/axi_dw_converter.sv \
    $AXI_XBAR_PATH/src/axi_from_mem.sv \
    $AXI_XBAR_PATH/src/axi_id_serialize.sv \
    $AXI_XBAR_PATH/src/axi_lfsr.sv \
    $AXI_XBAR_PATH/src/axi_multicut.sv \
    $AXI_XBAR_PATH/src/axi_to_axi_lite.sv \
    $AXI_XBAR_PATH/src/axi_to_mem.sv \
    $AXI_XBAR_PATH/src/axi_zero_mem.sv \
    $AXI_XBAR_PATH/src/axi_interleaved_xbar.sv \
    $AXI_XBAR_PATH/src/axi_iw_converter.sv \
    $AXI_XBAR_PATH/src/axi_lite_xbar.sv \
    $AXI_XBAR_PATH/src/axi_xbar_unmuxed.sv \
    $AXI_XBAR_PATH/src/axi_to_mem_banked.sv \
    $AXI_XBAR_PATH/src/axi_to_mem_interleaved.sv \
    $AXI_XBAR_PATH/src/axi_to_mem_split.sv \
    $AXI_XBAR_PATH/src/axi_xbar.sv \
    $AXI_XBAR_PATH/src/axi_xp.sv \
]

set_property include_dirs [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/include \
    $AXI_XBAR_PATH/include \
] [current_fileset]

set_property include_dirs [list \
    $AXI_XBAR_PATH/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/include \
    $AXI_XBAR_PATH/include \
] [current_fileset -simset]

# Check if RAM_INIT_FILE is provided as environment variable
if { [info exists env(RAM_INIT_FILE)] } {
    set ram_init_file $env(RAM_INIT_FILE)
    puts "Using RAM_INIT_FILE from environment: $ram_init_file"
} else {
    set ram_init_file ""
    puts "RAM_INIT_FILE not set, using default empty string"
}

# Check if BOOTLOADER_INIT_FILE is provided as environment variable
if { [info exists env(BOOTLOADER_INIT_FILE)] } {
    set bootloader_init_file $env(BOOTLOADER_INIT_FILE)
    puts "Using BOOTLOADER_INIT_FILE from environment: $bootloader_init_file"
} else {
    set bootloader_init_file ""
    puts "BOOTLOADER_INIT_FILE not set, using default empty string"
}

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SYNTHESIS \
    TARGET_VIVADO \
    TARGET_XILINX \
    RAM_INIT_FILE=\"$ram_init_file\" \
    BOOTLOADER_INIT_FILE=\"$bootloader_init_file\" \
] [current_fileset]

set_property verilog_define [list \
    TARGET_FPGA \
    TARGET_SYNTHESIS \
    TARGET_VIVADO \
    TARGET_XILINX \
    RAM_INIT_FILE=\"$ram_init_file\" \
    BOOTLOADER_INIT_FILE=\"$bootloader_init_file\" \
] [current_fileset -simset]

# ============================================
# PICORV32 CORE
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $PICORV32_CORE_PATH/picorv32.v \
]

# ============================================
# PICORV32 SOC TOP
# ============================================
add_files -norecurse -fileset [current_fileset] [list \
  $PICORV32_SOC_PATH/rtl/picorv32_soc_pkg.sv \
  $PICORV32_SOC_PATH/rtl/picorv32_soc_top.sv \
]
set_property top picorv32_soc_top [current_fileset]
update_compile_order -fileset [current_fileset]

# ============================================
# Nexys Video design constraints
# ============================================
add_files -norecurse -fileset [current_fileset -constrset] [list \
  $PICORV32_SOC_PATH/fpga/vivado/xdc/nexys_video.xdc \
]
