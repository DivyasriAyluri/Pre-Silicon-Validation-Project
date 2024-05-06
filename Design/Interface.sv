interface Asynch_fifo_interface #(parameter D_SIZE=8, A_SIZE =8);
	logic [D_SIZE-1:0] w_data;
	logic w_inc;
	logic w_clk;
	logic w_rst;
	logic [D_SIZE-1:0] r_data;
	logic r_inc;
	logic r_clk;
	logic r_rst;
	logic w_full;
	logic r_empty;
	logic w_half_full;
	logic r_half_empty;

modport master (
	input w_clk, w_rst,
	output w_data, w_inc, w_full,w_half_full,
	input r_clk, r_rst,
	output r_data, r_inc, r_empty,r_half_empty);
endinterface

