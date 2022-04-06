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
    signal c: integer range 0 to 20 := 0;

    signal is_computed_dft: std_logic := '0';
    signal dft_res: queue_t;

    begin 

    pll: entity work.pll
    port map( inclk0 => clk, c0 => mclk);

    vga: entity work.vga_controller
    port map( clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y,
              h_sync => h_sync, v_sync => v_sync);

    plot: entity work.plot_controller
    port map(clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y, 
             red => red, green => green, blue => blue, l_data => l_data, r_data => r_data, do => dft_res);

--    mic: entity work.mic_rec
--    port map(mclk => mclk, sclk => sclk, ws => lrcl, d_rx => din, l_data => l_data, r_data => r_data, 
--            read_en => wr_en);

--    fifo: entity work.queue
--    port map(clk => mclk, data_in => l_data, data_out => do, wr_en => wr_en);

    dft: entity work.dft
    port map(clk => clk, data => do, read_en => wr_en, result => dft_res, is_computed => is_computed_dft);
    -- wr_en <= '1';    
	do <= ccc;
    sel <= '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if c < 10 then
                c <= c + 1;
                wr_en <= '1';
            else
                wr_en <= '0';
            end if;
        end if;
    end process;
end arch;

