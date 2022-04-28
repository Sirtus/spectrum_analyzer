library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;
use work.trigonometric.all;

entity butterfly is
    port (
        x, y: in cplx;
        alpha: in integer range 0 to 100; 
        Sa, Sb : out cplx
    );
end entity butterfly;

architecture rtl of butterfly is
    
begin
    
    process(x, y, alpha)
    variable w_r: integer range -100 to 100;
    variable w_i: integer range -100 to 100;
    variable Sb_r, Sb_i: integer range -1000 to 1000 := 0;
    begin
        -- report "x: " & integer'image(x(0)) & " " & integer'image(x(1)) ;
        -- report "y: " & integer'image(y(0)) & " " & integer'image(y(1)) ;
        w_r := cos_from_table(alpha);
        w_i := sin_from_table(alpha);
        Sb_r := ((w_r * y(0)) + (w_i * y(1)));
        Sb_i := ((w_i * y(0)) + (w_r * y(1)));
        Sa(0) <= x(0) + Sb_r;
        Sa(1) <= x(1) + Sb_i;
        Sb(0) <= x(0) - Sb_r;
        Sb(1) <= x(1) - Sb_i;
        report "alpha: " & integer'image(alpha);
        report "w_r: " & integer'image(w_r);
        report "w_i: " & integer'image(w_i);
        -- report "Sb_r: " & integer'image(Sb_r);
        -- report "Sb_i: " & integer'image(Sb_i);
        -- report "Sa: " & integer'image(Sa(0)) & ", " & integer'image(Sa(1));
        -- report "Sb: " & integer'image(Sb(0)) & ", " & integer'image(Sb(1));
    end process;
    
end architecture rtl;