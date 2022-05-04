library IEEE;
use ieee.math_real.all;
package common is
    
    type queue_t is array(0 to 31) of integer range -300 to 600;
    type cplx is array(0 to 1) of integer range -100000 to 100000;
    

    constant N: integer := queue_t'high + 1;
    constant LOG_N: integer := integer(ceil(log2(real(N))));
    constant WORD_LEN: integer := 9;

end package common;