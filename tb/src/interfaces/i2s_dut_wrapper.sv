module i2s_dut_wrapper (i2s_itf _if);
  i2s_receiver wrapper (.sclk (_if.sclk),
                        .ws (_if.ws),
                        .sel(_if.sel),
                        .d_rx(_if.d_rx),
                        .l_data(_if.l_data),
                        .r_data(_if.r_data),
                        .read_en(_if.read_en));
endmodule
