module tx_frame (
    input  wire       clk,
    input  wire       rst,
    input  wire       arst_n,
    input  wire       load_en,
    input  wire [7:0] data_in,
    output reg  [9:0] frame_out
);
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            frame_out <= 10'b11_1111_1111; // Idle TX line (all 1s)
        end else if (rst) begin
            frame_out <= 10'b11_1111_1111;
        end else if (load_en) begin
            // Bit 0 = Start (0), Bits 1..8 = Data, Bit 9 = Stop (1)
            frame_out <= {1'b1, data_in, 1'b0};
        end
    end

endmodule