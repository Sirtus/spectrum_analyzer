library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity chart_controller is
    port (
        clk: in std_logic;
        red, green, blue: out std_logic_vector(3 downto 0);
        video_on: in std_logic;
        pixel_x, pixel_y: in integer;
        last_column: in integer range 0 to 255;
        addressA: out std_logic_vector(14 downto 0);
        qA: in std_logic_vector(15 downto 0)
    );
end entity chart_controller;

architecture arch of chart_controller is

    constant SINGLE_FFT_DELAY: integer := 514;
    constant UPPER_RECT_Y_LIMIT:integer := 344;

    constant X_LIMIT: integer := 799;
    constant Y_LIMIT: integer := 256;
    
    signal point_x: integer range 0 to 2047 := 0;
    signal point_y: integer range 0 to 2047 := 0;

    signal col_y: integer range 0 to 1023 := 0;
    signal data_pixel: std_logic_vector(15 downto 0) := (others => '0');

    signal lower_pixel_y, lower_pixel_x: integer range 0 to 2048 := 0;
    signal lower_video_on, upper_video_on: std_logic := '1';

    signal pixel_a: std_logic_vector(15 downto 0) := (others => '0');

    signal upper_rect_x: integer range 0 to 800 := 0;

    signal aclr, wren: std_logic := '0';
    signal q, data :std_logic_vector(0 downto 0);
    signal rdaddress, wraddress :std_logic_vector(17 downto 0);

    signal oe: std_logic;
    signal x1, x2, y1, y2, x_wr, y_wr: integer := 0;
    signal plot_addr1_wr, plot_addr1_rd, plot_addr2_wr, plot_addr2_rd: integer := 0;
    signal lower_pixel_y_div_2: integer range 0 to 2048 := 0;

    signal line_select: integer range 0 to 3 := 0;

    signal x, y: integer range 0 to 800:= 0;
    signal line_done, start_drawing_line: std_logic := '0';
    signal line_select_out: std_logic := '0';
    signal inverted_pixel_y: integer range 0 to 256:= 0;
    signal new_fft_y: integer range 0 to 255 := 0;

    signal read_fft_result: std_logic := '0';

    signal lower_red, lower_green, lower_blue:std_logic_vector(3 downto 0) := (others => '0');
    
    signal tfft_ram_addr, tfft_ram_column: integer := 0;
    signal col_x: integer range 0 to 1023  := 0;
    signal current_column: integer range 0 to 199 := 0;

