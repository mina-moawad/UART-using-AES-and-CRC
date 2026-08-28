module AES_Shift_Row #(
	parameter WIDTH = 128)(
	input [WIDTH-1:0] data_in,
	output [WIDTH-1:0] data_out);

	// Bit insertion in each Row(r) and Coloumn (c)

	//Left Coloumn ==> Kept the same (NO SHIFT)
	wire [7:0] s00 = data_in[127:120];
	wire [7:0] s10 = data_in[119:112];
	wire [7:0] s20 = data_in[111:104];
	wire [7:0] s30 = data_in[103:96];

	//Second Coloumn
	wire [7:0] s01 = data_in[95:88];
	wire [7:0] s11 = data_in[87:80];
	wire [7:0] s21 = data_in[79:72];
	wire [7:0] s31 = data_in[71:64];
	
	//Third Coloumn
	wire [7:0] s02 = data_in[63:56];
	wire [7:0] s12 = data_in[55:48];
	wire [7:0] s22 = data_in[47:40];
	wire [7:0] s32 = data_in[39:32];
	
	//Last Coloumn
	wire [7:0] s03 = data_in[31:24];
	wire [7:0] s13 = data_in[23:16];
	wire [7:0] s23 = data_in[15:8];
	wire [7:0] s33 = data_in[7:0];

	//Shifting is done by number of Rows ==> R0 (NO shift), R1 (shift one), R2 (shift two), R3 (Shift three)
	// NO shift in First Row ==> s00, s01, s02, s03
	// Shift in Second Row ==>   s11, s12, s13, s10
	// Shift in Third Row ==>    s22, s23, s20, s21
	//Shift in Fourth Row =====> s33, s30, s31, s32
	assign data_out = {s00, s11, s22, s33, 
					   s01, s12, s23, s30,
					   s02, s13, s20, s31,
					   s03, s10, s21, s32 };

	endmodule : AES_Shift_Row