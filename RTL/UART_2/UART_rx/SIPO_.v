module SIPO (
    input  wire       clk,
    input  wire       rst_n,     // Active-low asynchronous reset
    input  wire       rx, 
    input  wire       sipo_en,   // Pulsed once per bit period by FSM
    input  wire       clr_cnt,   // Clears internal state/counter
    output wire [7:0] data_out,
    output reg  [2:0] bit_cnt    // Keeps track of sampled bit count
); 
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= 8'b0; 
            bit_cnt  <= 3'b0;
        end else if (clr_cnt) begin
            bit_cnt  <= 3'b0;
        end else if (sipo_en) begin
            data_reg <= {rx, data_reg[7:1]}; // Shift right (LSB first)
            bit_cnt  <= bit_cnt + 1'b1;
        end
    end

    assign data_out = data_reg;

endmodule