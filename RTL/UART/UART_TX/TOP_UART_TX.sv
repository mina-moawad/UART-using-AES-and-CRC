module TOP_UART_TX(
input clk, rst, arst_n,
input tx_en, 
input [7:0] data, 
output done, busy, tx);

wire tick; 

baud_counter_generator gen (clk, rst, arst_n, tick);
tx_controller CTRL (clk, rst, arst_n, tx_en, tick, data, done, busy, tx);

endmodule : TOP_UART_TX