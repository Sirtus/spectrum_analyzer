module hello;
  import uvm_pkg::*;
  `include "uvm_macros.svh" 
  initial begin
    int a = 55;
    `uvm_info("ASD", $sformatf("\n\n iAPOIJDPOSIJDPOSAIJ %d\n\n", a), UVM_LOW);
  end
endmodule
