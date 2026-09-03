vlib work
vlog baud_counter_generator.sv  tx_controller.sv TOP_UART_TX.sv tb_UART_TX.sv  +cover -covercells
vsim -voptargs=+acc work.tb_UART_TX -cover
coverage save tb_UART_TX.ucdb -onexit
do wave.do
run -all