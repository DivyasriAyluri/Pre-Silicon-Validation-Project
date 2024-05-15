`include "env.sv"
module test(Asynch_fifo_interface intf);
  environment env;
  
  initial begin
    env = new(intf);
    
    
    env.gen.tx_cnt = 60;
    
    env.run();
  end
endmodule