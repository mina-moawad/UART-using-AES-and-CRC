module uart_rx #(
    parameter CLK_FREQ  = 50000000, // System clock frequency in Hz (e.g., 50 MHz)
    parameter BAUD_RATE = 115200    // Desired Baud Rate
)(
    input  wire       clk,
    input  wire       rst,      
    input  wire       arst_n,   
    input  wire       rx_en,    
    input  wire       rx,       // Serial input line
    output reg  [7:0] data,     // Parallel output data
    output reg        busy,     
    output reg        done,     
    output reg        err       
);
reg [2:0] state_reg, next_state;

localparam
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    ERROR = 3'b011,
    STOP  = 3'b100;



    always @ (posedge clk or negedge rst_n or negedge arst_n) begin
        if (!rst_n || !arst_n) begin
            data <= 8'b0;
            busy <= 1'b0;
            done <= 1'b0;
            err <= 1'b0;
        end else begin
            // UART receiving logic here
            if (rx_en) begin
                
            end
        end
    end
