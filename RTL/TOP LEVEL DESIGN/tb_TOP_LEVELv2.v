`timescale 1ns/1ps
//==============================================================================
// TOP_LEVELv2
// Drives plaintext + master key into TOP_LEVEL and prints what appears after
// each stage, ending with the bytes seen at the UART receiver, one by one.
//
// Stimulus (FIPS-197 Appendix B):
//   plaintext  = 3243f6a8885a308d313198a2e0370734
//   master_Key = 2b7e151628aed2a6abf7158809cf4f3c
//
// Expected with a CORRECT AES-128 + CRC-16/XMODEM:
//   ciphertext = 3925841d02dc09fbdc118597196a0b32
//   CRC-16     = db05
//   RX bytes (in order received):
//     byte  0 = 39   byte  1 = 25   byte  2 = 84   byte  3 = 1d
//     byte  4 = 02   byte  5 = dc   byte  6 = 09   byte  7 = fb
//     byte  8 = dc   byte  9 = 11   byte 10 = 85   byte 11 = 97
//     byte 12 = 19   byte 13 = 6a   byte 14 = 0b   byte 15 = 32
//     byte 16 = db   byte 17 = 05   (CRC high byte, then low byte)
//==============================================================================
module TOP_LEVELv2 ();
 
    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [127:0] plaintext;
    reg  [127:0] master_Key;
 
    wire         done_AES;
    wire         busy_crc;
    wire         done_crc;
    wire         tx_busy_all;
    wire         tx_done_all;
    wire [7:0]   rx_data;
    wire         done_rx;
    wire         busy_rx;
    wire         err_rx;
 
    TOP_LEVEL dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .plaintext   (plaintext),
        .master_Key  (master_Key),
        .done_AES    (done_AES),
        .busy_crc    (busy_crc),
        .done_crc    (done_crc),
        .tx_busy_all (tx_busy_all),
        .tx_done_all (tx_done_all),
        .rx_data     (rx_data),
        .done_rx     (done_rx),
        .busy_rx     (busy_rx),
        .err_rx      (err_rx)
    );
 
    // 50 MHz clock (UART baud generators assume 50 MHz for 9600 baud)
    initial clk = 1'b0;
    always #10 clk = ~clk;
 
    integer rx_cnt = 0;
    reg [143:0] rx_packet = 144'd0;   // received bytes assembled in order
 
    // ---- Stage 1: AES ------------------------------------------------------
    always @(posedge clk)
        if (done_AES) begin
            $display("\n[%0t ns] STAGE 1 - AES done", $time);
            $display("         ciphertext      = %h", dut.ciphertext);
        end
 
    // ---- Stage 2: CRC ------------------------------------------------------
    always @(posedge clk)
        if (done_crc) begin
            $display("\n[%0t ns] STAGE 2 - CRC done", $time);
            $display("         CRC-16          = %h", dut.data_with_crc[15:0]);
            $display("         data_with_crc   = %h  (18 bytes: 16 data + 2 CRC)", dut.data_with_crc);
        end
 
    // ---- Stage 3: serializer / UART transmit -------------------------------
    always @(posedge clk) begin
        if (dut.tx_en_byte)
            $display("[%0t ns] STAGE 3 - TX sends byte = %h", $time, dut.tx_data_byte);
        if (tx_done_all)
            $display("\n[%0t ns] STAGE 3 - serializer done (all 18 bytes sent)", $time);
    end
 
    // ---- Stage 4: UART receiver, byte by byte ------------------------------
    always @(posedge clk) begin
        if (err_rx)
            $display("[%0t ns] STAGE 4 - RX framing error!", $time);
        if (done_rx) begin
            $display("[%0t ns] STAGE 4 - RX byte %2d = %h", $time, rx_cnt, rx_data);
            rx_packet = {rx_packet[135:0], rx_data};
            rx_cnt    = rx_cnt + 1;
        end
    end
 
    // ---- Stimulus ----------------------------------------------------------
    initial begin
        $timeformat(-9, 0, "", 0);        // print %t in plain ns
        rst_n      = 1'b0;
        start      = 1'b0;
        plaintext  = 128'h3243f6a8885a308d313198a2e0370734;
        master_Key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
 
        repeat (5) @(negedge clk);
        rst_n = 1'b1;
 
        // start soon after reset so the first UART byte is baud-aligned
        repeat (5) @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;
 
        wait (tx_done_all);
        repeat (20) @(posedge clk);
 
        $display("\n==================== FINAL RECEIVER OUTPUT ====================");
        $display(" bytes received : %0d (expected 18)", rx_cnt);
        $display(" ciphertext     : %h", rx_packet[143:16]);
        $display(" CRC-16         : %h", rx_packet[15:0]);
        $display(" full packet    : %h", rx_packet);
        $display(" expected (correct AES): 3925841d02dc09fbdc118597196a0b32db05");
        $display("===============================================================");
        $finish;
    end
 
    // watchdog (~21 ms expected)
    initial begin
        #30_000_000;
        $display("TIMEOUT - tx_done_all never asserted");
        $finish;
    end
endmodule