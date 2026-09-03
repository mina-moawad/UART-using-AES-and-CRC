module Edge_Detection (
	input clk, rst, arst_n,
	input rx,
	output falling_edge);

reg rx_ff;

always@(posedge clk or negedge arst_n)begin
	if (!arst_n)
		rx_ff<=1; // value is high in idle state
	else if (rst)
		rx_ff<=1;
	else begin
		rx_ff<=rx; // next clock cycle value of rx will be asserted in rx_ff
	end
end

assign falling_edge = (rx_ff && !rx); // if current rx_ff is 1 and rx is 0 ==> falling edge

endmodule : Edge_Detection