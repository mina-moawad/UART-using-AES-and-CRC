module Key_Expansion(   
    input   [127:0] key,
    input   [3:0] round,
    output  [127:0] round_key // round_key dah hyb2a 1048 bits 
) ;



 wire [31:0] w3 = key[127:96];
 wire [31:0] w2 = key[95:64] ;
 wire [31:0] w1 = key[63:32] ;         //WORDS IN
 wire [31:0] w0 = key[31:0]  ;

 wire [31:0] w7;
 wire [31:0] w6;
 wire [31:0] w5;         //WORDS OUT
 wire [31:0] w4;


wire [31:0] rotated_word ;
wire [31:0] substituted_word ;
wire [31:0] Rcon ; 
wire [7:0] xored_byte_with_Rcon ;
wire [31:0] substituted_word_after_xor ;




function  automatic [31:0] Rot_Word(
    input [31:0] orig_word
);
Rot_Word = {orig_word[7:0], orig_word[31:8]};
endfunction

assign rotated_word = Rot_Word(w3);


S_box s_box1(rotated_word[7:0] ,  substituted_word[7:0] ) ;
S_box s_box2(rotated_word[15:8] ,  substituted_word[15:8] ) ;
S_box s_box3(rotated_word[23:16] ,  substituted_word[23:16] ) ;  //module S_box to be created
S_box s_box4(rotated_word[31:24] ,  substituted_word[31:24] ) ;




function [7:0] get_Rcon;
        input [3:0] round;

        begin
            case (round)
                4'd1:  get_Rcon = 8'h01;
                4'd2:  get_Rcon = 8'h02;
                4'd3:  get_Rcon = 8'h04;
                4'd4:  get_Rcon = 8'h08;
                4'd5:  get_Rcon = 8'h10;
                4'd6:  get_Rcon = 8'h20;
                4'd7:  get_Rcon = 8'h40;
                4'd8:  get_Rcon = 8'h80;
                4'd9:  get_Rcon = 8'h1B;
                4'd10: get_Rcon = 8'h36;

                default: get_Rcon = 8'h00;
            endcase
        end
    endfunction


assign xored_byte_with_Rcon = substituted_word [7:0] ^ get_Rcon(round) ;
assign substituted_word_after_xor = {xored_byte_with_Rcon , substituted_word[31:8]} ;


assign w4 = w0 ^ substituted_word_after_xor;
assign w5 = w1 ^ w4;
assign w6 = w2 ^ w5;
assign w7 = w3 ^ w6;

assign round_key = {w4 , w5 , w6 , w7} ;

endmodule


// function automatic [7:0] xtime(input [7:0] b);
//         begin
//             if (b[7])                      
//                 xtime = (b << 1) ^ 8'h1B; //{b6 b5 b4 b3 b2 b1 b0 0}⊕{0 0 0 1 1 0 1 1} , if b7 = 1. 
//             else
//                 xtime = b << 1;           //{b6 b5 b4 b3 b2 b1 b0 0} , if b7 = 0 
//         end
//     endfunction