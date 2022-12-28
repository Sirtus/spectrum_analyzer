library IEEE;
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
        sclk: out std_logic;
        switch: in std_logic
    );
end spectrum_analyzer;

architecture arch of spectrum_analyzer is

    signal video_on: std_logic := '0';
    signal pixel_x, pixel_y: integer range 0 to 2047 := 0;
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

    signal addressA, addressB: std_logic_vector(14 downto 0);
    signal dataA, dataB, qA, qB: std_logic_vector(15 downto 0);
    signal wrA, wrB: std_logic;
    
    signal last_column: integer;
    signal fifoA_addr_a, fifoA_addr_b, fifoB_addr_a, fifoB_addr_b: std_logic_vector(8 downto 0);
    signal fifoA_q_a, fifoA_q_b, fifoB_q_a, fifoB_q_b: std_logic_vector(11 downto 0);
    signal fifoA_data_a, fifoA_data_b, fifoB_data_a, fifoB_data_b: std_logic_vector(11 downto 0);
    signal fifo_last_column: unsigned(LOG_N-1 downto 0) := (others => '0');
    signal fifoA_calculated_column, fifoB_calculated_column: unsigned(LOG_N-1 downto 0) := (others => '0');

    begin 

    bclk: entity work.bclk
    port map( inclk0 => clk, c0 => mclk);

    reg: entity work.shift_reg
    port map(clock => clk, address_a => addressA, address_b => addressB, data_a => dataA, 
             data_b => dataB, wren_a => wrA, wren_b => wrB, q_a => qA, q_b => qB);

    vga: entity work.vga_controller
    port map( clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y,
              h_sync => h_sync, v_sync => v_sync);

    chart: entity work.chart_controller
    port map(clk => clk, video_on => video_on, pixel_x => pixel_x, pixel_y => pixel_y, 
             red => red, green => green, blue => blue, last_column => last_column, addressA => addressA, qA => qA);

    
    fft: entity work.fft
    port map(clk => clk,  do_fft => switch, done => done_f, wr_en => wr_en, 
    last_column => last_column, general_ram_addr => addressB, general_ram_data => dataB, 
    general_ram_wren => wrB, fifoA_addr => fifoA_calculated_column, fifoB_addr => fifoB_calculated_column,
    fifoA_q => fifoA_q_b, fifoB_q => fifoB_q_b);

    fifoA: entity work.fifo
    port map(
    address_a => fifoA_addr_a,
    address_b => fifoA_addr_b,
    clock => clk,
    data_a => fifoA_data_a,
    data_b => fifoA_data_b,
    wren_a => '1',
    wren_b => '0',
    q_a => fifoA_q_a,
    q_b => fifoA_q_b);

    fifoB: entity work.fifo
    port map(
    address_a => fifoB_addr_a,
    address_b => fifoB_addr_b,
    clock => clk,
    data_a => fifoB_data_a,
    data_b => fifoB_data_b,
    wren_a => '1',
    wren_b => '0',
    q_a => fifoB_q_a,
    q_b => fifoB_q_b);

    fifoB_addr_a <= fifoA_addr_a;
    fifoB_data_a <= fifoA_data_a;
    fifoA_addr_b <= '0' & std_logic_vector(fifoA_calculated_column + fifo_last_column);
    fifoB_addr_b <= '0' & std_logic_vector(fifoB_calculated_column + fifo_last_column);

    i2s_queue: entity work.queue 
    port map (
        clk => clk,
        wr_en => wr_en,
        data_in => l_data,
        fifoA_addr_a => fifoA_addr_a,
        fifoA_data_a => fifoA_data_a,
        fifo_last_column => fifo_last_column
    );


    i2s: entity work.i2s_receiver
    port map(sclk => mclk, ws => ws, d_rx => din, l_data => l_data, r_data => r_data, sel => sel,
    read_en => wr_en);

    lrcl <= ws;
    sclk <= mclk;
    wrA <= '0';
    dataA <= (others => '0');

end arch;