begin

    plt_ram: entity work.plot_ram 
    port map (
        aclr => aclr,
        clock => clk,
        data => data,
        rdaddress => rdaddress,
        wraddress => wraddress,
        wren => wren,
        q => q
    );

    line: entity work.draw_line
    port map (
        clk => clk,
        start => start_drawing_line,
        x1 => x1,
        y1 => y1,
        x2 => x2,
        y2 => y2,
        x => x,
        y => y,
        oe => oe,
        done => line_done
    );

    wren <= '1' when lower_video_on = '1' or upper_video_on = '1' else '0';
    rdaddress <= std_logic_vector(to_unsigned(plot_addr2_rd, rdaddress'length)) ;
    wraddress <= std_logic_vector(to_unsigned(plot_addr2_wr, rdaddress'length)) when wren = '1' else (others => '0');
    data <= "1" when lower_video_on = '1' else "0";

    start_drawing_line <= '1' when read_fft_result = '1' and lower_pixel_y > 4 else '0';

    read_fft_result <= '1' when lower_video_on = '1' and pixel_x = SINGLE_FFT_DELAY + 1 else '0'; 
    
    x1 <= x2 - 3  when pixel_x = SINGLE_FFT_DELAY else x1;
    y1 <= new_fft_y when pixel_x = SINGLE_FFT_DELAY else y1 ;

    x2 <= upper_rect_x when pixel_x = SINGLE_FFT_DELAY else x2;
    y2 <= to_integer(unsigned(data_pixel(15 downto 8))) when pixel_x = SINGLE_FFT_DELAY else y2;

    new_fft_y <= y2 when pixel_x = SINGLE_FFT_DELAY + 50 else new_fft_y;

    oe <= '1';
    plot_addr1_wr <= y_wr * 800 when lower_video_on = '1' else 0;
    plot_addr1_rd <= inverted_pixel_y * 800 when upper_video_on = '1' else 0;
    plot_addr2_wr <= plot_addr1_wr + x_wr when lower_video_on = '1' else plot_addr1_rd + pixel_x - 1 when upper_video_on = '1' else 0;
    plot_addr2_rd <= plot_addr1_rd + pixel_x when upper_video_on = '1' else 0;

    inverted_pixel_y <= Y_LIMIT - pixel_y;

    upper_rect_x <= lower_pixel_y * 3;
    line_select <= lower_pixel_y_div_2 mod 4;
    line_select_out <= '1' when (x_wr /= x or y_wr /= y) and line_done = '0' else '0';

    x_wr <= x;
    y_wr <= y;

    lower_pixel_y_div_2 <= lower_pixel_y / 2;
    lower_pixel_x <= pixel_x / 4;
    data_pixel <= pixel_a when lower_pixel_y < Y_LIMIT else (others => '0');
    
    red <= lower_red when lower_video_on = '1' else
           "0000";

    lower_red <= "0011" when pixel_x = SINGLE_FFT_DELAY else
                "1111" when data_pixel(15 downto 12) /= "0000" else
                data_pixel(7 downto 4);

    lower_blue <= "0011" when pixel_x = SINGLE_FFT_DELAY else
            data_pixel(15 downto 12) when data_pixel(15 downto 12) /= "0000" else 
            "0000"                         when data_pixel(11 downto 8)  /= "0000" else
            not data_pixel(7 downto 4)     when data_pixel(7 downto 4)   /= "0000" else
            data_pixel(3 downto 0);

    blue <= lower_blue when lower_video_on = '1' else
            "0000";

    lower_green <= "0011" when pixel_x = SINGLE_FFT_DELAY else
                    "1111" when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else
                    data_pixel(11 downto 8);
        
    green <= "1111" when upper_video_on = '1' and q(0) = '1' else
             lower_green when lower_video_on = '1' else 
             "0000";

    lower_video_on <= '1' when video_on = '1' and pixel_y >= UPPER_RECT_Y_LIMIT else '0';
    upper_video_on <= '1' when video_on = '1' and pixel_y < Y_LIMIT else '0' ;
    lower_pixel_y <= pixel_y - UPPER_RECT_Y_LIMIT;

    current_column <= last_column + col_x;
    tfft_ram_column <= (current_column * N_DIV_2);
    tfft_ram_addr <= tfft_ram_column + lower_pixel_y_div_2;
    

    process(clk)
    variable pixel_addr: unsigned(14 downto 0) := (others => '0'); 
    variable row_y : integer := 0;
    variable pixel_counter_x, pixel_counter_y: integer range 0 to 31 := 0;
    begin
        if rising_edge(clk) then
            if pixel_x = 0 then
                pixel_counter_x := 0;
            end if;
            if pixel_counter_x = 0 then
                pixel_counter_x := pixel_counter_x + 1;
                if lower_pixel_y < Y_LIMIT and pixel_x < X_LIMIT then
                    pixel_addr := to_unsigned(tfft_ram_addr, addressA'length);
                    col_x <= lower_pixel_x;
                    
                    addressA <= std_logic_vector(pixel_addr);
                    pixel_a <= qA;
                end if;
            else
                if pixel_counter_x = 3 then
                    pixel_counter_x := 0;
                else
                    pixel_counter_x := pixel_counter_x + 1;
                end if;
                if pixel_x < X_LIMIT and lower_pixel_y < Y_LIMIT then
                    pixel_a <= qA;
                else
                end if;
            end if;
        end if;
    end process;
    
end architecture arch; 