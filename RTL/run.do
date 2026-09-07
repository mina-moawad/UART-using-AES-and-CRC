vlib work

# 1. Compile AES Sub-modules (داخل مجلد AES 128 bits)
vlog "./AES 128 bits/Add round Key/Add_Round_Key.sv"
vlog "./AES 128 bits/AES_mix_column/mix_single_column.v" "./AES 128 bits/AES_mix_column/AES_mix_columns.v"
vlog "./AES 128 bits/Key Expansion/Key_Expansion.v"
vlog "./AES 128 bits/S_box and Sub_Bytes/sbox.v" "./AES 128 bits/S_box and Sub_Bytes/subBytes.v"
vlog "./AES 128 bits/Shift row/AES_Shift_Row.sv"
vlog "./AES 128 bits/AES controller fsm/AES_FSM.sv"

# 2. Compile CRC
vlog "./CRC/CRC.v"

# 3. Compile Top Module & Testbench
vlog "./TOP_LEVEL.sv"
vlog "./tb_TOP_LEVEL.sv" +cover -covercells

# 4. Simulate Testbench
vsim -voptargs=+acc work.tb_TOP_LEVEL -cover

# 5. Add Signals to Waveform
add wave -position insertpoint sim:/tb_TOP_LEVEL/*

# 6. Save Coverage & Run
coverage save tb_TOP_LEVEL.ucdb -onexit
run -all