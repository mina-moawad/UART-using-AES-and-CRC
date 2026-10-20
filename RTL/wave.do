onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_TOP_LEVELv2/clk
add wave -noupdate /tb_TOP_LEVELv2/rst_n
add wave -noupdate /tb_TOP_LEVELv2/start
add wave -noupdate -expand -group IN -color Cyan /tb_TOP_LEVELv2/plaintext
add wave -noupdate -expand -group IN -color Cyan /tb_TOP_LEVELv2/master_Key
add wave -noupdate /tb_TOP_LEVELv2/done_AES
add wave -noupdate /tb_TOP_LEVELv2/busy_crc
add wave -noupdate /tb_TOP_LEVELv2/done_crc
add wave -noupdate /tb_TOP_LEVELv2/tx_busy_all
add wave -noupdate /tb_TOP_LEVELv2/tx_done_all
add wave -noupdate -expand -group RX /tb_TOP_LEVELv2/rx_data
add wave -noupdate -expand -group RX /tb_TOP_LEVELv2/done_rx
add wave -noupdate -expand -group RX /tb_TOP_LEVELv2/busy_rx
add wave -noupdate -expand -group RX /tb_TOP_LEVELv2/err_rx
add wave -noupdate -expand -group RX -color Khaki /tb_TOP_LEVELv2/rx_cnt
add wave -noupdate -expand -group RX -color Magenta /tb_TOP_LEVELv2/rx_packet
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {645 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {3258 ps}
