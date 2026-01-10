module ccr #(
  parameter int BTN_DEBOUNCE_COUNTER_VALUE_p = 100000, // This corresponds to 100ms on 100 MHz clock
  parameter int PLL_LOCK_COUNTER_VALUE_p = 100000 // This corresponds to 100ms on 100 MHz clock
)(
  input logic i_clk,
  input logic i_btn_rst_n,
  output logic o_clk,
  output logic o_rst_n
);

  // Intermediate signals
  logic s_clk;
  logic s_clk_fb;
  logic s_rst_n;
  logic s_locked;

  // Drive outputs
  assign o_clk = s_clk;
  assign o_rst_n = s_rst_n;

  // First we want to sample and debounce the input button
  logic [$clog2(BTN_DEBOUNCE_COUNTER_VALUE_p)-1:0] btn_debounce_counter;
  (* IOB = "TRUE" *) logic btn_rst_n_stage_1;
  (* ASYNC_REG = "TRUE" *) logic btn_rst_n_stage_2;
  logic btn_rst_n_stage_3;
  logic btn_rst_n_stage_4;
  logic btn_debounced;

  `ifndef SIM
  initial begin
    btn_debounce_counter = BTN_DEBOUNCE_COUNTER_VALUE_p;
  end
  `endif

  always_ff @(posedge s_clk) begin
    btn_rst_n_stage_1 <= i_btn_rst_n;
    btn_rst_n_stage_2 <= btn_rst_n_stage_1;
    btn_rst_n_stage_3 <= btn_rst_n_stage_2;
    btn_rst_n_stage_4 <= btn_rst_n_stage_3;
  end

  always_ff @(posedge s_clk) begin
    if (btn_rst_n_stage_4 != btn_rst_n_stage_3) begin
      btn_debounce_counter <= BTN_DEBOUNCE_COUNTER_VALUE_p;
    end else begin
      if (btn_debounce_counter == '0) begin
        btn_debounced <= btn_rst_n_stage_4;
      end else begin
        btn_debounce_counter <= btn_debounce_counter - 1'b1;
      end
    end
  end

  // Resample input flops using the correct clock domain
  // Add counter for reset
  // Output reset depends on system reset and PLL lock
  MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(6.0),     // Multiply value for all CLKOUT (2.000-64.000).
    .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
    .CLKIN1_PERIOD(10.000),    // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT1_DIVIDE(1),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(6.0),    // Divide amount for CLKOUT0 (1.000-128.000).
    // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .CLKOUT6_PHASE(0.0),
    .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
    .DIVCLK_DIVIDE(1),         // Master division value (1-106)
    .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
    .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
 )
 MMCME2_BASE_inst (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0    ( s_clk       ),   // 1-bit output: CLKOUT0
    .CLKOUT0B   ( /* OPEN */  ),   // 1-bit output: Inverted CLKOUT0
    .CLKOUT1    ( /* OPEN */  ),   // 1-bit output: CLKOUT1
    .CLKOUT1B   ( /* OPEN */  ),   // 1-bit output: Inverted CLKOUT1
    .CLKOUT2    ( /* OPEN */  ),   // 1-bit output: CLKOUT2
    .CLKOUT2B   ( /* OPEN */  ),   // 1-bit output: Inverted CLKOUT2
    .CLKOUT3    ( /* OPEN */  ),   // 1-bit output: CLKOUT3
    .CLKOUT3B   ( /* OPEN */  ),   // 1-bit output: Inverted CLKOUT3
    .CLKOUT4    ( /* OPEN */  ),   // 1-bit output: CLKOUT4
    .CLKOUT5    ( /* OPEN */  ),   // 1-bit output: CLKOUT5
    .CLKOUT6    ( /* OPEN */  ),   // 1-bit output: CLKOUT6
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT   ( s_clk_fb    ),   // 1-bit output: Feedback clock
    .CLKFBOUTB  ( /* OPEN */  ),   // 1-bit output: Inverted CLKFBOUT
    // Status Ports: 1-bit (each) output: MMCM status ports
    .LOCKED     ( s_locked    ),   // 1-bit output: LOCK
    // Clock Inputs: 1-bit (each) input: Clock input
    .CLKIN1     ( i_clk       ),   // 1-bit input: Clock
    // Control Ports: 1-bit (each) input: MMCM control ports
    .PWRDWN     ( 1'b0        ),   // 1-bit input: Power-down
    .RST        ( 1'b0        ),   // 1-bit input: Reset
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN    ( s_clk_fb    )    // 1-bit input: Feedback clock
  );

  logic [$clog2(PLL_LOCK_COUNTER_VALUE_p)-1:0] s_rst_cnt;  
  logic s_clear_counter;

  // Now use the synchronized version
  always_ff @(posedge s_clk) begin
    s_clear_counter <= ~(s_locked & btn_debounced);
    s_rst_n <= (s_rst_cnt == PLL_LOCK_COUNTER_VALUE_p);
  
    if (s_clear_counter) begin
      s_rst_cnt <= '0;
    end else if (s_rst_cnt != PLL_LOCK_COUNTER_VALUE_p) begin
      s_rst_cnt <= s_rst_cnt + 1;
    end
  end

endmodule : ccr
