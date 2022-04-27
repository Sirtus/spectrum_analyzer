library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;
use work.trigonometric.all;

entity butterfly is
    port (
        x, y: in cplx;
        alpha: in integer; 
        Sa, Sb : out cplx
    );
end entity butterfly;

architecture rtl of butterfly is
    
begin
    
    process(x, y, alpha)
    variable w_r: integer range -100 to 100;
    variable w_i: integer range -100 to 100;
    begin
        w_r := app_cos(alpha);
        w_i := app_sin(alpha);
        Sa(0) <= x(0) + (w_r * y(0))/100;
        Sa(1) <= x(1) + (w_i * y(1))/100;
        Sb(0) <= x(0) - (w_r * y(0))/100;
        Sb(1) <= 5;--x(1) - (w_i * y(1))/100;
        -- report "Sa: " & integer'image(alpha);
        report "w_r: " & integer'image(w_r);
        -- report "Sa: " & integer'image(Sa(0)) & ", " & integer'image(Sa(1));
        -- report "Sb: " & integer'image(Sb(0)) & ", " & integer'image(Sb(1));
    end process;
    
end architecture rtl;