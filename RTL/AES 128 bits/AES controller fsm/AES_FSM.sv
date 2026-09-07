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

// function [127:0] transpose_128;
//     input [127:0] in;
//     begin
//         transpose_128 = {
//             in[127:120], in[95:88],  in[63:56],  in[31:24],
//             in[119:112], in[87:80],  in[55:48],  in[23:16],
//             in[111:104], in[79:72],  in[47:40],  in[15:8],
//             in[103:96],  in[71:64],  in[39:32],  in[7:0]
//         };
//     end
// endfunction

subBytes Sub_init (state_reg, sub_bytes_out);

AES_Shift_Row SHIFT_ROW (sub_bytes_out, shift_row_out);

AES_mix_columns mix (shift_row_out, mix_col_out);

Key_Expansion key (key_reg, round_cnt, round_key_out);

assign add_key_state = (cs == AES_FINAL_ROUND)? shift_row_out : mix_col_out;


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
				ns = AES_ROUND_LOOP;
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
				round_cnt <= 0;
				if (start)begin
					state_reg <= plaintext;
					key_reg <= master_key; 
				end
			end 

			AES_ADD_ROUND_KEY_0: begin
				state_reg <= plaintext ^ master_key;
				key_reg <= master_key;
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

always @(posedge clk) begin
        if (cs == AES_ADD_ROUND_KEY_0) begin
            $display("\n=================== AES ROUND 0 ===================");
            $display("State After Round 0  : %h", plaintext ^ master_key);
            $display("Master Key           : %h", master_key);
        end
        else if (cs == AES_ROUND_LOOP) begin
            $display("\n------------------- AES ROUND %0d -------------------", round_cnt);
            $display("SubBytes Out         : %h", sub_bytes_out);
            $display("ShiftRows Out        : %h", shift_row_out);
            $display("MixColumns Out       : %h", mix_col_out);
            $display("Generated Round Key  : %h", round_key_out);
            $display("State Out (Next)     : %h", add_round_key_out);
        end
        else if (cs == AES_FINAL_ROUND) begin
            $display("\n=================== FINAL ROUND 10 ===================");
            $display("SubBytes Out         : %h", sub_bytes_out);
            $display("ShiftRows Out        : %h", shift_row_out);
            $display("Final Round Key      : %h", round_key_out);
            $display("Final Ciphertext     : %h", add_round_key_out);
            $display("======================================================\n");
        end
    end
endmodule : AES_FSM