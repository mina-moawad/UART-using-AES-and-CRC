vlib work

# 1. Compile all design sub-modules using their relative folder paths
vlog "./Add round Key/Add_Round_Key.sv"
vlog "./AES_mix_column/mix_single_column.v" "./AES_mix_column/AES_mix_columns.v"
vlog "./Key Expansion/Key_Expansion.v"
vlog "./S_box and Sub_Bytes/sbox.v" "./S_box and Sub_Bytes/subBytes.v"
vlog "./Shift row/AES_Shift_Row.sv"

# 2. Compile Top Module and Testbench
vlog "./AES controller fsm/AES_FSM.sv" "./AES controller fsm/tb_AES_FSM.sv" +cover -covercells

# 3. Simulate Testbench
vsim -voptargs=+acc work.tb_AES_FSM -cover

# 4. Waveform & Coverage setup
add wave -position insertpoint sim:/tb_AES_FSM/*
coverage save tb_AES_FSM.ucdb -onexit
run -all