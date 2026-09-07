`timescale 1ns / 1ps

module tb_UART_top();

    // 50 MHz clock period (20 ns)
    parameter CLK_PERIOD = 20;

    // DUT Signals (In Verilog, drive inputs with reg, outputs with wire)
    reg        clk;
    reg        rst;
    reg        arst_n;
    reg        tx_en;
    reg        rx_en;
    reg  [7:0] tx_data;

    wire       done;
    wire       busy;
    wire [7:0] rx_data;
    wire       done_rx;
    wire       busy_rx;
    wire       err_rx;

    // Instantiate DUT
    UART_top dut (
        .clk     (clk    ),
        .rst     (rst    ),
        .arst_n  (arst_n ),
        .tx_en   (tx_en  ),
        .rx_en   (rx_en  ),
        .tx_data (tx_data),
        .done    (done   ),
        .busy    (busy   ),
        .rx_data (rx_data),
        .done_rx (done_rx),
        .busy_rx (busy_rx),
        .err_rx  (err_rx )
    );

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Stimulus
    initial begin
        // Waveform dump setup
        // $dumpfile("dump.vcd");
        // $dumpvars(0, tb_UART_top);

        // 1. Initial State & Apply Resets
        tx_en   = 1'b0;
        rx_en   = 1'b0;
        tx_data = 8'h00;
        arst_n  = 1'b0; // Active-low async reset
        rst     = 1'b1; // Active-high sync reset

        #(CLK_PERIOD * 5);
        arst_n  = 1'b1; // De-assert async reset

        #(CLK_PERIOD * 5);
        @(posedge clk);
        rst     = 1'b0; // De-assert sync reset
        @(posedge clk);

        // 2. Prepare Data & Enable RX
        tx_data = 8'hA5; // Data byte to test
        rx_en   = 1'b1;  // RX must be active to capture start bit
        @(posedge clk);

        // 3. Trigger Transmission (1 clock pulse)
        tx_en   = 1'b1;
        @(posedge clk);
        tx_en   = 1'b0;

        // 4. Wait for Receive Completion
        @(posedge done_rx);

        // 5. Verify Output
        #(CLK_PERIOD);
        if (err_rx) begin
            $display("[FAIL] Reception Error Flag Asserted!");
        end else if (rx_data === 8'hA5) begin
            $display("[PASS] Received Expected Data: 0x%0h", rx_data);
        end else begin
            $display("[FAIL] Data Mismatch! Expected: 0xA5, Got: 0x%0h", rx_data);
        end

        $finish;
    end

endmodule