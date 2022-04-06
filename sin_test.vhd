library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.trigonometric.all;
use work.common.all;

entity cos_test is
    port (
        res: out queue_t := (others => 0)
    );
end cos_test;

architecture rtl of cos_test is
    signal res_out: queue_t := (others => 0);
begin

    g : for i in 0 to 799 generate
        res_out(i) <= 300 - app_sin(i);
    end generate;
    
    res <= res_out;

end architecture;