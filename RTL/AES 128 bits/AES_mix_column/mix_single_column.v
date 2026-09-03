module mix_single_column (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);
    wire [7:0] s0 = col_in[31:24];
    wire [7:0] s1 = col_in[23:16];
    wire [7:0] s2 = col_in[15:8];
    wire [7:0] s3 = col_in[7:0];

    // Inline Galois Field multiplication by 2 (xtime)
    wire [7:0] s0_x2 = (s0[7]) ? ((s0 << 1) ^ 8'h1b) : (s0 << 1);
    wire [7:0] s1_x2 = (s1[7]) ? ((s1 << 1) ^ 8'h1b) : (s1 << 1);
    wire [7:0] s2_x2 = (s2[7]) ? ((s2 << 1) ^ 8'h1b) : (s2 << 1);
    wire [7:0] s3_x2 = (s3[7]) ? ((s3 << 1) ^ 8'h1b) : (s3 << 1);

    // Galois Field multiplication by 3: (s * 2) ^ s
    wire [7:0] s0_x3 = s0_x2 ^ s0; // (s0 * 2) XOR (s0 * 1) = s0 * 3
    wire [7:0] s1_x3 = s1_x2 ^ s1; // (s1 * 2) XOR (s1 * 1) = s1 * 3
    wire [7:0] s2_x3 = s2_x2 ^ s2; // (s2 * 2) XOR (s2 * 1) = s2 * 3
    wire [7:0] s3_x3 = s3_x2 ^ s3; // (s3 * 2) XOR (s3 * 1) = s3 * 3

    // Direct continuous wire assignments for outputs
    assign col_out[31:24] = s0_x3 ^ s1_x2 ^ s2    ^ s3;
    assign col_out[23:16] = s0    ^ s1_x3 ^ s2_x2 ^ s3;
    assign col_out[15:8]  = s0    ^ s1    ^ s2_x3 ^ s3_x2;
    assign col_out[7:0]   = s0_x2 ^ s1    ^ s2    ^ s3_x3;

endmodule   