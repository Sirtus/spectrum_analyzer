library IEEE;
use ieee.math_real.all;
package common is
    constant N: integer := 128;
    constant LOG_N: integer := integer(ceil(log2(real(N))));
    constant WORD_LEN: integer := 9;
	 
    type queue_t is array(0 to 511) of integer range -300 to 600;
    type isignal_t is array(0 to N-1) of integer range -600 to 600;
    type osignal_t is array(0 to (N/2)-1) of integer range 0 to 600;
    type cplx is array(0 to 1) of integer;
    



end package common;