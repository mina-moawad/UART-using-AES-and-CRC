module tx_mux (
    input  wire [9:0] frame_in,
    input  wire [3:0] bit_idx,
    input  wire       busy,
    output wire       tx
);
    // If busy, output frame[bit_idx]; otherwise hold line HIGH (1)
    assign tx = busy ? frame_in[bit_idx] : 1'b1;

endmodule