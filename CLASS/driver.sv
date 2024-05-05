class driver;
  int tx_cnt1=0;
  int tx_cnt2=0;
  
  virtual Asynch_fifo_interface intf;
  mailbox gen2driv;
  
  function new(virtual Asynch_fifo_interface intf, mailbox gen2driv);
    this.intf = intf;
    this.gen2driv = gen2driv;
  endfunction
  
 `include "transaction.sv"   
  task reset;
    intf.w_rst <= 0;
    intf.r_rst <= 0;
    wait(!intf.w_rst);
    $display("[ DRIVER ] ************ RESET STARTED *************");
    intf.w_inc <= 0;
    intf.w_data <= 0;
    intf.r_inc <= 0;
    
    repeat(5) @(posedge intf.w_clk);
    intf.w_rst = 1'b1;
    intf.r_rst = 1'b1;
    wait(intf.w_rst);
    $display("[ DRIVER ] ************* RESET ENDED **************");
  endtask
  
  task main;
    $display("[ DRIVER ] *************** DRIVER STARTED ****************");
    
    forever begin
      transaction tx;
      gen2driv.get(intf);
      
      @(posedge intf.w_clk);
      tx_cnt1++;
      intf.w_clk <= intf.w_clk;
      intf.w_rst <= intf.w_rst;
      intf.r_clk <= intf.r_clk;
      intf.r_clk <= intf.r_clk;
      intf.r_rst <= intf.r_rst;
      $display("the tx_cnt1 =%d, the tx_cnt2=%d, w_inc=%d",tx_cnt1,tx_cnt2,intf.w_inc);
      if (intf.w_inc== 1'b1) tx_cnt2++;
    end
    $display("************* DRIVER ENDED *********************");
  endtask
endclass