module baud_rate_generator #(
    parameter CLK_FREQ  = 50000000, // System clock frequency in Hz
    parameter BAUD_RATE = 9600     // Desired baud rate
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        arst_n,
    input  wire        load_en,    // Load/reload command pulse from FSM
    input  wire        is_half_bit,// 1 = Load 1.5 bit time (RX start), 0 = Load 1.0 bit time
    output wire        baud_zero   // Flag asserted HIGH when counter reaches zero
);

    // Timing parameters calculated at compile time
    localparam BIT_TICKS    = CLK_FREQ / BAUD_RATE;
    localparam ONE_HALF_BIT = BIT_TICKS + (BIT_TICKS / 2);

    reg [15:0] count;

    // Zero flag output for FSM synchronization
    assign baud_zero = (count == 16'd0);

    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            count <= 16'd0;
        end else if (rst) begin
            count <= 16'd0;
        end else if (load_en) begin
            // Select 1.5 bit ticks for RX alignment, or 1.0 bit ticks for normal bit duration
            if (is_half_bit)
                count <= ONE_HALF_BIT - 1'b1;
            else
                count <= BIT_TICKS - 1'b1;
        end else if (count > 0) begin
            count <= count - 1'b1;
        end
    end

endmodule