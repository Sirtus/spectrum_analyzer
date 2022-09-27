`ifndef i2s_in
`define i2s_in

class i2s_in extends uvm_sequence_item;
  rand logic[23:0] l_data;
  rand logic[23:0] r_data;

  `uvm_object_utils_begin(i2s_in)
    `uvm_field_int(l_data, UVM_DEFAULT)
    `uvm_field_int(r_data, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function void rnd();
    l_data = $urandom;
    r_data = $urandom; //24'h712345;
  endfunction

  function new(string name="i2s_in");
    super.new(name);
  endfunction
endclass
`endif 