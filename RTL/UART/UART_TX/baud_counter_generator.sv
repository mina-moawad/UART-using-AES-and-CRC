module baud_counter_generator (
	input clk, rst, arst_n, 
	output reg tick);

parameter CYCLES = (50_000_000/9600);
parameter SIZE   = $clog2(CYCLES); 

reg [SIZE-1:0] counter; 

always@(posedge clk or negedge arst_n) begin
	if (!arst_n) begin // Asynchoronus reset
		counter<=0;
		tick<=0;
	end
	else if (rst) begin // Synchronous reset
		counter<=0;
		tick<=0;
	end
	else begin
		if (counter == CYCLES-1)begin
			tick<=1;
			counter<=0;
			end
		else  begin
			counter<= counter+1;
			tick<=0;
		end
	end
end
endmodule 