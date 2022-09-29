`ifndef i2s_monitor
`define i2s_monitor

class i2s_monitor extends uvm_monitor;
  `uvm_component_utils(i2s_monitor)

  virtual i2s_itf vif;
  uvm_analysis_port #(i2s_out) mon_analysis_port;
  semaphore sem;

  function new(string name="i2s_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual i2s_itf) ::get(this, "", "vif", vif))
      `uvm_error("MONITOR ERROR", "DUT ITF NOT FOUND");
    
    sem = new(1);
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    
    i2s_out out_data = i2s_out::type_id::create("data", this);
    super.run_phase(phase);
    forever begin
      @(negedge vif.sclk)
      if(vif.read_en ) begin
        `uvm_info("PPPPPPP", $sformatf("ldata: %h, rdata: %h PPP: %d", vif.l_data, vif.r_data, vif.ws), UVM_LOW)
        out_data.l_data = vif.l_data;
        out_data.r_data = vif.r_data;
        mon_analysis_port.write(out_data);
      end
    end
  endtask

endclass
`endif