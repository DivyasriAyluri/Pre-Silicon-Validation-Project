`include "transaction.sv"
class monitor_out;
  int tx_count=0;
  virtual Asynch_fifo_interface vif;
  mailbox mon_out2scb;
   transaction tx = new();
int fd;
int i;
  function new(virtual Asynch_fifo_interface vif, mailbox mon_out2scb);
    this.vif = vif;
    this.mon_out2scb = mon_out2scb;
  endfunction
  
  task main;
    $display("[ MONITOR_OUT ] ****** MONITOR_OUT STARTED ******");    
    forever begin
        
        
        @(posedge vif.rclk iff !vif.r_empty)
        vif.r_inc = (i%2 == 0)? 1'b1 : 1'b0;
        if ((vif.r_inc)&&(i!=0)) begin
             tx.r_data =vif.r_data;
             mon_out2scb.put(tx);
             tx_count++;
             
             fd= $fopen("output1.txt","a");
             $fdisplay(fd,"monitor_out rdata  =%h",tx.r_data);
        end
  i++;
      end 
  
    $display("[ MONITOR_OUT ] ****** MONITOR_OUT ENDED ******");    
  endtask
endclass

