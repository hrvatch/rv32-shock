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

  // Generate reset
  initial begin
    tb_rst_n <= 1'b0;
    repeat (10) @(posedge tb_clk);
    tb_rst_n <= 1'b1;
    wait(picorv32_soc_dut.s_rst_n === 1'b1);
    repeat (10) @(posedge tb_clk);

    $finish;
  end

  picorv32_soc_top picorv32_soc_dut (
    .i_clk     ( tb_clk     ),
    .i_rst_n   ( tb_rst_n   ),
    .o_led     ( tb_led     ),
    .o_uart_rx ( tb_uart_rx ),
    .i_uart_tx ( tb_uart_tx )
  );

endmodule : picorv32_soc_tb_top
