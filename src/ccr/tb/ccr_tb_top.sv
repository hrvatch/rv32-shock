module ccr_tb_top ();

  timeunit 1ns;
  timeprecision 1ps;

  logic tb_clk;
  logic tb_sysrst_n;
  logic dut_clk;
  logic dut_rst_n;

  // Generate clock
  initial begin
    tb_clk <= 1'b0;
    forever #5ns tb_clk <= ~tb_clk;
  end

  // Generate reset
  initial begin
    tb_sysrst_n <= 1'b0;
    repeat (10) @(posedge tb_clk);
    tb_sysrst_n <= 1'b1;

    wait (dut_rst_n == 1'b1);
    repeat (10) @(posedge tb_clk);

    tb_sysrst_n <= 1'b0;
    repeat (50) @(posedge tb_clk);
    tb_sysrst_n <= 1'b1;

    wait (dut_rst_n == 1'b0);
    wait (dut_rst_n == 1'b1);
    repeat (10) @(posedge tb_clk);
    $finish;
  end

  ccr #(
    .SYSRST_DEBOUNCE_COUNTER_VALUE_p(15),
    .PLL_LOCK_COUNTER_VALUE_p(20)
  ) ccr_dut_i (
    .i_clk      ( tb_clk      ),
    .i_sysrst_n ( tb_sysrst_n ),
    .o_clk      ( dut_clk     ),
    .o_rst_n    ( dut_rst_n   )
  );

endmodule : ccr_tb_top
