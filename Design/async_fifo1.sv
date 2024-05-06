
module async_fifo1 #(parameter D_SIZE = 8, A_SIZE = 8) (
 Asynch_fifo_interface.master bus
);
  logic [A_SIZE-1:0] w_addr, r_addr;
  logic [A_SIZE:0] w_ptr, r_ptr, w2r_ptr, r2w_ptr;

  fifo_mem #(D_SIZE, A_SIZE) fifomem_1(bus.w_inc,bus.w_full,bus.w_clk,w_addr,r_addr,bus.w_data,bus.r_data);
  rptr_empty #(A_SIZE) rptr_empty_1(bus.r_inc,bus.r_clk,bus.r_rst,r2w_ptr,bus.r_empty,r_addr,r_ptr);
  sync_r2w #(A_SIZE) sync_r2w_1(bus.w_clk,bus.w_rst,r_ptr,w2r_ptr);
  sync_w2r #(A_SIZE) sync_w2r_1(bus.r_clk,bus.r_rst, w_ptr,r2w_ptr);
  wptr_full #(A_SIZE) wptr_full_1(bus.w_inc,bus.w_clk,bus.w_rst,w2r_ptr,bus.w_full,w_addr,w_ptr);
  half_full #(A_SIZE) half_full_1(r_ptr, w_half_full,w_ptr);
  half_empty #(A_SIZE) half_empty_1(r_ptr,w_half_empty,w_ptr);
endmodule

// FIFO

module fifo_mem #(parameter D_SIZE =8, A_SIZE =8) (
	input logic w_inc,w_full,w_clk,
	input logic [A_SIZE-1:0] w_addr,r_addr,
	input logic [D_SIZE-1:0] w_data,
	output logic [D_SIZE-1:0] r_data);
  // RTL Verilog memory model
  localparam DEPTH = 333;//2*addsize
  logic  [A_SIZE-1:0] a, b;
  logic [D_SIZE-1:0] mem [0:DEPTH-1];

  always_comb begin
   r_data = mem[r_addr];
  end


  always_ff @(posedge w_clk)
    if (w_inc && !w_full)
      mem[w_addr] <= w_data;

endmodule

// Read pointer

module rptr_empty
#(
  parameter A_SIZE = 8
)
(
  input logic  r_inc, r_clk, r_rst,
  input logic  [A_SIZE :0] r2w_ptr,
  output logic r_empty,
  output logic [A_SIZE-1:0] r_addr,
  output logic [A_SIZE :0] r_ptr
);

  logic [A_SIZE:0] r_bin;
  logic [A_SIZE:0] r_graynext, r_binnext;

  always_ff @(posedge r_clk or negedge r_rst)
    if (!r_rst)
      {r_bin, r_ptr} <= '0;
    else
      {r_bin, r_ptr} <= {r_binnext, r_graynext};

  // Memory read-address pointer (okay to use binary to address memory)
  always_comb begin
  	r_addr = r_bin[A_SIZE-1:0];
  	r_binnext = r_bin + (r_inc & ~r_empty);
  	r_graynext = (r_binnext>>1) ^ r_binnext;
  end

     assign r_empty_val = (r_graynext == r2w_ptr);

  always_ff @(posedge r_clk or negedge r_rst)
    if (!r_rst)
      r_empty <= 1'b1;
    else
      r_empty <= r_empty_val;

endmodule

//Read to write synchronizer
module sync_r2w
#(
  parameter A_SIZE = 8
)
(
  input logic   w_clk, w_rst,
  input logic  [A_SIZE:0] r_ptr,
  output logic [A_SIZE:0] w2r_ptr//readpointer with write side
);

  logic [A_SIZE:0] wq1_rptr;

  always_ff @(posedge w_clk or negedge w_rst)
    if (!w_rst) {w2r_ptr,wq1_rptr} <= 0;
    else {w2r_ptr,wq1_rptr} <= {wq1_rptr,r_ptr};

endmodule

//write to read synchronizer
module sync_w2r
#(
  parameter A_SIZE = 8
)
(
  input logic  r_clk, r_rst,
  input logic  [A_SIZE:0] w_ptr,
  output logic[A_SIZE:0] r2w_ptr
);

  logic [A_SIZE:0] rq1_wptr;

  always_ff @(posedge r_clk or negedge r_rst)
    if (!r_rst)
      {r2w_ptr,rq1_wptr} <= 0;
    else
      {r2w_ptr,rq1_wptr} <= {rq1_wptr,w_ptr};

endmodule

//Write pointer
module wptr_full
#(
  parameter A_SIZE = 8
)
(
  input logic  w_inc, w_clk, w_rst,
  input logic  [A_SIZE :0] w2r_ptr,
  output logic  w_full,
  output logic [A_SIZE-1:0] w_addr,
  output logic[A_SIZE :0] w_ptr
);

   logic [A_SIZE:0] w_bin;
  logic [A_SIZE:0] w_graynext, w_binnext;
  logic wfull_val;
  // GRAYSTYLE2 pointer
  always_ff @(posedge w_clk or negedge w_rst)
    if (!w_rst)
      {w_bin, w_ptr} <= '0;
    else
      {w_bin, w_ptr} <= {w_binnext, w_graynext};

  // Memory write-address pointer 
always_comb begin 
   w_addr = w_bin[A_SIZE-1:0];
   w_binnext = w_bin + (w_inc & ~w_full);
   w_graynext = (w_binnext>>1) ^ w_binnext;
end
 
  assign wfull_val = (w_graynext=={~w2r_ptr[A_SIZE:A_SIZE-1], w2r_ptr[A_SIZE-2:0]});

  always_ff @(posedge w_clk or negedge w_rst)
    if (!w_rst)
      w_full <= 1'b0;
    else
      w_full <= wfull_val;
endmodule

//Half full
module half_full #(
  parameter A_SIZE = 8
)
(
  input logic  [A_SIZE :0] r_ptr,
  output logic  w_half_full,
  input logic[A_SIZE :0] w_ptr
);
localparam DEPTH = 333;
always_comb 
begin
	if((w_ptr == DEPTH/2)&& (r_ptr == '0))
	w_half_full = 1'b1;
end
endmodule

//Half Empty
module half_empty #(
  parameter A_SIZE = 8
)
(
  input logic  [A_SIZE :0] r_ptr,
  output logic  w_half_empty,
  input logic[A_SIZE :0] w_ptr
);
localparam DEPTH = 333;
always_comb 
begin
	if(r_ptr == DEPTH/2)
	w_half_empty = 1'b1;
end
endmodule
