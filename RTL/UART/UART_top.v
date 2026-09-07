module UART_top ( 
    input wire clk,
    input wire rst,
    input wire arst_n,
    
    input wire tx_en,
    input wire rx_en,
    input wire [7:0] tx_data,
    output wire done,
    output wire busy,
      
    // output declaration of module TOP_rx
    output wire [7:0] rx_data,
    output wire done_rx,
    output wire busy_rx,
    output wire err_rx
) ; 

    wire tx;

    // UART Transmitter instance
    TOP_UART_TX u_TOP_UART_TX(
        .clk    	(clk     ),
        .rst    	(rst   ),
        .arst_n 	(arst_n  ),
        .tx_en  	(tx_en   ),
        .data   	(tx_data  ),
        .done   	(done    ),
        .busy   	(busy    ),
        .tx     	(tx      )
    );


    
    TOP_rx u_TOP_rx(
        .clk    	(clk     ),
        .rst    	(rst   ),
        .arst_n 	(arst_n  ),
        .rx_en  	(rx_en   ),
        .rx     	(tx      ),
        .data   	(rx_data  ),
        .done   	(done_rx ),
        .busy   	(busy_rx ),
        .err    	(err_rx  )
    );
    

endmodule