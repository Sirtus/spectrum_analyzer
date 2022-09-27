`ifndef i2s_driver
`define i2s_driver

class i2s_driver extends uvm_driver #(i2s_in);
  `uvm_component_utils(i2s_driver)

  virtual i2s_itf vif;
  uvm_analysis_port #(i2s_in) drv_analysis_port;

  function new(string name="i2s_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER BUILD", "BUILD", UVM_LOW);
    if(!uvm_config_db #(virtual i2s_itf) :: get(this, "", "vif", vif)) begin
      `uvm_fatal("DRIVER ERROR", "VIF NOT FOUND");
    end
    drv_analysis_port = new("drv_analysis_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);
      drv_analysis_port.write(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_item(i2s_in data);
    for(int i = 0; i < 24; i++) begin
      vif.d_rx = data.l_data[23-i];
      @(negedge vif.sclk);
    end
    for(int i = 0; i < 8; i++) begin
      vif.d_rx = 0;
      @(negedge vif.sclk);
    end
    for(int i = 0; i < 24; i++) begin
      vif.d_rx = data.r_data[23-i];
      @(negedge vif.sclk);
    end
    for(int i = 0; i < 8; i++) begin
      vif.d_rx = 0;
      @(negedge vif.sclk);
    end
    `uvm_info("DRIVER_AFTER", $sformatf("LEFT: %h RIGHT: %h %d", vif.l_data, vif.r_data, vif.read_en), UVM_LOW)
  endtask

endclass
`endif 