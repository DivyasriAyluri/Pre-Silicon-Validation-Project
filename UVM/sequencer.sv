class afifo_sequencer extends uvm_sequencer#(afifo_sequence_item);
    `uvm_component_utils(afifo_sequencer)
 
    //CLASS CONSTRUCTOR
   
  function new(string name = "afifo_sequencer",uvm_component parent);
      super.new(name,parent);
    endfunction
  
    
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQR_CLASS", "Build Phase!", UVM_HIGH)
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SEQR_CLASS", "Connect Phase!", UVM_HIGH)
    
  endfunction: connect_phase
  
  
  
endclass
   




