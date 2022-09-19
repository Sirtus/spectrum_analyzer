module top_tb;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import i2s_pkg::*;

  bit clk;
  always #10 clk <= ~clk;

  i2s_itf itf(clk);
  i2s_dut_wrapper wrapper(._if(itf));

  initial begin
    uvm_config_db #(virtual i2s_itf)::set (null, "uvm_test_top", "i2s_itf", itf);
    run_test("i2s_test");
  end

  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule
