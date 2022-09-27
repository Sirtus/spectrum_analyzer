`ifndef i2s_agent
`define i2s_agent

`include "uvm_macros.svh"
class i2s_agent extends uvm_agent;
  `uvm_component_utils(i2s_agent)

  i2s_driver driver;
  i2s_monitor monitor;
  i2s_sequencer sequencer;
  function new(string name="i2s_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("AGENT BUILD", "BUILD", UVM_LOW);
    sequencer = i2s_sequencer::type_id::create("sequencer", this);
    driver = i2s_driver::type_id::create("driver", this);
    monitor = i2s_monitor::type_id::create("monitor", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass
`endif