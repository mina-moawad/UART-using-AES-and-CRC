module TOP_LEVEL #(
	parameter DATA_WIDTH = 128,
    parameter CRC_WIDTH  = 16,
    parameter [CRC_WIDTH:0] POLYNOMIAL = 17'h11021)(
	input clk, rst_n, start,
	input [127:0] plaintext, master_Key,
	output [DATA_WIDTH+CRC_WIDTH-1:0] data_out,
	output done_AES, done_crc, busy_crc);

wire [127:0] ciphertext;

AES_FSM D1 (clk, rst_n, start, plaintext, master_Key, ciphertext, done_AES);
CRC #(DATA_WIDTH, CRC_WIDTH, POLYNOMIAL) D2 (clk, rst_n, done_AES, ciphertext, data_out, done_crc, busy_crc);
endmodule : TOP_LEVEL