library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.trigonometric.all;
use work.common.all;

entity trig_tb is
end trig_tb;

architecture sim of trig_tb is


begin

    process is
        variable v_sin, v_cos: integer:= 0;
    begin
        for i in  0 to 32 loop
            v_sin := app_sin(i);
            report "sin(" & integer'image(i) & ") = " & integer'image(v_sin);
        end loop;
        for i in  0 to 32 loop
            v_cos := app_cos(i);
            report "cos(" & integer'image(i) & ") = " & integer'image(v_cos);
        end loop;
        
        wait;
        
    end process;


end architecture;