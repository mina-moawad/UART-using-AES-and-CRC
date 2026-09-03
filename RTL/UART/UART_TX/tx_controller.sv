module tx_controller (
	input clk, rst, arst_n,
	input tx_en, tick,
	input [7:0] data,
	output reg done, busy, tx);

parameter IDLE = 0;
parameter ON  = 1;

reg [9:0] total_frame;
reg [3:0] i = 0; // counter to counter number of frame bits
reg cs, ns; 

always@(posedge clk or negedge arst_n)begin
	if (!arst_n)begin
		cs<=IDLE; 
		tx<=1; // line idealy high
		done<=0;
		i<=0;
		total_frame<=10'b1111111111;// line stays in logic 1 between frames
		busy<=0;
	end
	else if (rst)begin
		cs<=IDLE; 
		tx<=1;
		done<=0;
		i<=0;
		total_frame<=10'b1111111111;
		busy<=0;
	end
	else begin // start checking on the two cases
		done<=0; // by default low 

		// check on cs 
		case (cs)
			IDLE: begin
				tx<=1;
				if (tx_en)begin
					total_frame <= {1'b1, data, 1'b0}; // stop bit (1), data [7:0] , start bit (0)
					busy<=1; 
					cs<= ON;
				end
				else begin
					busy<=0;
					total_frame <= 10'b1111111111;
					cs <= IDLE;
				end

			end

			ON: begin
				busy<= 1; 
				tx <= total_frame[i];
				if (tick)begin
					if (i == 9)begin
						i <= 0;
						busy <= 0; 
						done <= 1;
					end
					else 
						i <= i + 1;
				end
			end 
		endcase // cs

	end
end
endmodule : tx_controller