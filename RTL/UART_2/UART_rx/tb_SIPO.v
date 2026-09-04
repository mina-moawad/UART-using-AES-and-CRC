`timescale 1ns / 1ps

module tb_SIPO();


    reg clk;
    reg rst_n;
    reg rx;
    reg sipo_en;
    reg clr_cnt;

    wire [7:0] data_out;
    wire [2:0] bit_cnt;


    SIPO uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx       (rx),
        .sipo_en  (sipo_en),
        .clr_cnt  (clr_cnt),
        .data_out (data_out),
        .bit_cnt  (bit_cnt)
    );

   
    always #10 clk = ~clk;

   
    reg [7:0] test_pattern = 8'b10110010;
    integer i;

    initial begin
        // Initialize signals
        clk     = 0;
        rst_n   = 0;
        rx      = 1;
        sipo_en = 0;
        clr_cnt = 0;

        // Apply Reset
        #20 rst_n = 1;
        #20;

        $display("\n--- Starting SIPO Shift Test ---");
        $display("Input Pattern to Shift (LSB First): 8'b10110010 (0xB2)");

        // Shift 8 bits into the SIPO LSB-first
        for (i = 0; i < 8; i = i + 1) begin
            rx = test_pattern[i]; 
            
           
            @(posedge clk);
            sipo_en = 1'b1;
            
            @(posedge clk);
            sipo_en = 1'b0;

            #20;
            $display("Bit %0d shifted (%b) | Current Parallel Out: 8'b%b", i, rx, data_out);
        end

        // Final Output Verification
        #20;
        $display("\n--- Test Result ---");
        if (data_out === test_pattern) begin
            $display("SUCCESS: Parallel output matches input! data_out = 8'b%b (0x%h)", data_out, data_out);
        end else begin
            $display("ERROR: Shift failed. Expected 8'b%b, got 8'b%b", test_pattern, data_out);
        end

        $finish;
    end

endmodule