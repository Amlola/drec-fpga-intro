create_clock -period "50.0 MHz" [get_ports CLK]

derive_clock_uncertainty

# Reset
set_false_path -from RSTN -to [all_clocks]
# UART
set_false_path -from *    -to TXD
set_false_path -from RXD  -to [all_clocks]
# 74HC595
set_false_path -from * -to [get_ports OE]
set_false_path -from * -to [get_ports DS]
set_false_path -from * -to [get_ports STCP]
set_false_path -from * -to [get_ports SHCP]