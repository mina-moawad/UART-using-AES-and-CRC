vlib work
vlog Edge_Detection.sv SIPO.sv rx_baud_counter.sv rx_fsm.sv TOP_rx.sv tb_RX.sv  +cover -covercells
vsim -voptargs=+acc work.tb_RX -cover
coverage save tb_RX.ucdb -onexit
do wave.do
run -all