module TOP_LEVEL #(
    parameter DATA_WIDTH = 128,
    parameter CRC_WIDTH  = 16,
    parameter [CRC_WIDTH:0] POLYNOMIAL = 17'h11021
)(

    input  wire        clk,
    input  wire        rst_n,           // Active-low asynchronous reset
    input  wire        start,           // Trigger AES encryption
    input  wire [127:0] plaintext,
    input  wire [127:0] master_Key,


    // AES & CRC Status Flags
    output wire        done_AES,
    output wire        busy_crc,
    output wire        done_crc,

    // System Transmission Status Flags
    output wire        tx_busy_all,     // System is currently transmitting over UART
    output wire        tx_done_all,     // All 18 bytes have been transmitted

    // UART Receiver Interface (from UART_top)
    output wire [7:0]  rx_data,
    output wire        done_rx,
    output wire        busy_rx,
    output wire        err_rx
);


    // Internal Wires & Connections

    wire [127:0] ciphertext;
    wire [DATA_WIDTH+CRC_WIDTH-1:0] data_with_crc; // 144 bits (128 data + 16 CRC)

    wire [7:0]  tx_data_byte;
    wire        tx_en_byte;
    wire        uart_done;
    wire        uart_busy;

    // Convert active-low top reset to active-high reset for UART
    wire rst_high;
    assign rst_high = ~rst_n;

 
    AES_FSM D1 (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .master_Key (master_Key),
        .ciphertext (ciphertext),
        .done_AES   (done_AES)
    );

    CRC #(
        .DATA_WIDTH (DATA_WIDTH),
        .CRC_WIDTH  (CRC_WIDTH),
        .POLYNOMIAL (POLYNOMIAL)
    ) D2 (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (done_AES),      // Starts CRC calculation when AES finishes
        .data_in       (ciphertext),
        .data_with_crc (data_with_crc),
        .done          (done_crc),
        .busy          (busy_crc)
    );

    CRC_to_UART_Serializer #(
        .PACKET_WIDTH (DATA_WIDTH + CRC_WIDTH),      // 144 bits
        .NUM_BYTES    ((DATA_WIDTH + CRC_WIDTH) / 8) // 18 bytes
    ) u_serializer (
        .clk                (clk),
        .rst_n              (rst_n),
        .crc_done           (done_crc),
        .crc_data_with_crc  (data_with_crc),
        .uart_done          (uart_done),
        .uart_busy          (uart_busy),
        .tx_data            (tx_data_byte),
        .tx_en              (tx_en_byte),
        .serializer_busy    (tx_busy_all),
        .serializer_done    (tx_done_all)
    );

    UART_top u_UART_top (
        .clk     (clk),
        .rst     (rst_high),            
        .arst_n  (rst_n),               
        .tx_en   (tx_en_byte),          
        .rx_en   (1'b1),                
        .tx_data (tx_data_byte),        
        .done    (uart_done),           
        .busy    (uart_busy),           
        .rx_data (rx_data),
        .done_rx (done_rx),
        .busy_rx (busy_rx),
        .err_rx  (err_rx)
    );

endmodule