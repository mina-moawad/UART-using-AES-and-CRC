module aes_inv_mix_columns (
    input  wire [127:0] state_in,
    output reg  [127:0] state_out
);

    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    function [7:0] mul_09; input [7:0] b; begin mul_09 = xtime(xtime(xtime(b))) ^ b; end endfunction
    function [7:0] mul_0B; input [7:0] b; begin mul_0B = xtime(xtime(xtime(b))) ^ xtime(b) ^ b; end endfunction
    function [7:0] mul_0D; input [7:0] b; begin mul_0D = xtime(xtime(xtime(b))) ^ xtime(xtime(b)) ^ b; end endfunction
    function [7:0] mul_0E; input [7:0] b; begin mul_0E = xtime(xtime(xtime(b))) ^ xtime(xtime(b)) ^ xtime(b); end endfunction

    function [31:0] inv_mix_single_column;
        input [31:0] col_in;
        reg [7:0] s0, s1, s2, s3;
        begin
            s0 = col_in[31:24]; s1 = col_in[23:16];
            s2 = col_in[15:8];  s3 = col_in[7:0];

            inv_mix_single_column[31:24] = mul_0E(s0) ^ mul_0B(s1) ^ mul_0D(s2) ^ mul_09(s3);
            inv_mix_single_column[23:16] = mul_09(s0) ^ mul_0E(s1) ^ mul_0B(s2) ^ mul_0D(s3);
            inv_mix_single_column[15:8]  = mul_0D(s0) ^ mul_09(s1) ^ mul_0E(s2) ^ mul_0B(s3);
            inv_mix_single_column[7:0]   = mul_0B(s0) ^ mul_0D(s1) ^ mul_09(s2) ^ mul_0E(s3);
        end
    endfunction

    always @(*) begin
        state_out[127:96] = inv_mix_single_column(state_in[127:96]);
        state_out[95:64]  = inv_mix_single_column(state_in[95:64]);
        state_out[63:32]  = inv_mix_single_column(state_in[63:32]);
        state_out[31:0]   = inv_mix_single_column(state_in[31:0]);
    end

endmodule