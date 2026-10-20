module tx_controller_v2 (
    input clk,
    rst,
    arst_n,
    input tx_en,
    tick,
    input [7:0] data,
    output reg done,
    busy,
    tx
);

  parameter IDLE = 0;
  parameter SYNC = 1;  // NEW: wait for the next baud tick so the start bit is a full bit long
  parameter ON = 2;

  reg [9:0] total_frame;
  reg [3:0] i = 0;  // counter to counter number of frame bits
  reg [1:0] cs;

  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      cs <= IDLE;
      tx <= 1;  // line idealy high
      done <= 0;
      i <= 0;
      total_frame <= 10'b1111111111;  // line stays in logic 1 between frames
      busy <= 0;
    end else if (rst) begin
      cs <= IDLE;
      tx <= 1;
      done <= 0;
      i <= 0;
      total_frame <= 10'b1111111111;
      busy <= 0;
    end else begin  // start checking on the cases
      done <= 0;  // by default low 

      // check on cs 
      case (cs)
        IDLE: begin
          tx <= 1;
          i  <= 0;
          if (tx_en) begin
            total_frame <= {1'b1, data, 1'b0};  // stop bit (1), data [7:0] , start bit (0)
            busy        <= 1;
            cs          <= SYNC;  // NEW: was cs<=ON
          end else begin
            busy <= 0;
            total_frame <= 10'b1111111111;
            cs <= IDLE;
          end
        end

        // NEW: hold the line high until the next baud tick, then start the frame.
        // The baud generator free-runs, so without this the start bit could be
        // shorter than one bit period and the receiver would sample the wrong bit.
        SYNC: begin
          busy <= 1;
          tx   <= 1;
          if (tick) cs <= ON;
        end

        ON: begin
          busy <= 1;
          tx   <= total_frame[i];
          if (tick) begin
            if (i == 9) begin
              i    <= 0;
              busy <= 0;
              done <= 1;
              cs   <= IDLE;  // NEW: return to IDLE after the stop bit
            end else i <= i + 1;
          end
        end

        default: cs <= IDLE;
      endcase  // cs

    end
  end
endmodule
