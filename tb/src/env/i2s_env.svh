`ifndef i2s_env
`define i2s_env

class i2s_env extends uvm_env;
  

  `uvm_component_utils(i2s_env)

  i2s_agent agent;
  i2s_scoreboard scoreboard;

  function new(string name="i2s_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = i2s_agent::type_id::create("agent", this);
    scoreboard = i2s_scoreboard::type_id::create("scoreboard", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.mon_analysis_port.connect(scoreboard.ap_imp_out);
    agent.driver.drv_analysis_port.connect(scoreboard.ap_imp_in);
  endfunction
endclass
`endif