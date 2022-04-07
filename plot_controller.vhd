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
        do: in queue_t;
        l_data, r_data: in std_logic_vector(23 downto 0)
    );
end entity plot_controller;

architecture arch of plot_controller is
    signal point_x: integer := 0;
    signal point_y: integer := 0;
    signal que_sin: queue_t := (others => 0);
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if pixel_x = 801 and pixel_y = 601 then
                que_sin <= do;
            end if;
        end if;
    end process;

    red <= "0000";-- when video_on = '1' else "0000";
    blue <= "1111" when video_on = '1' and pixel_x < 512 and pixel_y = 300 else "0000";
    -- green <= "1111" when video_on = '1' and ((pixel_y >= 600 - que_sin(pixel_x)/3000 and que_sin(pixel_x) > 0 ) or 
    -- ((pixel_y >= 600 + que_sin(pixel_x)/3000 and que_sin(pixel_x) < 0))) else "0000";
    green <= "1111" when video_on = '1' and pixel_x < 512 and ((pixel_y <= que_sin(pixel_x) and pixel_y >= 300 and que_sin(pixel_x) >= 300) or
    (pixel_y >= que_sin(pixel_x) and pixel_y <= 300 and que_sin(pixel_x) < 300)) else "0000";
    -- green <= "1111" when video_on = '1' and pixel_y = que_sin(pixel_x) else "0000";

    
end architecture arch;