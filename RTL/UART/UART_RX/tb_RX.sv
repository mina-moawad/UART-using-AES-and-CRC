module tb_RX ();

	reg clk, rst, arst_n, rx_en, rx;
	wire [7:0] data;
	wire done, busy, err;

	parameter BIT_TIME = 5208 * 20;

TOP_rx dut (clk, rst, arst_n, rx_en, rx, data, done, busy, err);

// clock generation
initial begin
	clk = 0; 
	forever #10 clk = ~clk;
end	

initial begin
	arst_n = 0; 
	rst = 0; 
	rx_en = 0; 
	rx = 1; 
	repeat(3)@(negedge clk);


	arst_n = 1;
	rx_en  = 1; 
	repeat(6)@(negedge clk);

	$display("Starting reception for data 8'hA5 = 8'b10100101");
	send_byte(8'hA5);
	wait (done || err);

//	$stop; 
	if (done && data == 8'hA5)
            $display("[%0t] SUCCESS: Received correct data 8'h%h", $time, data);
        else
            $display("[%0t] ERROR: Test failed! data = 8'h%h, err = %b", $time, data, err);

        #BIT_TIME;
        $finish;
end

initial begin
	$monitor("Time=%0t, rx=%b, data=%b, busy=%b, done=%b, err=%b", $time, rx, data, busy, done, err);
end

task send_byte (input [7:0] tx_Data);
	integer i;
	begin
		rx = 0; // Start bit
		#BIT_TIME;

		for (i = 0; i < 8; i = i + 1) begin
			rx = tx_Data [i];
			#BIT_TIME;
		end
		rx = 1; // end bit 
	//	#BIT_TIME;
	end
endtask : send_byte
endmodule : tb_RX

