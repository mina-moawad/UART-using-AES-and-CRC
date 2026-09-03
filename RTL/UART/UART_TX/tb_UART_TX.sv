module tb_UART_TX ();
	reg clk, rst, arst_n;
	reg tx_en;
	reg [7:0] data; 
	wire done, busy, tx; 

TOP_UART_TX dut (clk, rst, arst_n, tx_en, data, done, busy, tx);

// clock generation 
initial begin
	clk = 0;
	forever #10 clk = ~clk;
end

initial begin
	// assert reset 
	rst = 0;
	arst_n = 0;
	data = 8'h44; 
	tx_en = 0; 
	@(negedge clk);

	rst = 0;
	arst_n = 0;
	data = 8'h55; 
	tx_en = 1;
	repeat (3) @(negedge clk);

	arst_n = 1;
	tx_en  = 1;
	data = 8'hA5;
	repeat(4)@(negedge clk);
	tx_en = 0;

	wait (done == 1);

	repeat(12)@(negedge clk);
	
	$display("simulation is finished");
	$stop; 

end

initial begin
	$monitor("Time=%0t, tx=%b, busy=%b, done=%b", $time, tx, busy, done);
end
endmodule : tb_UART_TX