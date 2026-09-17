`timescale 1ns/1ps

module CRC_16_tb;

    parameter DATA_WIDTH = 128;
    parameter CRC_WIDTH  = 16;

    reg  [DATA_WIDTH-1:0] data_in;
    reg                   clk;
    reg                   rst_n;
    reg                   start;

    wire [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc;
    wire                            done;
    wire                            busy;

    CRC #(
        .DATA_WIDTH (DATA_WIDTH),
        .CRC_WIDTH  (CRC_WIDTH),
        .POLYNOMIAL (17'h11021)
    ) DUT (
        .data_in       (data_in),
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .data_with_crc (data_with_crc),
        .done          (done),
        .busy          (busy)
    );



    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // Test sequence
    // ============================================================

    initial begin

        data_in = 128'b0;
        rst_n   = 1'b0;
        start   = 1'b0;

        // ========================================================
        // Reset
        // ========================================================

        #20;
        rst_n = 1'b1;


        // ========================================================
        // TEST 1 - for the standard ASCII string “123456789” 
        // ========================================================

        // Wait until CRC module is idle
        wait (!busy);

        // Apply test data while module is idle
        @(negedge clk);
        data_in = 128'h00000000000000313233343536373839; // Hex for ASCII "123456789"

        $display("--------------------------------------------");
        $display("TEST 1");
        $display("Input         = %h", data_in);
        $display("Expected CRC  = 16'h31C3");
        $display("--------------------------------------------");

        // Generate one-cycle START pulse
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for CRC calculation to finish
        @(posedge done);

        #1;

        if (data_with_crc[15:0] == 16'h31C3) begin
            $display("TEST 1 PASSED");
            $display("CRC = %h", data_with_crc[15:0]);
        end
        else begin
            $display("TEST 1 FAILED");
            $display("Expected = 16'h31C3");
            $display("Actual   = %h", data_with_crc[15:0]);
        end


        // ========================================================
        // TEST 2
        // ========================================================

        // Wait until module is idle again
        wait (!busy);

        @(negedge clk);

        // Apply second test data
        data_in = 128'h00112233445566778899AABBCCDDEEFF;

        $display("--------------------------------------------");
        $display("TEST 2");
        $display("Input         = %h", data_in);
        $display("Expected CRC  = 16'h1248");
        $display("--------------------------------------------");

        // Generate one-cycle START pulse
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for CRC calculation to finish
        @(posedge done);

        #1;

        if (data_with_crc[15:0] == 16'h1248) begin
            $display("TEST 2 PASSED");
            $display("CRC = %h", data_with_crc[15:0]);
        end
        else begin
            $display("TEST 2 FAILED");
            $display("Expected = 16'h1248");
            $display("Actual   = %h", data_with_crc[15:0]);
        end


        // ========================================================
        // TEST 3
        // ========================================================

        // Wait until module is idle again
        wait (!busy);

        @(negedge clk);

        // Apply third test data
        data_in = 128'h112233445566778899AABBCCDDEEAA55;

        $display("--------------------------------------------");
        $display("TEST 3");
        $display("Input         = %h", data_in);
        $display("Expected CRC  = 16'h8169");
        $display("--------------------------------------------");

        // Generate one-cycle START pulse
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for CRC calculation to finish
        @(posedge done);

        #1;

        if (data_with_crc[15:0] == 16'h8169) begin
            $display("TEST 3 PASSED");
            $display("CRC = %h", data_with_crc[15:0]);
        end
        else begin
            $display("TEST 3 FAILED");
            $display("Expected = 16'h8169");
            $display("Actual   = %h", data_with_crc[15:0]);
        end


        // ========================================================
        // End simulation
        // ========================================================

        #20;

        $display("--------------------------------------------");
        $display("SIMULATION FINISHED");
        $display("--------------------------------------------");

        $finish;

    end

endmodule