library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common.all;

entity spectrum_analyzer is
    port(
        clk: in std_logic;

        red, green, blue: out std_logic_vector(3 downto 0);
        h_sync, v_sync: out std_logic;
		  
		  mic_vcc: out std_logic := '1';
		  mic_gnd: out std_logic := '0';

        sel: out std_logic;
        lrcl: out std_logic;
        din: in std_logic;
        sclk: out std_logic
    );
end spectrum_analyzer;

architecture arch of spectrum_analyzer is

    signal video_on: std_logic := '0';
    signal pixel_x, pixel_y: integer := 0;
    signal mclk: std_logic := '0';
    signal dd, l_data, r_data : std_logic_vector(23 downto 0);
    signal do: queue_t := (others => 0);
    signal wr_en: std_logic := '0';

    begin 

    bclk: entity work.bclk
    port map( inclk0 => clk, c0 => mclk);

    vga: entity work.vga_controller
    port map( clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y,
              h_sync => h_sync, v_sync => v_sync);

    plot: entity work.plot_controller
    port map(clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y, 
             red => red, green => green, blue => blue, l_data => l_data, r_data => r_data, do => do);


    i2s: entity work.i2s_receiver
    port map(sclk => mclk, ws => lrcl, d_rx => din, l_data => l_data, r_data => r_data, 
    read_en => wr_en);

    fifo: entity work.queue
    port map(clk => mclk, data_in => l_data, data_out => do, wr_en => wr_en);
    
    sel <= '0';
    sclk <= mclk;

end arch;

