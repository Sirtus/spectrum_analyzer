`ifndef i2s_sequence
`define i2s_sequence

class i2s_sequence extends uvm_sequence#(i2s_in);
  `uvm_object_utils(i2s_sequence)
  int num = 5;

  function new(string name="i2s_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info("SEQUENCE", "START", UVM_LOW);

    for(int i = 0; i < num; i++) begin
      i2s_in data = i2s_in::type_id::create("data"); 
      start_item(data);
      data.rnd();
      finish_item(data);
    end
    `uvm_info("SEQUENCE", "END", UVM_LOW);
  endtask

  task pre_body();
    if(starting_phase != null) 
      starting_phase.raise_objection(this, get_type_name());
  endtask

  task post_body();
    if(starting_phase != null) 
      starting_phase.drop_objection(this, get_type_name());
  endtask

endclass
`endif