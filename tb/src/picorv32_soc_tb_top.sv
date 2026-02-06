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


  `ifdef BOOTLOADER_INIT_FILE
  initial begin
    static int fd = $fopen(`BOOTLOADER_INIT_FILE, "r");
    if (!fd) begin
      $display("Memory file %0s not found!", `BOOTLOADER_INIT_FILE);
      $fatal;
    end
    $fclose(fd);
    $readmemh(`BOOTLOADER_INIT_FILE, picorv32_soc_dut.axi_lite_bootloader_inst.ram_block);
  end
  `endif

  `ifdef RAM_INIT_FILE
  initial begin
    static int fd;
    fd = $fopen(`RAM_INIT_FILE, "r");
    if (!fd) begin
      $display("Memory file %0s not found!", `RAM_INIT_FILE);
      $fatal;
    end
    $fclose(fd);
    $readmemh(`RAM_INIT_FILE, picorv32_soc_dut.axi_lite_scratchpad_inst.ram_block);
  end
  `endif // RAM_INIT_FILE

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

  always @(tb_led) begin
    $display("LED status: %8b", tb_led);
  end

  task automatic uart_receive();
    logic [7:0] data;
    int bit_period_ns;

    bit_period_ns = 1000000000 / 921600;  // ~1085 ns

    forever begin
      // Wait for start bit (falling edge)
      @(negedge tb_uart_rx);

      // Wait to middle of start bit
      #(bit_period_ns / 2);

      if (tb_uart_rx !== 1'b0) begin
        $display("ERROR @ %t: Invalid start bit", $time);
        continue;
      end

      // Sample 8 data bits (LSB first)
      for (int i = 0; i < 8; i++) begin
        #bit_period_ns;
        data[i] = tb_uart_rx;
      end

      // Check stop bit
      #bit_period_ns;
      if (tb_uart_rx !== 1'b1) begin
        $display("ERROR @ %t: Invalid stop bit (received: %b)", $time, tb_uart_rx);
      end

      // Display received byte
      $display("@ %t: RX = 0x%02h ('%c')", $time, data, 
        (data >= 32 && data < 127) ? data : ".");
    end
  endtask

  // In your testbench initial block:
  initial begin
    fork
      uart_receive(); 
    join_none
  end

  picorv32_soc_top picorv32_soc_dut (
    .i_clk         ( tb_clk     ),
    .i_btn_rst_n   ( tb_rst_n   ),
    .o_led         ( tb_led     ),
    .o_uart_rx     ( tb_uart_rx ),
    .i_uart_tx     ( tb_uart_tx )
  );

endmodule : picorv32_soc_tb_top
