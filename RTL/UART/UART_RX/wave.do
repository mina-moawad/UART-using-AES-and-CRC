onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_RX/clk
add wave -noupdate /tb_RX/rst
add wave -noupdate /tb_RX/arst_n
add wave -noupdate /tb_RX/rx_en
add wave -noupdate -color Gold /tb_RX/rx
add wave -noupdate /tb_RX/data
add wave -noupdate /tb_RX/done
add wave -noupdate /tb_RX/busy
add wave -noupdate /tb_RX/err
add wave -noupdate -expand -group {Edge Detection} /tb_RX/dut/EDGE/rx
add wave -noupdate -expand -group {Edge Detection} /tb_RX/dut/EDGE/falling_edge
add wave -noupdate -expand -group SLL /tb_RX/dut/SLL/rx
add wave -noupdate -expand -group SLL /tb_RX/dut/SLL/en_shift
add wave -noupdate -expand -group SLL /tb_RX/dut/SLL/data
add wave -noupdate -expand -group {baud counter} /tb_RX/dut/CNT/finish
add wave -noupdate -expand -group {baud counter} /tb_RX/dut/CNT/counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {188 ns} 0}
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
WaveRestoreZoom {0 ns} {753 ns}
