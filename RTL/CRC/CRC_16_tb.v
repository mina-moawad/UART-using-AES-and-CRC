`timescale 1ns/1ps

module CRC_tb;

    parameter DATA_WIDTH = 128;
    parameter CRC_WIDTH  = 16;

    reg  [DATA_WIDTH-1:0] data_in;
    reg                   clk;
    reg                   rst_n;

    wire [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc;
    wire                            done;
    wire                            busy;


    // ============================================================
    // DUT
    // ============================================================

    CRC #(
        .DATA_WIDTH (DATA_WIDTH),
        .CRC_WIDTH  (CRC_WIDTH),
        .POLYNOMIAL (17'h11021)
    ) DUT (
        .data_in       (data_in),
        .clk           (clk),
        .rst_n         (rst_n),
        .data_with_crc (data_with_crc),
        .done          (done),
        .busy          (busy)
    );


    // ============================================================
    // Clock
    // ============================================================

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

        // Reset
        #20;
        rst_n = 1'b1;


        // ========================================================
        // TEST 1
        // ========================================================

        // Wait for any previous operation to finish
        wait (!busy);

        // Wait until done is definitely low
        @(negedge clk);

        // Apply test data while module is idle
        data_in = 128'h31323334353637383941424344454630;

        $display("--------------------------------------------");
        $display("TEST 1");
        $display("Input         = %h", data_in);
        $display("Expected CRC  = 16'h2952");
        $display("--------------------------------------------");

        // Wait for the module to become busy
        @(posedge clk);

        // Wait for operation to finish
        @(posedge done);

        #1;

        if (data_with_crc[15:0] == 16'h2952) begin
            $display("TEST 1 PASSED");
            $display("CRC = %h", data_with_crc[15:0]);
        end
        else begin
            $display("TEST 1 FAILED");
            $display("Expected = 16'h2952");
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

        // Wait for new operation
        @(posedge clk);

        // Wait for new done pulse
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
 //test 3
         wait (!busy);

        @(negedge clk);

        // Apply second test data
        data_in = 128'h112233445566778899AABBCCDDEEAA55;

        $display("--------------------------------------------");
        $display("TEST 3");
        $display("Input         = %h", data_in);
        $display("Expected CRC  = 16'h8169");
        $display("--------------------------------------------");

        // Wait for new operation
        @(posedge clk);

        // Wait for new done pulse
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