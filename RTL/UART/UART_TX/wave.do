onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_UART_TX/clk
add wave -noupdate /tb_UART_TX/rst
add wave -noupdate /tb_UART_TX/arst_n
add wave -noupdate /tb_UART_TX/tx_en
add wave -noupdate /tb_UART_TX/data
add wave -noupdate /tb_UART_TX/done
add wave -noupdate /tb_UART_TX/busy
add wave -noupdate /tb_UART_TX/tx
add wave -noupdate -expand -group GEN /tb_UART_TX/dut/gen/tick
add wave -noupdate -expand -group GEN /tb_UART_TX/dut/gen/counter
add wave -noupdate -expand -group GEN /tb_UART_TX/dut/gen/tx_en
add wave -noupdate -expand -group CTRL /tb_UART_TX/dut/CTRL/tx_en
add wave -noupdate -expand -group CTRL /tb_UART_TX/dut/CTRL/tick
add wave -noupdate -expand -group CTRL /tb_UART_TX/dut/CTRL/tx
add wave -noupdate -expand -group CTRL /tb_UART_TX/dut/CTRL/total_frame
add wave -noupdate -expand -group CTRL /tb_UART_TX/dut/CTRL/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82 ns} 0}
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
WaveRestoreZoom {0 ns} {205 ns}
