module rx_fsm(
	input clk, rst, arst_n, 
	input rx_en, 
	input falling_edge, finish,
	input rx,
	output reg en_shift, en_load, en_load_1_5,
	output reg busy, done , err);

parameter IDLE  = 0;
parameter START = 1;
parameter DATA  = 2;
parameter ERR   = 3;
parameter DONE  = 4; 

reg [2:0] cs, ns; 
reg [2:0] index;

/////////////////////////////////////////////////////////////////////////
// index counter 
always@(posedge clk or negedge arst_n)begin
	if (!arst_n)
		index <= 0;
	else if (rst || cs == IDLE) 
		index <= 0;
	else if (cs == DATA && finish)begin
		if (index < 3'b111) begin
			index <= index + 1;
		else 
			index <= 0;
		end
	end
end
//////////////////////////////////////////////////////////////////////////

always@(posedge clk or negedge arst_n) begin
	if (~arst_n)
		cs<=IDLE;
	else if (rst)
		cs <= IDLE;
	else 
		cs <= ns;
end

always@(*) begin
	ns<=cs;
	case (cs)
		IDLE: begin
			if (rx_en && falling_edge)	
				ns<=START;
			else 
				ns <= IDLE;
	end 

		START: begin
			if (finish && !rx)
				ns <= DATA;
			else 
				ns <= START;
	end 

		DATA: begin
			if (finish) begin
				if (index == 3'b111 && rx)
					ns <= DONE;
				else 
					ns <= ERR; 
			end
			else 
				ns <= DATA;
		end 

		DONE: begin
			ns <= IDLE;
		end 

		ERR: begin
			ns <= IDLE;
		end 

	endcase // cs


//////////////////////////////////////////////////////////////////////////
// output logic 
always@(*)begin
	if (arst_n)begin
		en_shift = 0; 
		en_load = 0;
		en_load_1_5 = 0;
		busy = 0;
		done = 0;
		err = 0;
	end
	else if (rst)begin
		en_shift = 0; 
		en_load = 0;
		en_load_1_5 = 0;
		busy = 0;
		done = 0;
		err = 0;	
	end
	else begin
		en_shift = 0; 
		en_load = 0;
		en_load_1_5 = 0;
		busy = 0;
		done = 0;
		err = 0;
	


	case (cs)

		IDLE:
			index <= 0;

		START: begin
			busy = 1; 
			en_load = 1; 
		end 

		DATA: begin
			busy = 1;
			if (finish) begin
				en_shift = 1;
				if (index < 3'b111) begin
					en_load = 1;
					index = index + 1; 
				end
			end
		end 

		DONE: begin 
			done = 1; 
			busy = 0;
		end

		ERR: begin
			err = 1;
		end 
		endcase  
end
end
endmodule : rx_fsm