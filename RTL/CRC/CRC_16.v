module CRC #(
    parameter DATA_WIDTH = 4,
    parameter CRC_WIDTH  = 3,

    // Polynomial has CRC_WIDTH + 1 bits
    parameter [CRC_WIDTH:0] POLYNOMIAL = 4'b1011

)(
    
    input  wire [DATA_WIDTH-1:0] data_in,

    input  wire                  clk,
    input  wire                  rst_n,

    output reg [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc,
    output reg                  done , 
    output reg busy

);


    reg [CRC_WIDTH:0] stage;   
    // reg [CRC_WIDTH:0] stage_2;        
     

    reg [DATA_WIDTH+CRC_WIDTH-1:0] data_with_zeros;

    reg [DATA_WIDTH-1:0] counter;

    reg  [DATA_WIDTH-1:0] data_in_reg ;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            stage          <= {(CRC_WIDTH+1){1'b0}};
            // stage_2        <= {(CRC_WIDTH+1){1'b0}};
            data_with_zeros <= {(DATA_WIDTH+CRC_WIDTH){1'b0}};
            counter        <= {DATA_WIDTH{1'b0}};
            data_with_crc  <= {(DATA_WIDTH+CRC_WIDTH){1'b0}};
            done           <= 1'b0;
            busy           <= 1'b0;


        end

        else begin
            done <= 1'b0;
           // busy <= 1'b1;

    if(!busy) begin
        
            if (counter == 0) begin
                busy <= 1'b1;
                data_with_zeros <= {
                    data_in,
                    {CRC_WIDTH{1'b0}}
                };

                stage <= data_in[DATA_WIDTH-1:
                                  DATA_WIDTH-CRC_WIDTH-1];

                counter <= counter + 1'b1;

            end

    end
            

            else if (counter < DATA_WIDTH) begin
                busy <= 1'b1;
                if (stage[CRC_WIDTH]) begin
                    stage <= {
                        stage[CRC_WIDTH-1:0] ^ POLYNOMIAL[CRC_WIDTH-1:0],
                        data_with_zeros[CRC_WIDTH-counter]
                    }  ;

                end

                else begin
                    stage <= {
                        stage[CRC_WIDTH-1:0],
                        data_with_zeros[ CRC_WIDTH-counter]
                    };

                end

                counter <= counter + 1'b1;

            end


    

            else if (counter == DATA_WIDTH) begin

                if (stage[CRC_WIDTH]) begin
                    data_with_crc <= {
                        data_in,
                        stage[CRC_WIDTH-1:0] ^ POLYNOMIAL[CRC_WIDTH-1:0]
                    };

                end

                else begin
                    data_with_crc <= {
                        data_in,
                        stage[CRC_WIDTH-1:0]
                    };

                end
                done <= 1'b1;
                busy <= 1'b0;
                counter  <= 0 ; 
                stage    <= 0 ;

            end
        
        

    end
    end

endmodule