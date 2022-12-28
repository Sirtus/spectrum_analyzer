library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.trigonometric.all;
use work.common.all;

entity sin_test is
    port (
        res: out queue_t := (others => 0)
    );
end sin_test;

architecture rtl of sin_test is
    signal res_out: queue_t := (others => 0);
begin

    sin_proc : for i in 0 to queue_t'high generate
        res_out(i) <= 300 - app_sin(i);
    end generate;
    
    res <= res_out;

end architecture;