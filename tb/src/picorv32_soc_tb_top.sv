module picorv32_soc_tb_top;

  logic tb_clk;
  logic tb_rst_n;
  logic [7:0] tb_led;
  logic tb_uart_rx;
  logic tb_uart_tx;

  // Generate clock
  initial begin
    tb_clk <= 1'b0;
    forever #5ns tb_clk <= ~tb_clk;
  end


  initial begin
    string file_name = "$PICORV32_SOC_ROOT/tb/src/firmware.hex";
    int fd;
    fd = $fopen(file_name, "r");
    if (!fd) begin
      $display("Memory file %0s not found!", file_name);
      $fatal;
    end
    $fclose(fd);
    $readmemh(file_name, picorv32_soc_dut.axi_lite_scratchpad_inst.ram_block);
  end

  // Generate reset
  initial begin
    tb_rst_n <= 1'b0;
    repeat (10) @(posedge tb_clk);
    tb_rst_n <= 1'b1;
    wait(picorv32_soc_dut.s_trap === 1'b1);
    $display("Trap detected! Ending simulation.");
    repeat(10) @(posedge tb_clk);

    $finish;
  end

  picorv32_soc_top picorv32_soc_dut (
    .i_clk     ( tb_clk     ),
    .i_btn_rst_n   ( tb_rst_n   ),
    .o_led     ( tb_led     ),
    .o_uart_rx ( tb_uart_rx ),
    .i_uart_tx ( tb_uart_tx )
  );

endmodule : picorv32_soc_tb_top
