module Key_Expansion(   
    input   [0:127] key,
    input   [3:0] round,
    output  [0:127] round_key
) ;



 wire w3 = key[96:127];
 wire w2 = key[64:95] ;
 wire w1 = key[32:63] ;         //WORDS IN
 wire w0 = key[0:31]  ;

 wire w7 = key[96:127];
 wire w6 = key[64:95] ;
 wire w5 = key[32:63] ;         //WORDS OUT
 wire w4 = key[0:31]  ;


wire [0:31] rotated_word ;
wire [0:31] substituted_word ;
wire [0:31] Rcon ; 
wire [0:7] xored_byte_with_Rcon ;
wire [0:31] substituted_word_after_xor ;




function  automatic [0:31] Rot_Word(
    input [0:31] orig_word
);
Rot_Word = {orig_word[8:31], orig_word[0:7]};
endfunction

assign rotated_word = Rot_Word(w3);


S_box s_box1(rotated_word[0:7] ,  substituted_word[0:7] ) ;
S_box s_box2(rotated_word[8:15] ,  substituted_word[8:15] ) ;
S_box s_box3(rotated_word[16:23] ,  substituted_word[16:23] ) ;  //module S_box to be created
S_box s_box4(rotated_word[24:31] ,  substituted_word[24:31] ) ;




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


assign xored_byte_with_Rcon = substituted_word [0:7] ^ get_Rcon(round) ;
assign substituted_word_after_xor = {xored_byte_with_Rcon , substituted_word[8:31]} ;


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