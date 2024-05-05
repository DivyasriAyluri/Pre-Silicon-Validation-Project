`include "transaction.sv"
class scoreboard;
  mailbox mon_in2scb;
  mailbox mon_out2scb;
  virtual Asynch_fifo_interface vif;
  logic [7:0] rdata_fifo[$];
  logic [7:0] wdata_fifo[$]; 
  int fd;
logic [8-1:0] verif_data_q[$];
  logic [8-1:0] verif_wdata;
  function new(virtual Asynch_fifo_interface vif, mailbox mon_in2scb, mailbox mon_out2scb);
    this.vif = vif;
    this.mon_in2scb  = mon_in2scb;
    this.mon_out2scb = mon_out2scb;
  endfunction
  
  task main;
	fork 
      get_data_w();
      get_data_r();
      //get_output();
    join_none;
  endtask
  
  
  task get_data_w();
    
     transaction tx;
   
   for(int i=0;i <100;i++) begin
      
      @(posedge vif.w_clk iff !vif.w_full);
        
        if (vif.w_inc) begin
          mon_in2scb.get(tx);
           verif_data_q.push_front(tx.w_data); 
          fd= $fopen("output1.txt","a");
      $fdisplay(fd,"the scoreboard wdata  =%h",vif.w_data);
        end
     end 
    
  endtask
  task get_data_r();
    
     transaction tx;
    
    for(int j=0;j<100;j++) begin
        
        
        @(posedge vif.rclk iff !vif.r_empty)
        vif.r_inc = (j%2 == 0)? 1'b1 : 1'b0;
        if ((vif.r_inc) &&(j!=0)) begin
          verif_wdata = verif_data_q.pop_back();
           mon_out2scb.get(tx);
          // Check the rdata against modeled wdata
            fd= $fopen("output1.txt","a");
          $fdisplay(fd,"Scoreboard Assertion check rdata: expected wdata = %h, rdata = %h, time=%0t", verif_wdata, tx.r_data,$time); 
          assert(tx.r_data === verif_wdata) else $fdisplay(fd,"Checking failed: expected wdata = %h, rdata = %h", verif_wdata, tx.r_data);
        end
        
      end 
      
    
  endtask 
  
  task get_output();
    transaction tx;
    static logic [7:0] a, b;
    
    forever begin
      
      mon_in2scb.get(tx);
      mon_out2scb.get(tx);
      //$display("Outputs received at SCOREBOARD rdata = %0d, wdata =%0d", tx.rdata,tx.wdata); 
      @(posedge vif.r_clk iff !vif.r_empty)  
      if(tx.r_inc) begin
            b = wdata_fifo.pop_front();
            a = rdata_fifo.pop_front();
          fd= $fopen("output1.txt","a");
         assert(a === b) else $fdisplay(fd,"Checking failed: expected wdata = %h, r_data = %h", a,b);
      end
      /*mon_out2scb.get(tx);
      fd= $fopen("output1.txt","a");
      if(a!=b)
        $fdisplay(fd,"Wrong Result --- Inputs wdata = %0h and --- Output rdata= %0h \n\n ", b, a);
      else 
        $fdisplay(fd,"PASS inputs wdata = %0h and --- Output rdata= %0h \n\n", b, a); */
      end
      $fclose(fd);
     
  
   
  endtask
    
endclass