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
    signal data_pixel: std_logic_vector(15 downto 0) := (others => '0');
    signal data_pixel_int: integer := 0;
    
    signal done_f: std_logic := '0';
    signal ws: std_logic := '0';

    signal addressA, addressB: std_logic_vector(13 downto 0);
    signal dataA, dataB, qA, qB: std_logic_vector(15 downto 0);
    signal wrA, wrB: std_logic;
    
    signal last_column: integer;
    signal col_y: integer range 0 to 1023 := 0;

    begin 

    bclk: entity work.bclk
    port map( inclk0 => clk, c0 => mclk);

    reg: entity work.shift_reg
    port map(clock => clk, address_a => addressA, address_b => addressB, data_a => dataA, 
             data_b => dataB, wren_a => wrA, wren_b => wrB, q_a => qA, q_b => qB);

    vga: entity work.vga_controller
    port map( clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y,
              h_sync => h_sync, v_sync => v_sync);

    plot: entity work.plot_controller
    port map(clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y, 
             red => red, green => green, blue => blue, do => data_pixel);

    
    fft: entity work.fft
    port map(clk => clk,  do_fft => do_fft, done => done_f, wr_en => wr_en, data_in => l_data, last_column => last_column, general_ram_addr => addressB, general_ram_data => dataB, general_ram_wren => wrB);

    -- process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         if done_f = '1' then
    --             do_next <= do_cos;
    --         end if;
    --     end if;
    -- end process;

    -- process(clk)
    
    -- type writing_sm is (idle, write_to_register, wait_for_reg);
    -- variable state: writing_sm := idle;
    -- variable wait_cnt: integer range 0 to 7 := 0;
    -- variable fft_counter: integer range 0 to 15 := 0;
    -- begin
    --     if rising_edge(clk) then
    --         case state is
    --             when idle =>
    --                 wrB <= '0';
    --                 if done_f = '1' then
    --                     if fft_counter = 10 then
    --                         state := write_to_register;
    --                         do_fft <= '0';
    --                         wait_cnt := 0;
    --                         do_i_cnt <= 0;
    --                         fft_counter := 0;
    --                     else
    --                         fft_counter := fft_counter + 1;
    --                     end if;
    --                 else
    --                     state := idle;
    --                     do_fft <= '1';
    --                 end if;
    --             when write_to_register =>
    --                 wrB <= '1';
    --                 if do_i_cnt = WORD_WIDTH then
    --                     state := idle;
    --                     do_i_cnt <= 0;
    --                     last_column <= (last_column + 1) mod 128;
    --                 else
    --                     addressB <= std_logic_vector(to_unsigned((last_column*WORD_WIDTH) + do_i_cnt, addressB'length));
    --                     dataB <= std_logic_vector(to_unsigned(do_next(do_i_cnt), dataB'length));
    --                     do_i_cnt <= do_i_cnt + 1;
    --                     state := wait_for_reg;
    --                 end if;
            
    --             when wait_for_reg =>
    --                 if wait_cnt = 6 then
    --                     wait_cnt := 0;
    --                     state := write_to_register;
    --                 else
    --                     wait_cnt := wait_cnt + 1;
    --                     state := wait_for_reg;
    --                 end if;
                    
    --             when others =>
                    
            
    --         end case;

    --     end if;
    -- end process;

    process(clk)
    variable pixel_addr: unsigned(13 downto 0) := (others => '0'); 
    variable current_column: integer range 0 to 255 := 0;
    begin
        if rising_edge(clk) then
            if pixel_y <= 256 then
                col_y <= (current_column * N_DIV_2) + pixel_y/8;
                pixel_addr := to_unsigned(col_y, addressA'length);
            end if;
            current_column := (last_column + pixel_x) mod 128;
            addressA <= std_logic_vector(pixel_addr);
            data_pixel <= qA;
        end if;
    end process;

    i2s: entity work.i2s_receiver
    port map(sclk => mclk, ws => ws, d_rx => din, l_data => l_data, r_data => r_data, sel => sel,
    read_en => wr_en);

    lrcl <= ws;
    sclk <= mclk;
    wrA <= '0';
    dataA <= (others => '0');

end arch;

