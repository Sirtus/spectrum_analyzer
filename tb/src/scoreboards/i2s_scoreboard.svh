`ifndef i2s_scoreboard
`define i2s_scoreboard

`uvm_analysis_imp_decl(_dut_in)
`uvm_analysis_imp_decl(_dut_out)

class i2s_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2s_scoreboard);

  uvm_analysis_imp_dut_in #(i2s_in, i2s_scoreboard) ap_imp_in;
  uvm_analysis_imp_dut_out #(i2s_out, i2s_scoreboard) ap_imp_out;
  i2s_in input_array[$];
  i2s_out output_array[$];
  

  function new(string name="i2s_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD BUILD", "BUILD", UVM_LOW);
    ap_imp_in = new("ap_imp_in", this);
    ap_imp_out = new("ap_imp_out", this);

  endfunction

  virtual function void report_phase(uvm_phase phase);
    int mismatches = 0;
    foreach(input_array[i]) begin
      if(input_array[i].l_data !=? output_array[i].l_data) begin
        mismatches++;
        `uvm_info("SCOREBOARD_MISMATCH LEFT", $sformatf("ACTUAL: %h, EXPECTED: %h", output_array[i].l_data, input_array[i].l_data), UVM_LOW);
        `uvm_info("SCOREBOARD_MISMATCH LEFT", $sformatf("ACTUAL: %b, EXPECTED: %b", output_array[i].l_data, input_array[i].l_data), UVM_LOW);
      end else begin
        `uvm_info("SCOREBOARD_MATCH LEFT", $sformatf("ACTUAL: %h, EXPECTED: %h", output_array[i].l_data, input_array[i].l_data), UVM_LOW);
      end
      if(input_array[i].r_data !=? output_array[i].r_data) begin
        mismatches++;
        `uvm_info("SCOREBOARD_MISMATCH RIGHT", $sformatf("ACTUAL: %h, EXPECTED: %h", output_array[i].r_data, input_array[i].r_data), UVM_LOW);
        `uvm_info("SCOREBOARD_MISMATCH RIGHT", $sformatf("ACTUAL: %b, EXPECTED: %b", output_array[i].r_data, input_array[i].r_data), UVM_LOW);
      end else begin
        `uvm_info("SCOREBOARD_MATCH RIGHT", $sformatf("ACTUAL: %h, EXPECTED: %h", output_array[i].r_data, input_array[i].r_data), UVM_LOW);
      end
    end
    $display("############################\n");
    if(!mismatches) begin
      $display("TEST PASSED\n");
    end else begin
      $display("TEST FAILED\n");
    end
    $display("############################\n");
    `uvm_info("REPORT", $sformatf("MISMATCHES: %d", mismatches), UVM_LOW);
  endfunction

  virtual function void write_dut_in(i2s_in data);
    `uvm_info("WRITE", "RECEIVED_DATA_IN", UVM_LOW);
    input_array.push_back(data);
    `uvm_info("SCRBD", $sformatf("l: %h  r: %h", data.l_data, data.r_data), UVM_LOW);
  endfunction

  virtual function void write_dut_out(i2s_out data);
    i2s_out ndata = new("dat");
    ndata.l_data = data.l_data;
    ndata.r_data = data.r_data;
    `uvm_info("WRITE", "RECEIVED_DATA_OUT", UVM_LOW);
    
    output_array.push_back(ndata);
    `uvm_info("SCRBD", $sformatf("l: %h  r: %h", data.l_data, data.r_data), UVM_LOW);
  endfunction


endclass
`endif