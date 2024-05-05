`include "transaction.sv"

class generator;
  rand transaction tx;
  mailbox gen2driv;
  virtual Asynch_fifo_interface bus_tb;
  int tx_cnt;
  logic [8-1:0] verif_data[$];
  logic [8-1:0] verif_w_data;
  int i;
  event ended;
  function new(virtual Asynch_fifo_interface bus_tb, mailbox gen2driv);
    this.bus_tb = bus_tb;
    this.gen2driv = gen2driv;
  endfunction
  
  
  task main();
    $display("************** GENERATOR_STARTED *****************");
    $display("{Genarator} tx_cnt = %d",tx_cnt);
    //repeat(tx_cnt) begin
fork 
     for(int i=0;i <tx_cnt;i++) begin
      $display("entering generate loop");
     //@(posedge bus_tb.wclk)
      @(posedge bus_tb.w_clk iff !bus_tb.w_full);
         bus_tb.w_inc = (i%3 == 0)? 1'b1 : 1'b0;
        
        if (bus_tb.w_inc) begin
          tx = new();
          assert(tx.randomize());
          bus_tb.w_data = tx.w_data;
          gen2driv.put(bus_tb);
          verif_data.push_front(bus_tb.w_data);
          $display("w_data rand =%d", bus_tb.w_data);
        end
       
      end
      for(int j=0;j<tx_cnt;j++) begin
        
        //@(posedge bus_tb.r_clk)
        @(posedge bus_tb.r_clk iff !bus_tb.r_empty)
        bus_tb.r_inc = ((j%2 == 0)||(tx_cnt==0))? 1'b1 : 1'b0;
        if (bus_tb.r_inc) begin
          verif_w_data = verif_data.pop_back();
          // Check the rdata against modeled wdata
          $display("Assertion check rdata: expected w_data = %h, r_data = %h, time=%0t", verif_w_data, bus_tb.r_data,$time);
          assert(bus_tb.r_data === verif_w_data) else $error("Checking failed: expected w_data = %h, r_data = %h", verif_w_data, bus_tb.r_data);
        end
        if(j==tx_cnt)
         break; 
      end 
     join
      
    
   -> ended;
    $display("[ GENERATOR ] ************ GENERATOR ENDED *******************");
  endtask
endclass
