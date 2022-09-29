`ifndef i2s_sequencer
`define i2s_sequencer

class i2s_sequencer extends uvm_sequencer#(i2s_in);
  `uvm_component_utils(i2s_sequencer)
  function new (string name="i2s_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction

endclass
`endif
