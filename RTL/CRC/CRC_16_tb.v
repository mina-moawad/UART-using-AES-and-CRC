`timescale 1ns/1ps
module CRC_tb;

    // -----------------------------------------
    // Parameters
    // -----------------------------------------

    parameter DATA_WIDTH = 4;
    parameter CRC_WIDTH  = 3;

    // -----------------------------------------
    // Testbench signals
    // -----------------------------------------

    reg [DATA_WIDTH-1:0] data_in;
    reg                  clk;
    reg                  rst_n;

    wire [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc;
    wire                             done;
    wire busy ;

    // -----------------------------------------
    // DUT
    // -----------------------------------------

    CRC2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH),
        .POLYNOMIAL(4'b1011)
    )
    DUT (
        .data_in(data_in),
        .clk(clk),
        .rst_n(rst_n),
        .data_with_crc(data_with_crc),
        .done(done) , 
        .busy(busy)
        );


    // -----------------------------------------
    // Clock
    // 10 ns period
    // -----------------------------------------

    always #5 clk = ~clk;


    // -----------------------------------------
    // Test
    // -----------------------------------------

    initial begin

        // Initial values
        clk    = 1'b0;
        rst_n  = 1'b0;
        data_in = 4'b0000;

        // Reset
        #20;
        rst_n = 1'b1;
        

        // =====================================
        // TEST 1
        // =====================================

        data_in = 4'b1001;
        #45 ; 
        // Wait until CRC calculation finishes
        // wait(done);
        // wait(!busy);

       //#2;

        $display("Data = %b | Data + CRC = %b",
                 data_in,
                 data_with_crc);


        // =====================================
        // TEST 2
        // =====================================

        //#10;

        data_in = 4'b1010;

        // wait(done);
        // wait(!busy);
        //#2;
        #50 ;

        $display("Data = %b | Data + CRC = %b",
                 data_in,
                 data_with_crc);


        // =====================================
        // TEST 3
        // =====================================

       // #10;

        data_in = 4'b0000;

       #50 ;

        //#2;

        $display("Data = %b | Data + CRC = %b",
                 data_in,
                 data_with_crc);


        #20;

        $finish;

    end


    // -----------------------------------------
    // Monitor
    // -----------------------------------------

    initial begin

        $monitor("Time=%0t | clk=%b | rst_n=%b | data=%b | CRC_word=%b | done=%b",
                 $time,
                 clk,
                 rst_n,
                 data_in,
                 data_with_crc,
                 done);

    end

endmodule