`timescale 1ns / 1ps

module tb_CRC_to_UART();


    parameter CLK_PERIOD   = 10;   // 100 MHz Clock
    parameter PACKET_WIDTH = 144;
    parameter NUM_BYTES    = 18;

    reg                     clk;
    reg                     rst_n;
    reg                     crc_done;
    reg  [PACKET_WIDTH-1:0] crc_data_with_crc;
    reg                     uart_done;
    reg                     uart_busy;

    wire [7:0]              tx_data;
    wire                    tx_en;
    wire                    serializer_busy;
    wire                    serializer_done;

    // Test tracking variables
    integer i;
    reg [PACKET_WIDTH-1:0] expected_packet;
    reg [7:0]              expected_byte;
    integer                error_count;


    CRC_to_UART_Serializer #(
        .PACKET_WIDTH (PACKET_WIDTH),
        .NUM_BYTES    (NUM_BYTES)
    ) uut (
        .clk                (clk),
        .rst_n              (rst_n),
        .crc_done           (crc_done),
        .crc_data_with_crc  (crc_data_with_crc),
        .uart_done          (uart_done),
        .uart_busy          (uart_busy),
        .tx_data            (tx_data),
        .tx_en              (tx_en),
        .serializer_busy    (serializer_busy),
        .serializer_done    (serializer_done)
    );

  
    always #(CLK_PERIOD / 2) clk = ~clk;

  
    // Test Sequence
    initial begin
     
        clk               = 0;
        rst_n             = 0;
        crc_done          = 0;
        crc_data_with_crc = 144'h0;
        uart_done         = 0;
        uart_busy         = 0;
        error_count       = 0;

        // 144-bit test data: 128-bit Ciphertext + 16-bit CRC (0x1234...FEDC + 0xABCD)
        expected_packet   = 144'h0123456789ABCDEF0123456789ABCDEFABCD;


        // 1. Reset Pulse
        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD * 2);

        // 2. Trigger Serializer with crc_done pulse
        @(posedge clk);
        crc_data_with_crc <= expected_packet;
        crc_done          <= 1'b1;
        
        @(posedge clk);
        crc_done          <= 1'b0; 

        // 3. Emulate UART Transmit Loop for 18 Bytes
        for (i = 0; i < NUM_BYTES; i = i + 1) begin
            // Wait for serializer to present byte and pulse tx_en
            wait (tx_en == 1'b1);
            
            // Extract expected byte (MSB first)
            expected_byte = expected_packet[(PACKET_WIDTH - 1 - (i * 8)) -: 8];

            // Verify tx_data matches expected byte
            if (tx_data !== expected_byte) begin
                $display("[ERROR] Byte %0d Mismatch! Expected: 0x%h, Got: 0x%h", i, expected_byte, tx_data);
                error_count = error_count + 1;
            end else begin
                $display("[PASS]  Byte %0d Transmitted Correctly: 0x%h", i, tx_data);
            end

            // Emulate UART busy period (e.g., UART taking 3 clock cycles to send)
            @(posedge clk);
            uart_busy <= 1'b1;
            #(CLK_PERIOD * 3);
            
            // Pulse uart_done to notify serializer
            uart_busy <= 1'b0;
            uart_done <= 1'b1;
            @(posedge clk);
            uart_done <= 1'b0;
        end

        // 4. Verify Final Completion Handshake
        wait (serializer_done == 1'b1);
        @(posedge clk);

        $display("---------------------------------------------------------");
        if (error_count == 0 && serializer_busy == 1'b0) begin
            $display("SIMULATION SUCCESS: All 18 bytes serialized successfully!");
        end else begin
            $display("SIMULATION FAILED with %0d errors.", error_count);
        end
        $display("---------------------------------------------------------");

        $finish;
    end

endmodule