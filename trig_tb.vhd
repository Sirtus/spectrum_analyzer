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
        variable v: integer:= 0;
    begin
        for i in  0 to 32 loop
            v := app_sin(i);
            report "sin(" & integer'image(i) & ") = " & integer'image(v);
        end loop;
        wait;
    end process;


end architecture;