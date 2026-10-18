`timescale 1ns / 1ps

module tb_CRC_to_UART;

    // Parameters
    parameter PACKET_WIDTH = 144;
    parameter NUM_BYTES    = 18;
    parameter CLK_PERIOD   = 10; // 100 MHz clock

    // Inputs to UUT
    reg                    clk;
    reg                    rst_n;
    reg                    crc_done;
    reg [PACKET_WIDTH-1:0] crc_data_with_crc;
    reg                    uart_done;
    reg                    uart_busy;

    // Outputs from UUT
    wire [7:0]             tx_data;
    wire                   tx_en;
    wire                   serializer_busy;
    wire                   serializer_done;

   
    integer i;
    integer error_count = 0;
    reg [7:0] expected_byte;

    // Instantiate Unit Under Test (UUT)
    CRC_to_UART #(
        .PACKET_WIDTH(PACKET_WIDTH),
        .NUM_BYTES(NUM_BYTES)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .crc_done(crc_done),
        .crc_data_with_crc(crc_data_with_crc),
        .uart_done(uart_done),
        .uart_busy(uart_busy),
        .tx_data(tx_data),
        .tx_en(tx_en),
        .serializer_busy(serializer_busy),
        .serializer_done(serializer_done)
    );

    // 1. Clock Generation Block
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 2. Main Stimulus & Handshake Control Block
    initial begin
        // Initialize signals
        rst_n             = 1'b0;
        crc_done          = 1'b0;
        uart_done         = 1'b0;
        uart_busy         = 1'b0;
        crc_data_with_crc = 144'h99114423104580546006193429178388264758221;

        $display("\n--- STARTING CRC_to_UART_Serializer TESTBENCH ---");

        // Apply Reset
        #(CLK_PERIOD * 2);
        rst_n = 1'b1;
        #(CLK_PERIOD * 2);

        // Trigger Transmission with crc_done pulse
        @(posedge clk);
        crc_done = 1'b1;
        @(posedge clk);
        crc_done = 1'b0;

        // Loop through all 18 bytes and emulate UART handshake
        for (i = 0; i < NUM_BYTES; i = i + 1) begin
            
            // Wait for serializer to assert tx_en
            wait (tx_en == 1'b1);

            // Extract expected byte from packet MSB to LSB
            expected_byte = crc_data_with_crc[(PACKET_WIDTH - 1 - (i * 8)) -: 8];

            // Verify serializer tx_data output
            if (tx_data === expected_byte) begin
                $display("[TIME %0t ps] PASS: Byte [%0d] = 0x%h (Matches Expected: 0x%h)", 
                         $time, i, tx_data, expected_byte);
            end else begin
                $display("[TIME %0t ps] ERROR: Byte [%0d] = 0x%h (EXPECTED: 0x%h)", 
                         $time, i, tx_data, expected_byte);
                error_count = error_count + 1;
            end

            // Simulate UART delay (3 clock cycles per byte transfer)
            repeat (3) @(posedge clk);

            // Pulse uart_done for 1 clock cycle
            uart_done = 1'b1;
            @(posedge clk);
            uart_done = 1'b0;
        end

        // Wait for serializer completion flag
        wait (serializer_done == 1'b1);
        
        #(CLK_PERIOD * 2);

        // Final Verification Summary
        $display("------------------------------------------------");
        if (error_count == 0) begin
            $display(">>> TEST PASSED SUCCESSFULLY: All %0d bytes verified! <<<", NUM_BYTES);
        end else begin
            $display(">>> TEST FAILED: %0d byte mismatches detected! <<<", error_count);
        end
        $display("------------------------------------------------\n");

        $finish;
    end

endmodule