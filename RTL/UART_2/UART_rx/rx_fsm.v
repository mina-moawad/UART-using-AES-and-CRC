module rx_fsm #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       arst_n,
    input  wire       rx_en,
    input  wire       falling_edge,
    input  wire       baud_zero,
    input  wire [2:0] bit_cnt,
    input  wire       rx_sync,
    output reg        load_en,
    output reg [15:0] load_val,
    output reg        sipo_en,
    output reg        clr_cnt,
    output reg        busy,
    output reg        done,
    output reg        err
);
    localparam BIT_TICKS    = CLK_FREQ / BAUD_RATE;
    localparam ONE_HALF_BIT = BIT_TICKS + (BIT_TICKS / 2);

    localparam [2:0] IDLE  = 3'b000,
                     START = 3'b001,
                     DATA  = 3'b010,
                     DONE  = 3'b011,
                     ERR   = 3'b100;

    reg [2:0] current_state, next_state;

    // State Register
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n)
            current_state <= IDLE;
        else if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next State & Output Logic
    always @(*) begin
        next_state = current_state;
        load_en    = 1'b0;
        load_val   = BIT_TICKS;
        sipo_en    = 1'b0;
        clr_cnt    = 1'b0;
        busy       = 1'b1;
        done       = 1'b0;
        err        = 1'b0;

        case (current_state)
            IDLE: begin
                busy    = 1'b0;
                clr_cnt = 1'b1;
                if (rx_en && falling_edge) begin
                    load_val   = ONE_HALF_BIT; // 1.5 bit periods to hit middle of D0
                    load_en    = 1'b1;
                    next_state = START;
                end
            end

            START: begin
                if (baud_zero) begin
                    sipo_en    = 1'b1; // Sample D0
                    load_val   = BIT_TICKS;
                    load_en    = 1'b1;
                    next_state = DATA;
                end
            end

            DATA: begin
                if (baud_zero) begin
                    if (bit_cnt == 3'd7) begin
                        // 8 bits received. Evaluate stop bit (must be high)
                        if (rx_sync == 1'b1)
                            next_state = DONE;
                        else
                            next_state = ERR;
                    end else begin
                        sipo_en    = 1'b1; // Sample D1 through D7
                        load_val   = BIT_TICKS;
                        load_en    = 1'b1;
                    end
                end
            end

            DONE: begin
                busy       = 1'b0;
                done       = 1'b1;
                next_state = IDLE;
            end

            ERR: begin
                busy       = 1'b0;
                err        = 1'b1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule