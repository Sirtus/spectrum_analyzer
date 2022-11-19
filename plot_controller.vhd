library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity plot_controller is
    port (
        clk: in std_logic;
        red, green, blue: out std_logic_vector(3 downto 0);
        video_on: in std_logic;
        pixel_x, pixel_y: in integer;
        last_column: in integer range 0 to 255;
        addressA: out std_logic_vector(14 downto 0);
        qA: in std_logic_vector(15 downto 0)
        -- do_int: in integer range 0 to 600
    );
end entity plot_controller;

architecture arch of plot_controller is

    constant SINGLE_FFT_DELAY: integer := 512;
    constant UPPER_RECT_Y_LIMIT:integer := 344;

    constant X_LIMIT: integer := 799;
    constant Y_LIMIT: integer := 256;
    
    signal point_x: integer range 0 to 2047 := 0;
    signal point_y: integer range 0 to 2047 := 0;

    signal col_y: integer range 0 to 1023 := 0;
    signal data_pixel: std_logic_vector(15 downto 0) := (others => '0');

    signal lower_pixel_y, lower_pixel_x: integer range 0 to 2048 := 0;
    signal lower_video_on, upper_video_on: std_logic := '1';

    type pixel_array_t is array(0 to 199) of std_logic_vector(15 downto 0);
    signal pixel_array: pixel_array_t;
    type single_fft_array is array(0 to 127) of integer range 0 to 255;
    signal single_fft: single_fft_array;

    signal upper_rect_x: integer range 0 to 800 := 0;

    signal aclr, wren: std_logic := '0';
    signal q, data :std_logic_vector(0 downto 0);
    signal rdaddress, wraddress :std_logic_vector(17 downto 0);

    signal oe: std_logic;
    signal x1, x2, y1, y2, x_wr, y_wr: integer := 0;
    signal plot_addr1_wr, plot_addr1_rd, plot_addr2_wr, plot_addr2_rd: integer := 0;
    signal lower_pixel_y_div_2: integer range 0 to 2048 := 0;

    signal line_select: integer range 0 to 3 := 0;

    type line_array is array(0 to 3) of integer range 0 to 800;
    signal x, y: line_array:= (others => 0);
    signal line_done, start_drawing_line: std_logic_vector(0 to 3) := (others => '0');
    signal line_select_out: std_logic_vector(0 to 3) := (others => '0');
    signal inverted_pixel_y: integer range 0 to 256:= 0;
    signal new_fft_y: integer range 0 to 255 := 0;

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

    line0: entity work.draw_line
    port map (
        clk => clk,
        start => start_drawing_line(0),
        x1 => x1,
        y1 => y1,
        x2 => x2,
        y2 => y2,
        x => x(0),
        y => y(0),
        oe => oe,
        done => line_done(0)
    );


    line1: entity work.draw_line
    port map (
        clk => clk,
        start => start_drawing_line(1),
        x1 => x1,
        y1 => y1,
        x2 => x2,
        y2 => y2,
        x => x(1),
        y => y(1),
        oe => oe,
        done => line_done(1)
    );


    line2: entity work.draw_line
    port map (
        clk => clk,
        start => start_drawing_line(2),
        x1 => x1,
        y1 => y1,
        x2 => x2,
        y2 => y2,
        x => x(2),
        y => y(2),
        oe => oe,
        done => line_done(2)
    );


    line3: entity work.draw_line
    port map (
        clk => clk,
        start => start_drawing_line(3),
        x1 => x1,
        y1 => y1,
        x2 => x2,
        y2 => y2,
        x => x(3),
        y => y(3),
        oe => oe,
        done => line_done(3)
    );



    wren <= '1' when lower_video_on = '1' or upper_video_on = '1' else '0';
    rdaddress <= std_logic_vector(to_unsigned(plot_addr2_rd, rdaddress'length)) ;--when upper_video_on = '1' else (others => '0');
    wraddress <= std_logic_vector(to_unsigned(plot_addr2_wr, rdaddress'length)) when wren = '1' else (others => '0');
    data <= "1" when lower_video_on = '1' else "0";
    start_drawing_line(0) <= '1' when lower_video_on = '1' and line_select = 0 and lower_pixel_y > 4 and pixel_x = SINGLE_FFT_DELAY + 1 else '0';
    start_drawing_line(1) <= '1' when lower_video_on = '1' and line_select = 1 and pixel_x = SINGLE_FFT_DELAY + 1 else '0';
    start_drawing_line(2) <= '1' when lower_video_on = '1' and line_select = 2 and pixel_x = SINGLE_FFT_DELAY + 1 else '0';
    start_drawing_line(3) <= '1' when lower_video_on = '1' and line_select = 3 and pixel_x = SINGLE_FFT_DELAY + 1 else '0';
    
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
    line_select_out(0) <= '1' when (x_wr /= x(0) or y_wr /= y(0)) and line_done(0) = '0' else '0';
    line_select_out(1) <= '1' when (x_wr /= x(1) or y_wr /= y(1)) and line_done(1) = '0' else '0';
    line_select_out(2) <= '1' when (x_wr /= x(2) or y_wr /= y(2)) and line_done(2) = '0' else '0';
    line_select_out(3) <= '1' when (x_wr /= x(3) or y_wr /= y(3)) and line_done(3) = '0' else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if line_select_out(0) = '1'  then
                x_wr <= x(0);
                y_wr <= y(0);
            elsif line_select_out(1) = '1' then
                x_wr <= x(1);
                y_wr <= y(1);
            elsif line_select_out(2) = '1'  then
                x_wr <= x(2);
                y_wr <= y(2);
            elsif line_select_out(3) = '1'  then
                x_wr <= x(3);
                y_wr <= y(3);
            end if;            
        end if;

    end process;

    lower_pixel_y_div_2 <= lower_pixel_y / 2;
    lower_pixel_x <= pixel_x / 4;
    data_pixel <= pixel_array(lower_pixel_x) when lower_pixel_y < Y_LIMIT and pixel_x < X_LIMIT else (others => '0');
    
    red <= "1111" when lower_video_on = '1' and pixel_x = SINGLE_FFT_DELAY else
           "1111" when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else
           data_pixel(7 downto 4) when lower_video_on = '1' else
           "0000";

    
    blue <= data_pixel(15 downto 12)       when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else 
            "0000"                         when lower_video_on = '1' and data_pixel(11 downto 8)  /= "0000" else
            not data_pixel(7 downto 4)     when lower_video_on = '1' and data_pixel(7 downto 4)   /= "0000" else
            data_pixel(3 downto 0)         when lower_video_on = '1' else 
            "0000";

    green <= "1111" when upper_video_on = '1' and q(0) = '1' else
            "1111" when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else
             data_pixel(11 downto 8) when lower_video_on = '1' else
             "0000";

    lower_video_on <= '1' when video_on = '1' and pixel_y >= UPPER_RECT_Y_LIMIT else '0';
    upper_video_on <= '1' when video_on = '1' and pixel_y < Y_LIMIT else '0' ;
    lower_pixel_y <= pixel_y - UPPER_RECT_Y_LIMIT;
    

    process(clk)
    variable pixel_addr: unsigned(14 downto 0) := (others => '0'); 
    variable current_column: integer range 0 to 199 := 0;
    variable col_x: integer range 0 to 1023  := 0;
    variable row_y : integer := 0;
    variable pixel_counter_x, pixel_counter_y: integer range 0 to 31 := 0;
    begin
        if rising_edge(clk) then
            if lower_video_on = '1' and lower_pixel_y mod 2 = 0 then
                if pixel_x = 0 then
                    pixel_counter_x := 0;
                end if;
                if pixel_counter_x = 0 then
                    pixel_counter_x := pixel_counter_x + 1;
                    if lower_pixel_y < Y_LIMIT and pixel_x < X_LIMIT then
                        row_y := (current_column * N_DIV_2) + lower_pixel_y_div_2;
                        pixel_addr := to_unsigned(row_y, addressA'length);
                        col_x := lower_pixel_x;
                        current_column := last_column + col_x;
                        addressA <= std_logic_vector(pixel_addr);
                        pixel_array(col_x) <= qA;
                    end if;
                else
                    if pixel_counter_x = 3 then
                        pixel_counter_x := 0;
                    else
                        pixel_counter_x := pixel_counter_x + 1;
                    end if;
                    if pixel_x < X_LIMIT and lower_pixel_y < Y_LIMIT then
                        pixel_array(col_x) <= qA;
                    else
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end architecture arch;