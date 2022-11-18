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
        do: in std_logic_vector(15 downto 0);
        last_column: in integer range 0 to 255;
        addressA: out std_logic_vector(14 downto 0);
        qA: in std_logic_vector(15 downto 0)
        -- do_int: in integer range 0 to 600
    );
end entity plot_controller;

architecture arch of plot_controller is

    constant UPPER_RECT_Y_LIMIT:integer := 344;

    constant X_LIMIT: integer := 799;
    constant Y_LIMIT: integer := 256;
    
    signal point_x: integer range 0 to 2047 := 0;
    signal point_y: integer range 0 to 2047 := 0;
    signal que: std_logic_vector(15 downto 0);

    signal col_y: integer range 0 to 1023 := 0;
    signal data_pixel: std_logic_vector(15 downto 0) := (others => '0');

    signal lower_pixel_y: integer := 0;
    signal lower_video_on, upper_video_on: std_logic := '1';

    type pixel_array_t is array(0 to 199) of std_logic_vector(15 downto 0);
    signal pixel_array: pixel_array_t;
    type single_fft_array is array(0 to 127) of integer range 0 to 255;
    signal single_fft: single_fft_array;

    signal upper_rect_x: integer range 0 to 128 := 0;
begin


    data_pixel <= pixel_array(pixel_x/4) when lower_pixel_y < Y_LIMIT and pixel_x < X_LIMIT else (others => '0');
    single_fft(lower_pixel_y/2) <= to_integer(unsigned(pixel_array(128)(15 downto 8))) when pixel_x = 512 and lower_video_on = '1';
    
    red <= "1111" when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else
           data_pixel(7 downto 4) when lower_video_on = '1' else
           "0000";

    
    blue <= data_pixel(15 downto 12)       when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else 
            "0000"                         when lower_video_on = '1' and data_pixel(11 downto 8)  /= "0000" else
            not data_pixel(7 downto 4)     when lower_video_on = '1' and data_pixel(7 downto 4)   /= "0000" else
            data_pixel(3 downto 0)         when lower_video_on = '1' else 
            "0000";

    green <= "1111" when upper_video_on = '1' and pixel_y = single_fft(upper_rect_x) else
            "0000" when upper_video_on = '1' else 
            "1111" when lower_video_on = '1' and data_pixel(15 downto 12) /= "0000" else
             data_pixel(11 downto 8) when lower_video_on = '1' else
             "0000";

    lower_video_on <= '1' when video_on = '1' and pixel_y >= UPPER_RECT_Y_LIMIT else '0';
    upper_video_on <= '1' when video_on = '1' and pixel_y < Y_LIMIT else '0';
    lower_pixel_y <= pixel_y - UPPER_RECT_Y_LIMIT;
    upper_rect_x <= pixel_x/6;

    process(clk)
    variable pixel_addr: unsigned(14 downto 0) := (others => '0'); 
    variable current_column: integer range 0 to 199 := 0;
    variable col_x: integer range 0 to 1023  := 0;
    variable row_y : integer := 0;
    variable pixel_counter_x, pixel_counter_y: integer range 0 to 31 := 0;
    begin
        if rising_edge(clk) then
            if lower_video_on = '1' and lower_pixel_y mod 2 = 0 then
                if pixel_counter_x = 0 then
                    pixel_counter_x := pixel_counter_x + 1;
                    if lower_pixel_y < Y_LIMIT and pixel_x < X_LIMIT then
                        row_y := (current_column * N_DIV_2) + lower_pixel_y/2;
                        pixel_addr := to_unsigned(row_y, addressA'length);
                        col_x := pixel_x / 4;
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