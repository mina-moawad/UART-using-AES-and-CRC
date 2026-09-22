module CRC_to_UART #(
    parameter PACKET_WIDTH = 144,
    parameter NUM_BYTES    = 18
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  crc_done,
    input  wire [PACKET_WIDTH-1:0] crc_data_with_crc,
    input  wire                  uart_done,
    input  wire                  uart_busy,

    output reg  [7:0]            tx_data,
    output reg                   tx_en,
    output reg                   serializer_busy,
    output reg                   serializer_done
);

    localparam [1:0] IDLE      = 2'b00;
    localparam [1:0] LOAD      = 2'b01;
    localparam [1:0] WAIT_UART = 2'b10;

    reg [1:0]              state;
    reg [PACKET_WIDTH-1:0] shift_reg;
    reg [4:0]              byte_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= IDLE;
            shift_reg       <= {PACKET_WIDTH{1'b0}};
            byte_cnt        <= 5'd0;
            tx_data         <= 8'd0;
            tx_en           <= 1'b0;
            serializer_busy <= 1'b0;
            serializer_done <= 1'b0;
        end else begin
            // Default pulse resets
            tx_en           <= 1'b0;
            serializer_done <= 1'b0;

            case (state)
                IDLE: begin
                    byte_cnt <= 5'd0;
                    if (crc_done) begin
                        shift_reg       <= crc_data_with_crc;
                        serializer_busy <= 1'b1;
                        state           <= LOAD;
                    end else begin
                        serializer_busy <= 1'b0;
                    end
                end

                LOAD: begin
                    tx_data   <= shift_reg[PACKET_WIDTH-1 : PACKET_WIDTH-8];
                    tx_en     <= 1'b1;
                    state     <= WAIT_UART;
                end

                WAIT_UART: begin
                    if (uart_done) begin
                        if (byte_cnt == NUM_BYTES - 1) begin
                            state           <= IDLE;
                            serializer_done <= 1'b1;
                            serializer_busy <= 1'b0;
                        end else begin
                            shift_reg <= {shift_reg[PACKET_WIDTH-9:0], 8'h00}; // Shift ONCE byte is sent
                            byte_cnt  <= byte_cnt + 1'b1;
                            state     <= LOAD;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end 
    end 

endmodule