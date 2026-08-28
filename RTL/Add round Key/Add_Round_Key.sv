module Add_Round_Key(
    input  logic [127:0] state,
    input  logic [127:0] round_key,
    output logic [127:0] new_state
) ;


assign new_state =state ^ round_key;

endmodule