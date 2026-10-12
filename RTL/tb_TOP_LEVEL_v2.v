`timescale 1ns / 1ps

module tb_TOP_LEVEL_v2();

    parameter DATA_WIDTH = 128;
    parameter CRC_WIDTH  = 16;
    parameter CLK_PERIOD = 10; // 100 MHz clock

    reg         clk;
    reg         rst_n;
    reg         start;
    reg [127:0] plaintext;
    reg [127:0] master_Key;

    wire        done_AES;
    wire        busy_crc;
    wire        done_crc;
    wire        tx_busy_all;
    wire        tx_done_all;
    wire [143:0] received_packet_144;
    wire        packet_ready_rx;

  
    TOP_LEVEL #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .plaintext(plaintext),
        .master_Key(master_Key),
        .done_AES(done_AES),
        .busy_crc(busy_crc),
        .done_crc(done_crc),
        .tx_busy_all(tx_busy_all),
        .tx_done_all(tx_done_all),
        .received_packet_144(received_packet_144),
        .packet_ready_rx(packet_ready_rx)
    );

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Receiver Byte-by-Byte Monitor
    integer byte_idx = 0;
    always @(posedge clk) begin
        if (uut.done_rx) begin
            $display("[TIME %0t ns] Receiver: Byte [%0d] received = 0x%h", $time, byte_idx, uut.rx_data_byte);
            byte_idx = byte_idx + 1;
        end
    end

    // Main Stimulus & Automated End-to-End Functional Verification
    initial begin
        rst_n      = 1'b0;
        start      = 1'b0;
        plaintext  = 128'h3243f6a8885a308d313198a2e0370734; 
        master_Key = 128'h2b7e151628aed2a6abf7158809cf4f3c; 

        $display("\n--- STARTING TOP_LEVEL SYSTEM FUNCTIONAL TEST ---");

        // Apply Reset
        #(CLK_PERIOD * 5);
        rst_n = 1'b1;
        #(CLK_PERIOD * 5);

        // Trigger AES Encryption
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        $display("[TIME %0t ns] AES Encryption and pipeline triggered.", $time);

        // Wait for pipeline stages to progress
        @(posedge done_AES);
        $display("[TIME %0t ns] Stage 1 Check: AES Encryption completed (done_AES asserted).", $time);

        @(posedge done_crc);
        $display("[TIME %0t ns] Stage 2 Check: CRC checksum generated (done_crc asserted).", $time);

        @(posedge tx_done_all);
        $display("[TIME %0t ns] Stage 3 Check: UART transmission completed (tx_done_all asserted).", $time);

        // Wait for Receiver Deserializer to complete parallel reconstruction
        @(posedge packet_ready_rx);
        #1;

        $display("\n==================================================");
        $display("               FINAL SYSTEM OUTPUTS               ");
        $display("==================================================");
        $display("Transmitted 144-bit Packet (Data + CRC): 0x%h", uut.data_with_crc);
        $display("Reconstructed 144-bit Receiver Packet  : 0x%h", received_packet_144);
        
        if (received_packet_144 === uut.data_with_crc) begin
            $display("\n>>> STATUS: TEST PASSED SUCCESSFULLY (Data Integrity Verified) <<<");
        end else begin
            $display("\n>>> STATUS: TEST FAILED (Mismatch Detected) <<<");
        end

        #(CLK_PERIOD * 10);
        $finish;
    end

endmodule