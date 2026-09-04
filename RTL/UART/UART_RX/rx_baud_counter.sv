module rx_baud_counter(
    input clk, rst, arst_n,
    input en_load, en_load_1_5, 
    output reg finish
);
    parameter CYCLES     = 50000000 / 9600; // 5208 cycles
    parameter CYCLES_1_5 = CYCLES * 3 / 2;  // 7812 cycles
    parameter SIZE       = $clog2(CYCLES_1_5);

    reg [SIZE-1:0] counter;
    reg active;

    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            counter <= 0;
            active  <= 0;
            finish  <= 0;
        end
        else if (rst) begin
            counter <= 0;
            active  <= 0;
            finish  <= 0;
        end
        else if (en_load) begin
            active <= 1;
            finish <= 0;
            if (en_load_1_5)
                counter <= CYCLES_1_5 - 1;
            else 
                counter <= CYCLES - 1;
        end
        else if (active) begin
            if (counter == 1) begin
                counter <= 0;
                finish  <= 1;
                active  <= 0;
            end
            else begin
                counter <= counter - 1;
                finish  <= 0;
            end
        end
        else begin
            finish <= 0;
        end
    end
endmodule