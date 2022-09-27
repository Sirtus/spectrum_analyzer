package i2s_pkg;
  timeunit 1ns; timeprecision 1ns;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  `include "../data_out/i2s_out.svh"
  `include "../data_in/i2s_in.svh"
  `include "../transactions/i2s_sequencer.svh"
  `include "../monitors/i2s_monitor.svh"
  `include "../drivers/i2s_driver.svh"
  `include "../agents/i2s_agent.svh"
  `include "../scoreboards/i2s_scoreboard.svh"
  `include "../env/i2s_env.svh"
  `include "../sequences/i2s_sequence.svh"
  `include "../tests/i2s_test.svh"
endpackage
