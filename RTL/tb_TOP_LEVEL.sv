module tb_TOP_LEVEL ();
// Parameters
    parameter DATA_WIDTH = 128;
    parameter CRC_WIDTH  = 16;

    // Testbench Signals
    reg  clk;
    reg  rst_n;
    reg  start;
    reg  [127:0] plaintext;
    reg  [127:0] master_key;

    wire [DATA_WIDTH+CRC_WIDTH-1:0] data_out;
    wire done_AES;
    wire done_crc;
    wire busy_crc;	// Parameters

    // Instantiate Top Level Module
    TOP_LEVEL #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .plaintext(plaintext),
        .master_Key(master_key),
        .data_out(data_out),
        .done_AES(done_AES),
        .done_crc(done_crc),
        .busy_crc(busy_crc)
    );


    // clock generation 

   initial begin
   	clk = 0; 
   	forever #10 clk = ~clk; 
   end

  initial begin
        // 1. Initialize Inputs
        //clk        = 0;
        rst_n      = 0;
        start      = 0;
        plaintext  = 128'h0102030405060708090a0b0c0d0e0f00;
        master_key = 128'h00000000000000000000000000000000;

        // 2. Apply Reset
        #20;
        rst_n = 1;
        @(posedge clk);

        // 3. Trigger Start Pulse synchronized with Clock
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        // 4. Wait for CRC Completion
        wait(done_crc);
        $display("\n[SUCCESS] Final Output (Ciphertext + CRC16) : %h", data_out);

        #100;
        $finish;
    end

endmodule
