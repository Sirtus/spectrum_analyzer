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

        sel: out std_logic := '0';
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
    signal do, do_i: isignal_t := (others => 0);
    signal do_cos, do_next: osignal_t := (others => 0);
    signal wr_en, do_fft: std_logic := '1';
    signal do_i_cnt: integer := 0;
    
    -- signal simple_data: queue_t := 
    -- (
    --     -- 35, 35, 64, 106, 35, -106, -135,-35 , others => 35
    --     -- 255,12, 123, 255, 3, 12, 255, 12
    --     -- 0, 1, 2, 3, 4, 5, 6, 7
    --     0, -1, -19, 14, 21, 20, 22, -4, -15, -17, -18, -5, 25, 4, 8, 15, 
    --     -23, -21, 1, 17, 10, 23, -15, -20, 1, 25, 17, -14, -22, -17, -23, 
    --     6, 1, -17, 25, 21, -2, -7, 15, -8, -24, -20, -23, -24, -23, -6, 
    --     19, 19, -20, -1, 2, -15, 15, -15, 10, 23, 21, 17, -20, -23, -16, 
    --     -10, -18, -18, 23, 25, 6, -22, -16, -6, 14, -9, 21, 3, -17, -6, 
    --     15, 25, 18, -10, -20, -3, 24, 24, -23, 25, 13, 23, -24, -12, -23, 
    --     -13, -2, -13, -23, -23, 0, 25, 24, 10, -22, -5, -22, 25, 1, 23, 
    --     0, -17, 10, 21, -9, -23, -23, -21, -22, 14, 25, 6, -22, -10, -15, 
    --     12, -24, -18, 21, 24, 25, 15, 1, -14, -24, -23, -20, 19, 25, -11, 
    --     16, 11, 23, -5, -24, -13, 23, 22, 24, 24, 10, -20, -9, 18, 1, 
    --     -22, 0, -24, 23, 6, 23, -9, -23, -24, 0, 24, 24, 14, 3, 14, 
    --     24, 13, 25, -22, -12, -24, 24, -23, -23, 4, 21, 11, -17, -24, -14, 
    --     7, 18, -2, -20, 10, -13, 7, 17, 23, -5, -24, -22, 19, 19, 11, 
    --     17, 24, 21, -16, -20, -22, -9, 16, -14, 16, -1, 2, 21, -18, -18, 
    --     7, 24, 25, 24, 21, 25, 9, -14, 8, 3, -20, -24, 18, 1, -5, 
    --     24, 18, 23, 15, -16, -24, 0, 21, 16, -22, -9, -16, 0, 22, 24, 
    --     -14, -7, -3, -24, 6, 19, 18, 16, 5, -21, -19, -20, -13, 20, others => 2
    --     -- 0, -1, -3, -4, -6, -7, -9, -10, -12, -14, -15, -17, -18, -20, -21, -23, 
    --     -- -24, -26, -28, -29, -31, -32, -34, -35, -37, -38, -40, -41, -43, -44, -46, 
    --     -- -47, -48, -50, -51, -53, -54, -56, -57, -58, -60, -61, -63, -64, -65, -67, 
    --     -- -68, -69, -71, -72, -73, -74, -76, -77, -78, -79, -81, -82, -83, -84, -85, 
    --     -- -87, -88, -89, -90, -91, -92, -93, -94, -95, -96, -97, -98, -99, -100, -101, 
    --     -- -102, -103, -104, -105, -106, -107, -108, -108, -109, -110, -111, -112, -112, -113, -114, 
    --     -- -115, -115, -116, -117, -117, -118, -9, -119, -119, -120, -121, -121, -122, -122, -122, 
    --     -- -123, -123, -124, -124, -124, -125, -125, -125, -126, -126, -126, -126, -127, -127, -127, 
    --     -- -127, -127, -127, -127, -127, -127, -127, -128, -127, -127, -127, -7, -127, -127, -127, 
    --     -- -127, -127, -127, -126, -126, -126, -126, -125, -125, -125, -124, -124, -124, -123, -123, 
    --     -- -122, -122, -122, -121, -121, -120, -119, -119, -118, -118, -117, -117, -116, -115, -115, 
    --     -- -114, -113, -112, -112, -111, -110, -109, -108, -108, -107, -106, -105, -104, -103, -102, 
    --     -- -101, -100, -99, -98, -97, -96, -95, -94, -93, -92, -91, -90, -89, -88, -87, 
    --     -- -85, -84, -83, -82, -81, -79, -78, -77, -76, -74, -73, -72, -71, -69, -68, 
    --     -- -67, -65, -64, -63, -61, -60, -58, -57, -56, -54, -53, -51, -50, -48, -47, 
    --     -- -46, -44, -43, -41, -40, -38, -37, -35, -34, -32, -31, -29, -28, -26, -24, 
    --     -- -23, -21, -20, -18, -17, -15, -14, -12, -10, -9, -7, -6, -4, -3, -1
    -- );
    -- signal simple_data: queue_t := 
    -- ( 
    --     0, -122, -191, 8, 1, -197, -167, 167, 182, 167, -167, -197, 0, 8, -191, -122, 
    --     1, 123, 192, -7, 0, 198, 168, -166, -181, -166, 168, 198, 1, -7, 192, 123
    -- );
    signal done_f: std_logic := '0';
    signal ws: std_logic := '0';
    begin 

    bclk: entity work.bclk
    port map( inclk0 => clk, c0 => mclk);

    vga: entity work.vga_controller
    port map( clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y,
              h_sync => h_sync, v_sync => v_sync);

    plot: entity work.plot_controller
    port map(clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y, 
             red => red, green => green, blue => blue, do => do_next);

--    mic: entity work.mic_rec
--    port map(mclk => mclk, sclk => sclk, ws => lrcl, d_rx => din, l_data => l_data, r_data => r_data, 
--            read_en => wr_en);

--    fifo: entity work.queue
--    port map(clk => clk, data_in => l_data, data_out => do, wr_en => wr_en, do_fft => do_fft);

    fft: entity work.fft
    port map(clk => clk,  do_fft => do_fft, done => done_f, res => do_cos, wr_en => wr_en, data_in => l_data);

    process(clk)
    begin
        if rising_edge(clk) then
            if done_f = '1' then
                do_next <= do_cos;
            end if;
        end if;
    end process;

    -- process(clk)
    
    -- type writing_sm is (idle, write_to_array);
    -- variable state: writing_sm := idle;
    -- begin
    --     if rising_edge(clk) then
    --         case state is
    --             when idle =>
    --                 if done_f = '1' then
    --                     state := write_to_array;
    --                     do_fft <= '0';
    --                 else
    --                     state := idle;
    --                     do_fft <= '1';
    --                 end if;
    --             when write_to_array =>
    --                 if do_i_cnt = N then
    --                     state := idle;
    --                     do_i_cnt <= 0;
    --                 else
    --                     do_i_cnt <= do_i_cnt + 1;
    --                     do_i(do_i_cnt) <= do_i_cnt mod 3; --do(do_i_cnt);
    --                 end if;
            
    --             when others =>
                    
            
    --         end case;

    --     end if;
    -- end process;

    i2s: entity work.i2s_receiver
    port map(sclk => mclk, ws => ws, d_rx => din, l_data => l_data, r_data => r_data, sel => sel,
    read_en => wr_en);

    lrcl <= ws;
    sclk <= mclk;

end arch;

