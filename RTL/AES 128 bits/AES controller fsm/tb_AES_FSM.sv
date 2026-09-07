module tb_AES_FSM ();
    reg clk, rst_n, start;
    reg [127:0] plaintext, master_key;
    wire [127:0] ciphertext; 
    wire done;

// Named Port Mapping
AES_FSM dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .plaintext(plaintext),
    .master_key(master_key),
    .ciphertext(ciphertext),
    .done(done)
);

// Clock generation (50 MHz)
initial begin
    clk = 0;
    forever #10 clk = ~clk; 
end

initial begin
    // Reset Phase
    rst_n = 0;
    start = 0;
    plaintext = 0; 
    master_key = 0;
    
    repeat(2) @(posedge clk);
    #1; // Delay small time to avoid race condition with clock
    rst_n = 1; 
    
    @(posedge clk);
    #1;
    // Assign inputs safely before assertion of start
    plaintext  <= 128'h00000000_00000000_00000000_00000000;
    master_key <= 128'h00000000_00000000_00000000_00000000;

    @(posedge clk);
    #1;
    start <= 1; 

    @(posedge clk);
    #1;
    start <= 0;

    wait (done);
    #10;

    // Display Result
    $display("\n==================================================");
    $display("   AES-128 Test Result");
    $display("==================================================");
    $display(" Plaintext  : %h", plaintext);
    $display(" Master Key : %h", master_key);
    $display(" Ciphertext : %h", ciphertext);
        
    // if (ciphertext == 128'h3ad77bb40d7a3660a89ecaf32466ef97) begin
    //     $display(" STATUS     : SUCCESS!");
    // end else begin
    //     $display(" STATUS     : FAILED!");
    // end
    // $display("==================================================\n");

    #20;
    $finish;
end

initial begin
    $monitor("Time=%0t, start=%b, plaintext=%h, master_key=%h, ciphertext=%h", $time, start, plaintext, master_key, ciphertext);
end

endmodule : tb_AES_FSM