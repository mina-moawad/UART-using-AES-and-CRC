vlib work

# 1. Compile AES Sub-modules (AES 128 bits)
vlog "./AES 128 bits/Add round Key/Add_Round_Key.sv"
vlog "./AES 128 bits/AES_mix_column/mix_single_column.v" "./AES 128 bits/AES_mix_column/AES_mix_columns.v"
vlog "./AES 128 bits/Key Expansion/Key_Expansion.v"
vlog "./AES 128 bits/S_box and Sub_Bytes/sbox.v" "./AES 128 bits/S_box and Sub_Bytes/subBytes.v"
vlog "./AES 128 bits/Shift row/AES_Shift_Row.sv"
vlog "./AES 128 bits/AES controller fsm/AES_FSM.sv"

# 2. Compile CRC
vlog "./CRC/CRC.v"

# 3. compile CRC 2 Uart
vlog "./CRC 2 UART SER/CRC_to_UART.v"

# 4. compile UART TX and RX.
vlog "./UART/UART_RX/Edge_Detection.sv" "./UART/UART_RX/rx_baud_counter.sv" "./UART/UART_RX/rx_fsm.sv" "./UART/UART_RX/SIPO.sv" "./UART/UART_RX/TOP_rx.sv"

vlog "./UART/UART_TX/baud_counter_generator.sv" "./UART/UART_TX/tx_controller.sv" "./UART/UART_TX/TOP_UART_TX.sv" "./UART/UART_top.v"

# 5. Compile Top Module & Testbench
vlog "./TOP LEVEL DESIGN/TOP_LEVEL_v2.v"
vlog "./TOP LEVEL DESIGN/tb_TOP_LEVEL_v2.v" +cover -covercells

# 6. Simulate Testbench
vsim -voptargs=+acc work.tb_TOP_LEVEL_v2 -cover

# 7. Add Signals to Waveform
add wave -position insertpoint sim:/tb_TOP_LEVEL_v2/*

# 8. Save Coverage & Run
coverage save tb_TOP_LEVEL_v2.ucdb -onexit
run -all