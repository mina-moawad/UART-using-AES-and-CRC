module TOP_rx (
	input clk, rst, arst_n,
	input rx_en, rx,
	output [7:0] data,
	output done, busy, err);

wire falling_edge, en_shift, en_load, en_load_1_5, finish;

Edge_Detection EDGE (clk, rst, arst_n, rx, falling_edge);
SIPO SLL (clk, rst, arst_n, rx, en_shift, data);
rx_baud_counter CNT (clk, rst, arst_n, en_load, en_load_1_5, finish);
rx_fsm CTRL (clk, rst, arst_n, rx_en, falling_edge, finish, rx, en_shift, en_load, en_load_1_5, busy, done, err);
endmodule : TOP_rx