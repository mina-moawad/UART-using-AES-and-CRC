module rx_baud_counter(
	input clk, rst, arst_n,
	input en_laod, en_load_1_5, 
	output finish);

parameter CYCLES = 50000000/9600;
parameter CYCLES_1_5 = CYCLES * 1.5;
parameter SIZE = $clog2(CYCLES_1_5);

reg [SIZE-1:0] counter; 

always@(posedge clk or negedge arst_n) begin
	if (!arst_n) begin
		counter<=0;
	end
	else if (rst)
		counter<=0;
	else if (en_laod) begin
		if (en_load_1_5)
			counter<= CYCLES_1_5-1;
		else 
			counter<=CYCLES-1;
	end
	else if (counter>0)
		counter<=counter-1;
end

assign finish = (counter == 0);
endmodule : rx_baud_counter