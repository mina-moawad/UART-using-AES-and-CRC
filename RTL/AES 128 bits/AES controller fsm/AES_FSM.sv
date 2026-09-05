module AES_FSM (
	input clk, rst_n, start,
	input [127:0] plaintext, master_key,
	output reg [127:0] ciphertext,
	output reg done);

parameter AES_IDLE = 0;
parameter AES_ADD_ROUND_KEY_0 = 1;
parameter AES_ROUND_LOOP = 2; 
parameter AES_FINAL_ROUND = 3;
parameter AES_DONE = 4;

reg [2:0] cs, ns; 

reg  [127:0] key_reg;
reg  [3:0] round_cnt;
reg  [127:0] state_reg;

wire [127:0] sub_bytes_out;
wire [127:0] shift_row_out;
wire [127:0] mix_col_out;
wire [127:0] round_key_out;
wire [127:0] add_key_state;
wire [127:0] add_round_key_out;

Sub_Bytes Sub_init (state_reg, sub_bytes_out);

AES_Shift_Row SHIFT_ROW (sub_bytes_out, shift_row_out);

AES_mix_columns mix (shift_row_out, mix_col_out);

Key_Expansion key (key_reg, round_cnt, round_key_out);

assign add_key_state = (cs == AES_FINAL_ROUND)? shift_row_out : mix_col_out;

// // assigning mux for addroundkey inputs
// wire [127:0] ark_state = (cs == AES_ADD_ROUND_KEY_0) ? plaintext : add_key_state;
// wire [127:0] ark_key   = (cs == AES_ADD_ROUND_KEY_0) ? master_key : round_key_out;

Add_Round_Key addkey (add_key_state, round_key_out, add_round_key_out);
//////////////////////////////////////////////////////////////////////////////////////////////////


// state register
always@(posedge clk or negedge rst_n) begin
	if (!rst_n)
		cs <= AES_IDLE;
	else 
		cs <= ns;
end

// Next state logic
always@(*)begin
	case (cs)
		AES_IDLE: begin
			if (start)
				ns = AES_ADD_ROUND_KEY_0;
			else 
				ns = AES_IDLE;
		end 

		AES_ADD_ROUND_KEY_0: begin
			ns = AES_ROUND_LOOP; 
		end 

		AES_ROUND_LOOP: begin
			if (round_cnt == 4'b1001) 
				ns =AES_FINAL_ROUND; 
			else 
				ns = AES_IDLE;
		end 

		AES_FINAL_ROUND: begin
			ns = AES_DONE;
		end 

		AES_DONE: begin
			ns = AES_IDLE; 
		end 

		default: ns = AES_IDLE;
	endcase // cs
end

// output logic 
always@(posedge clk or negedge rst_n) begin
	if (!rst_n) begin 
		state_reg <= 0; 
		key_reg <= 0;
		round_cnt <= 0; 
		ciphertext <= 0; 
		done <= 0;
	end 
	else begin
		case (cs)
			AES_IDLE: begin
				done <= 0; 
				if (start)begin
					state_reg <= plaintext;
					key_reg <= master_key; 
				end
			end 

			AES_ADD_ROUND_KEY_0: begin
				state_reg <= state_reg ^ key_reg;
				round_cnt <= 1;
			end 

			AES_ROUND_LOOP: begin
				state_reg <= add_round_key_out; 
				key_reg <= round_key_out;
				round_cnt <= round_cnt + 1; 
			end 

			AES_FINAL_ROUND: begin
				ciphertext <= add_round_key_out; 
				done <= 1;
			end 

			AES_DONE: begin
				done <= 0;  // to hold ciphertext valid 
			end 
		endcase
	end
end
endmodule : AES_FSM