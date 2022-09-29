`ifndef i2s_out
`define i2s_out

class i2s_out extends uvm_sequence_item;
  logic[23:0] l_data;
  logic[23:0] r_data;

  `uvm_object_utils_begin(i2s_out)
    `uvm_field_int(l_data, UVM_DEFAULT)
    `uvm_field_int(r_data, UVM_DEFAULT)
  `uvm_object_utils_end


  function new(string name="i2s_out");
    super.new(name);
  endfunction
endclass
`endif 