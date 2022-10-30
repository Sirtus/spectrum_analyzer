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
        do: in std_logic_vector(15 downto 0)
        -- do_int: in integer range 0 to 600
    );
end entity plot_controller;

architecture arch of plot_controller is
    signal point_x: integer := 0;
    signal point_y: integer := 0;
    signal que: std_logic_vector(15 downto 0);
    
begin

    process(clk)
    begin
        if rising_edge(clk)   then
            if video_on = '1' and pixel_y <= 256 and pixel_x <= 128 then
                if que(15 downto 12) /= "0000" then
                    blue <= "0000";
                    green <= not que(15 downto 12);
                else
                    blue <= que(7 downto 4); 
                    green <= que(11 downto 8);
                end if;
                -- green <= que(11 downto 8);
                -- blue <= "0000";-- when video_on = '1' and pixel_y = 300 else "0000";
                red <= que(15 downto 12);
                -- blue <= que(7 downto 4); 
                -- green <= que(11 downto 8);
            else
                green <= "0000";
                blue <= "0000";-- when video_on = '1' and pixel_y = 300 else "0000";
                red <= "0000";
            end if;
        end if;
    end process;
    que <= do;

    -- red <=   do(7 downto 4) when video_on = '1' and pixel_y <= 512 and pixel_x <= 128 else "0000";
    -- blue <= do(15 downto 12) when video_on = '1' and pixel_y <= 512 and pixel_x <= 128 else "0000";
    -- blue <= "0000";-- when video_on = '1' and pixel_y = 300 else "0000";
    -- red <= "0000";
    -- green <= "1111" when video_on = '1' and pixel_y <= que_cos(pixel_x/100) else "0000";
        -- green <= que(11 downto 8) when video_on = '1' and pixel_y <= 128 and pixel_x <= 128 else "0000";
        -- green <= "1111" when video_on = '1' and pixel_x < 32 and pixel_y = que_cos(pixel_x)+300 else "0000";
--pixel_y >= (600 - que_cos(pixel_x/100))
    
end architecture arch;