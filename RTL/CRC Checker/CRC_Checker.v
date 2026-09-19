module CRC_Checker #(
    parameter DATA_WIDTH = 128,
    parameter CRC_WIDTH  = 16,
    parameter [CRC_WIDTH:0] POLYNOMIAL = 17'h11021
)(
    input  wire clk,
    input  wire rst_n,
    input  wire start,

    input wire [DATA_WIDTH+CRC_WIDTH-1:0] received_data,

    output reg [DATA_WIDTH-1:0] data_out,

    output reg error,
    output reg accept,
    output reg done,
    output reg busy
);

    reg [CRC_WIDTH-1:0] crc_reg;

    reg [DATA_WIDTH+CRC_WIDTH-1:0] received_data_reg;

    reg [7:0] counter;


    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            crc_reg           <= {CRC_WIDTH{1'b0}};
            received_data_reg <= {(DATA_WIDTH+CRC_WIDTH){1'b0}};
            counter           <= 8'd0;
            data_out          <= {DATA_WIDTH{1'b0}};
            error             <= 1'b0;
            accept            <= 1'b0;
            done              <= 1'b0;
            busy              <= 1'b0;

        end

        else begin
            done <= 1'b0;

            if (start && !busy) begin
                received_data_reg <= received_data;
                crc_reg <= {CRC_WIDTH{1'b0}};
                counter <= 8'd0;
                error  <= 1'b0;
                accept <= 1'b0;
                busy <= 1'b1;

            end

            else if (busy) begin

                if (counter < DATA_WIDTH + CRC_WIDTH) begin

                    if (crc_reg[CRC_WIDTH-1] ^
                        received_data_reg[DATA_WIDTH+CRC_WIDTH-1-counter]) begin

                        crc_reg <=
                            {crc_reg[CRC_WIDTH-2:0], 1'b0}
                            ^ POLYNOMIAL[CRC_WIDTH-1:0];

                    end

                    else begin

                        crc_reg <=
                            {crc_reg[CRC_WIDTH-2:0], 1'b0};

                    end

                    counter <= counter + 1'b1;

                end

                else begin
                    data_out <= received_data_reg[DATA_WIDTH+CRC_WIDTH-1:CRC_WIDTH];
                    if (crc_reg == {CRC_WIDTH{1'b0}}) begin
                        error  <= 1'b0;
                        accept <= 1'b1;
                    end

                    else begin

                        error  <= 1'b1;
                        accept <= 1'b0;

                    end

                    done    <= 1'b1;
                    busy    <= 1'b0;
                    counter <= 8'd0;

                end

            end

        end

    end

endmodule