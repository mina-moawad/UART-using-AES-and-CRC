module uart_tx #(
    parameter CLK_FREQ  = 50000000, // Default: 50 MHz
    parameter BAUD_RATE = 9600      // Default: 9600 Baud
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       arst_n,
    input  wire       tx_en,
    input  wire [7:0] data,
    output wire       tx,
    output wire       busy,
    output wire       done
);

    // Inter-Block Interconnect Wires
    wire [9:0] frame;
    wire [3:0] bit_idx;
    wire       baud_tick;
    wire       load_en;
    wire       active;

    // 1. Frame Construct Block
    tx_frame u_tx_frame (
        .clk       (clk),
        .rst       (rst),
        .arst_n    (arst_n),
        .load_en   (load_en),
        .data_in   (data),
        .frame_out (frame)
    );

    // 2. Unified Baud Rate Generator
    baud_rate_generator #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_tx_baud_gen (
        .clk         (clk),
        .rst         (rst),
        .arst_n      (arst_n),
        .load_en     (load_en || baud_tick), // Reload on start and after each bit period
        .is_half_bit (1'b0),                 // Always 0 for TX (1.0 bit time)
        .baud_zero   (baud_tick)             // Replaces tx_baud_counter's baud_tick
    );

    // 3. Bit Select & FSM Controller
    tx_bit_select u_tx_bit_select (
        .clk       (clk),
        .rst       (rst),
        .arst_n    (arst_n),
        .tx_en     (tx_en),
        .baud_tick (baud_tick),
        .load_en   (load_en),
        .bit_idx   (bit_idx),
        .busy      (busy),
        .done      (done),
        .active    (active)
    );

    // 4. Output Multiplexer Block
    tx_mux u_tx_mux (
        .frame_in (frame),
        .bit_idx  (bit_idx),
        .busy     (busy),
        .tx       (tx)
    );

endmodule