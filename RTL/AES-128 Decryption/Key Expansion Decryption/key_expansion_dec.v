module Key_Expansion_Dec (

    input  [127:0] key,
    input  [3:0]   round,

    output reg [127:0] round_key

);

wire [127:0] subkey [0:10];

assign subkey[0] = key;

genvar i;

generate

    for (i = 0; i < 10; i = i + 1) begin : 

        Key_Expansion_Enc KE (

            .key       (subkey[i]),
            .round     (i + 1),
            .round_key (subkey[i+1])

        );

    end

endgenerate

always @(*) begin
    
    case (round)
    4'd0:  round_key = subkey[10]; // K10
    4'd1:  round_key = subkey[9];  // K9
    4'd2:  round_key = subkey[8];  // K8
    4'd3:  round_key = subkey[7];  // K7
    4'd4:  round_key = subkey[6];  // K6
    4'd5:  round_key = subkey[5];  // K5
    4'd6:  round_key = subkey[4];  // K4
    4'd7:  round_key = subkey[3];  // K3
    4'd8:  round_key = subkey[2];  // K2
    4'd9:  round_key = subkey[1];  // K1
    4'd10: round_key = subkey[0];  // K0
endcase

end

endmodule