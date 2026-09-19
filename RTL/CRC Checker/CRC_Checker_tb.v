module CRC_Checker_tb;

    parameter DATA_WIDTH = 128;
    parameter CRC_WIDTH  = 16;

    
    reg clk;
    reg rst_n;
    reg start;

    reg [DATA_WIDTH+CRC_WIDTH-1:0] received_data;

    wire [DATA_WIDTH-1:0] data_out;
    wire error;
    wire accept;
    wire done;
    wire busy;


    CRC_Checker #(
        .DATA_WIDTH(DATA_WIDTH),
        .CRC_WIDTH(CRC_WIDTH),
        .POLYNOMIAL(17'h11021)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .received_data(received_data),

        .data_out(data_out),
        .error(error),
        .accept(accept),
        .done(done),
        .busy(busy)
    );

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end



    initial begin

        rst_n         = 1'b0;
        start         = 1'b0;
        received_data = 144'b0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #20;

        rst_n = 1'b1;

        #10;


        // ========================================================
        // TEST 1
        // Correct DATA + Correct CRC
        // Expected: ACCEPT
        // ========================================================

        $display("==============================================");
        $display("TEST 1: Correct DATA + Correct CRC");
        received_data =
            144'h0000000000000031323334353637383931C3;

        start = 1'b1;

        @(posedge clk);

        start = 1'b0;
        @(posedge done);
        #1;

        $display("Received Data = %h", received_data);
        $display("Output Data   = %h", data_out);
        $display("Error         = %b", error);
        $display("Accept        = %b", accept);

        if ((error == 1'b0) && (accept == 1'b1)) begin
            $display("TEST 1 PASSED");
        end
        else begin
            $display("TEST 1 FAILED");
        end

        $display("----------------------------------------------");


        // ========================================================
        // TEST 2
        // Corrupted DATA + Original CRC
        // Expected: ERROR
        // ========================================================
        $display("TEST 2: Corrupted DATA + Original CRC");
        // One bit of DATA is changed
        @(negedge clk);
        received_data =
            144'h2000000000000031323334353637383931C3;

        start = 1'b1;

        @(negedge clk);

        start = 1'b0;

        @(posedge done);

        #1;

        $display("Received Data = %h", received_data);
        $display("Output Data   = %h", data_out);
        $display("Error         = %b", error);
        $display("Accept        = %b", accept);


        if ((error == 1'b1) && (accept == 1'b0)) begin
            $display("TEST 2 PASSED");
        end
        else begin
            $display("TEST 2 FAILED");
        end

        $display("----------------------------------------------");


        // ========================================================
        // TEST 3
        // Correct DATA + Corrupted CRC
        // Expected: ERROR
        // ========================================================
        $display("TEST 3: Correct DATA + Corrupted CRC");

        @(negedge clk);
        received_data =
            144'h0000000000000031323334353637383931C2;

        start = 1'b1;

        @(negedge clk);

        start = 1'b0;

        @(posedge done);

        #1;

        $display("Received Data = %h", received_data);
        $display("Output Data   = %h", data_out);
        $display("Error         = %b", error);
        $display("Accept        = %b", accept);


        if ((error == 1'b1) && (accept == 1'b0)) begin
            $display("TEST 3 PASSED");
        end
        else begin
            $display("TEST 3 FAILED");
        end

        $display("----------------------------------------------");


        // ========================================================
        // TEST 4
        // Corrupted DATA + Corrupted CRC
        // Expected: ERROR
        // ========================================================
        $display("TEST 4: Corrupted DATA + Corrupted CRC");
        @(negedge clk);
        received_data =
            144'h2000000000000031323334353637383931C2;

        start = 1'b1;

        @(negedge clk);

        start = 1'b0;

        @(posedge done);

        #1;

        $display("Received Data = %h", received_data);
        $display("Output Data   = %h", data_out);
        $display("Error         = %b", error);
        $display("Accept        = %b", accept);


        if ((error == 1'b1) && (accept == 1'b0)) begin
            $display("TEST 4 PASSED");
        end
        else begin
            $display("TEST 4 FAILED");
        end

        $display("----------------------------------------------");

        $finish;

    end

endmodule