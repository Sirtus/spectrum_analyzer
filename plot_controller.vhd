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
        addressA: out std_logic_vector(13 downto 0);
        qA: in std_logic_vector(15 downto 0)
        -- do_int: in integer range 0 to 600
    );
end entity plot_controller;

architecture arch of plot_controller is
    signal point_x: integer range 0 to 2047 := 0;
    signal point_y: integer range 0 to 2047 := 0;
    signal que: std_logic_vector(15 downto 0);

    signal col_y: integer range 0 to 1023 := 0;
    signal data_pixel: std_logic_vector(15 downto 0) := (others => '0');

    type pixel_array_t is array(0 to 255) of std_logic_vector(15 downto 0);
    signal pixel_array: pixel_array_t;
begin

    process(clk)
    begin
        if rising_edge(clk)   then
            if pixel_y < 256 and pixel_x < 512 then
                data_pixel <= pixel_array(pixel_x/4);
            else
                data_pixel <= (others => '0') ;
            end if;
            if video_on = '1' then
                if data_pixel(15 downto 12) /= "0000" then
                    red <= "1111";
                    -- blue <= "0000";
                    -- green <= not data_pixel(15 downto 12);
                else
                    red <= data_pixel(11 downto 8);
                    -- blue <= data_pixel(7 downto 4); 
                    -- green <= data_pixel(11 downto 8);
                end if;
                -- green <= que(11 downto 8);
                -- blue <= "0000";-- when video_on = '1' and pixel_y = 300 else "0000";
                -- red <= data_pixel(15 downto 12);
                blue <= data_pixel(3 downto 0); 
                green <= data_pixel(7 downto 4);
                -- red <= data_pixel(11 downto 8);
                -- blue <= que(7 downto 4); 
                -- green <= que(11 downto 8);
            else
                green <= "0000";
                blue <= "0000";
                red <= "0000";
            end if;
        end if;
    end process;
    -- que <= do;

    process(clk)
    variable pixel_addr: unsigned(13 downto 0) := (others => '0'); 
    variable current_column: integer range 0 to 127 := 0;
    variable col_x, row_y: integer range 0 to 1023 := 0;
    variable pixel_counter_x, pixel_counter_y: integer range 0 to 31 := 0;
    begin
        if rising_edge(clk) then
            if pixel_y mod 4 = 0 then
                if pixel_counter_x = 0 then
                    pixel_counter_x := pixel_counter_x + 1;
                    if pixel_y < 256 and pixel_x < 512 then
                        row_y := (current_column * N_DIV_2) + pixel_y/4;
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
                    if pixel_x < 512 and pixel_y < 256 then
                        pixel_array(col_x) <= qA;
                    else
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end architecture arch;