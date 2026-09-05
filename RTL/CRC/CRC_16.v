 // CRC-16/XMODEM:
// x^16 + x^12 + x^5 + 1 POLYNOMIAL
module CRC #(
    parameter DATA_WIDTH = 128,
    parameter CRC_WIDTH  = 16,

    // CRC-16/XMODEM:
    // x^16 + x^12 + x^5 + 1
    parameter [CRC_WIDTH:0] POLYNOMIAL = 17'h11021

)(
    
    input  wire [DATA_WIDTH-1:0] data_in,

    input  wire                  clk,
    input  wire                  rst_n,

    output reg [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc,
    output reg                  done,
    output reg                  busy

);

    reg [CRC_WIDTH-1:0] crc_reg;
    reg [DATA_WIDTH-1:0] data_in_reg;
    reg [DATA_WIDTH-1:0] counter;


    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            crc_reg       <= {CRC_WIDTH{1'b0}};
            data_in_reg   <= {DATA_WIDTH{1'b0}};
            counter       <= {DATA_WIDTH{1'b0}};

            data_with_crc <= {(DATA_WIDTH+CRC_WIDTH){1'b0}};

            done <= 1'b0;
            busy <= 1'b0;

        end

        else begin
            done <= 1'b0;

            if (!busy) begin

                data_in_reg <= data_in;
                crc_reg <= {CRC_WIDTH{1'b0}};
                counter <= 0;
                busy <= 1'b1;

            end


            else begin

                if (counter < DATA_WIDTH) begin

                    if (crc_reg[CRC_WIDTH-1] ^
                        data_in_reg[DATA_WIDTH-1-counter]) begin

                        crc_reg <= {
                            crc_reg[CRC_WIDTH-2:0],
                            1'b0
                        } ^ POLYNOMIAL[CRC_WIDTH-1:0];

                    end

                    else begin

                        crc_reg <= {
                            crc_reg[CRC_WIDTH-2:0],
                            1'b0
                        };

                    end

                    counter <= counter + 1'b1;

                end
                else begin

                    data_with_crc <= {
                        data_in_reg,
                        crc_reg
                    };

                    done <= 1'b1;
                    busy <= 1'b0;

                    counter <= 0;

                end

            end

        end

    end

endmodule