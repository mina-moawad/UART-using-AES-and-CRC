module tx_bit_select (
    input  wire       clk,
    input  wire       rst,
    input  wire       arst_n,
    input  wire       tx_en,
    input  wire       baud_tick,
    output reg        load_en,
    output reg  [3:0] bit_idx,
    output reg        busy,
    output reg        done,
    output wire       active
);
    localparam [1:0] IDLE = 2'b00,
                     LOAD = 2'b01,
                     SEND = 2'b10,
                     DONE = 2'b11;

    reg [1:0] state, next_state;
    reg [3:0] bit_cnt;

    assign active  = (state == SEND);
    assign bit_idx = bit_cnt;

    // Sequential State & Counter Register
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state   <= IDLE;
            bit_cnt <= 4'd0;
        end else if (rst) begin
            state   <= IDLE;
            bit_cnt <= 4'd0;
        end else begin
            state <= next_state;
            if (state == LOAD) begin
                bit_cnt <= 4'd0;
            end else if (state == SEND && baud_tick) begin
                bit_cnt <= bit_cnt + 1'b1;
            end
        end
    end

    // Combinational FSM Logic
    always @(*) begin
        next_state = state;
        load_en    = 1'b0;
        busy       = 1'b1;
        done       = 1'b0;

        case (state)
            IDLE: begin
                busy = 1'b0;
                if (tx_en)
                    next_state = LOAD;
            end

            LOAD: begin
                load_en    = 1'b1; // Latch input byte into frame register
                next_state = SEND;
            end

            SEND: begin
                if (baud_tick && (bit_cnt == 4'd9)) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                busy       = 1'b0;
                done       = 1'b1; // Single-cycle done flag
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule