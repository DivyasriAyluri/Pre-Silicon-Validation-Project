class afifo_base_sequence extends uvm_sequence#(afifo_sequence_item);
  
  `uvm_object_utils(afifo_base_sequence)
    
 
  afifo_sequence_item pkt;
  
  logic[7:0] data_in;
  bit r_rst,w_rst;
  int file;
  int data;
  function new(string name = "afifo_base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  task body();
    `uvm_info("TEST_SEQ", "Inside task body!", UVM_HIGH)
    
     pkt = afifo_sequence_item::type_id::create("pkt");
    
    file = $fopen("test.txt", "r");
    if (file == 0) begin
      return;
    end
    
    while (!$feof(file)) begin
      start_item(pkt);
      data = $fscanf(file, "%h %b %b", data_in, w_rst, r_rst);
      assert(!$isunknown(data_in)) else
      `uvm_error("ASSERTION", "x or z bits");
     
      pkt.w_rst = w_rst;
      pkt.r_rst = r_rst;
      if(pkt.w_rst==1)
         pkt.data_in = data_in; 
     
      
      finish_item(pkt);
    end
    

    $fclose(file);
  endtask: body
endclass

