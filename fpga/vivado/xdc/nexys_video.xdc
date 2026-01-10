## Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports i_clk]
create_clock -period 10.000 -name clk_100_main -waveform {0.000 5.000} -add [get_ports i_clk]

## Buttons
#set_property -dict { PACKAGE_PIN B22 IOSTANDARD LVCMOS12 } [get_ports { btnc }]; #IO_L20N_T3_16 Sch=btnc
#set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS12 } [get_ports { btnd }]; #IO_L22N_T3_16 Sch=btnd
#set_property -dict { PACKAGE_PIN C22 IOSTANDARD LVCMOS12 } [get_ports { btnl }]; #IO_L20P_T3_16 Sch=btnl
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS12 } [get_ports { btnr }]; #IO_L6P_T0_16 Sch=btnr
#set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS12 } [get_ports { btnu }]; #IO_0_16 Sch=btnu
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports i_btn_rst_n]


## LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {o_led[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {o_led[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports {o_led[2]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports {o_led[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS25} [get_ports {o_led[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS25} [get_ports {o_led[5]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS25} [get_ports {o_led[6]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {o_led[7]}]

## UART
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports o_uart_rx]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports i_uart_tx]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# Constrain the MMCM output as a generated clock
#create_generated_clock -name s_clk #    -source [get_pins ccr_inst/MMCME2_BASE_inst/CLKIN1] #    -multiply_by 6 -divide_by 6 #    [get_pins ccr_inst/MMCME2_BASE_inst/CLKOUT0]

# Mark input button as asynchronous (no timing check needed)
set_input_delay -clock clk_100_main 0.000 [get_ports i_btn_rst_n]
set_false_path -from [get_ports i_btn_rst_n]

set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[0]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[1]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[2]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[3]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[4]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[5]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[6]}]
set_output_delay -clock clk_100_main 0.000 [get_ports {o_led[7]}]

set_false_path -to [get_ports {o_led[0]}]
set_false_path -to [get_ports {o_led[1]}]
set_false_path -to [get_ports {o_led[2]}]
set_false_path -to [get_ports {o_led[3]}]
set_false_path -to [get_ports {o_led[4]}]
set_false_path -to [get_ports {o_led[5]}]
set_false_path -to [get_ports {o_led[6]}]
set_false_path -to [get_ports {o_led[7]}]

