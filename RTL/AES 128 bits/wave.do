onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_AES_FSM/clk
add wave -noupdate /tb_AES_FSM/rst_n
add wave -noupdate /tb_AES_FSM/start
add wave -noupdate /tb_AES_FSM/plaintext
add wave -noupdate /tb_AES_FSM/master_key
add wave -noupdate /tb_AES_FSM/ciphertext
add wave -noupdate /tb_AES_FSM/done
add wave -noupdate -expand -group Sub_init /tb_AES_FSM/dut/Sub_init/in
add wave -noupdate -expand -group Sub_init /tb_AES_FSM/dut/Sub_init/out
add wave -noupdate -expand -group SHIFT_ROW /tb_AES_FSM/dut/SHIFT_ROW/data_in
add wave -noupdate -expand -group SHIFT_ROW /tb_AES_FSM/dut/SHIFT_ROW/data_out
add wave -noupdate -expand -group MIX_COL /tb_AES_FSM/dut/mix/state_in
add wave -noupdate -expand -group MIX_COL /tb_AES_FSM/dut/mix/state_out
add wave -noupdate -expand -group KEY_EXpansion /tb_AES_FSM/dut/key/key
add wave -noupdate -expand -group KEY_EXpansion /tb_AES_FSM/dut/key/round
add wave -noupdate -expand -group KEY_EXpansion /tb_AES_FSM/dut/key/round_key
add wave -noupdate -expand -group ROUND_KEY /tb_AES_FSM/dut/addkey/state
add wave -noupdate -expand -group ROUND_KEY /tb_AES_FSM/dut/addkey/round_key
add wave -noupdate -expand -group ROUND_KEY /tb_AES_FSM/dut/addkey/new_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {77 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {24 ns} {357 ns}
