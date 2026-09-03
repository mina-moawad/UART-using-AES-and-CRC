module SIPO (
	input clk, rst, arst_n,
	input rx, en_shift,
	output [7:0] data);

always@(posedge clk or negedge arst_n) begin
	if(!arst_n)
		data <= 0;
	if (rst)
		data <= 0;
	else begin
		if (en_shift)
			data <= {rx, data[7:1]};
		else 
			data <= 0;
	end
end
endmodule : SIPO