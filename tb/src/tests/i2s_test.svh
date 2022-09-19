import uvm_pkg::*;
`include "uvm_macros.svh"

class i2s_test extends uvm_test;
  `uvm_component_utils(i2s_test)

  function new(string name="i2s_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
  endfunction

endclass
