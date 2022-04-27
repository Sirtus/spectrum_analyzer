library IEEE;
use ieee.math_real.all;
package common is
    
    type queue_t is array(0 to 7) of integer range -30000 to 60000;
    type cplx is array(0 to 1) of integer;-- range -1000 to 1000;
    

    constant N: integer := queue_t'high + 1;
    constant LOG_N: integer := integer(ceil(log2(real(N))));

end package common;