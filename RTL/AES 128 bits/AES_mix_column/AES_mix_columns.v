module AES_mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    // Apply the mix_single_column module to each column
    mix_single_column col00 (.col_in(state_in[127:96]), .col_out(state_out[127:96]));
    mix_single_column col11 (.col_in(state_in[95:64]),  .col_out(state_out[95:64]));
    mix_single_column col22 (.col_in(state_in[63:32]),  .col_out(state_out[63:32]));
    mix_single_column col33 (.col_in(state_in[31:0]),.col_out(state_out[31:0]));
endmodule 