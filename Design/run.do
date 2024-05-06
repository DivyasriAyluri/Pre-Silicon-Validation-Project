vlib work
vlog async_fifo1.sv
#vlog async_fifo1_tb.sv
#vsim -c -voptargs=+acc -sv_seed random async_fifo1_tb -do "run -all;"
vlog testbench.sv
vsim -c -voptargs=+acc -sv_seed random async_fifo1_tb_uvm -do "run -all;"
