module AES_mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    // Split the input state into 4 columns
    wire [31:0] col0 = state_in[127:96];
    wire [31:0] col1 = state_in[95:64];
    wire [31:0] col2 = state_in[63:32];
    wire [31:0] col3 = state_in[31:0];

    // Apply the mix_single_column module to each column
    mix_single_column col0 (.col_in(state_in[127:96]), .col_out(state_out[127:96]));
    mix_single_column col1 (.col_in(state_in[95:64]),  .col_out(state_out[95:64]));
    mix_single_column col2 (.col_in(state_in[63:32]),  .col_out(state_out[63:32]));
    mix_single_column col3 (.col_in(state_in[31:0]),.col_out(state_out[31:0]));
endmodule 