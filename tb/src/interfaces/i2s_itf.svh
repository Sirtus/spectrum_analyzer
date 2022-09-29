interface i2s_itf (input sclk);
  logic ws;
  logic sel;
  logic d_rx;
  logic [23:0] l_data;
  logic [23:0] r_data;
  logic read_en;
endinterface
