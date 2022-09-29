`ifndef i2s_test
`define i2s_test

class i2s_test extends uvm_test;
  `uvm_component_utils(i2s_test)

  i2s_env env;
  virtual i2s_itf vif;

  function new(string name="i2s_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = i2s_env::type_id::create("env", this);
    if(!uvm_config_db#(virtual i2s_itf)::get(this, "", "vif", vif)) begin
      `uvm_fatal("TEST ERROR", "VIF NOT FOUND")
    end

    uvm_config_db #(virtual i2s_itf)::set(this, "env.agent.*", "vif", vif);
    
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    // uvm_top.print_topology();
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    i2s_sequence seq = i2s_sequence::type_id::create("seq");

    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    // #20000
    phase.drop_objection(this);
    `uvm_info("TETSTETS", "KONIEC", UVM_LOW);
  endtask

endclass
`endif