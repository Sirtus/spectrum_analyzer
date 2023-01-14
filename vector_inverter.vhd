library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;

entity vector_inverter is
    port (
        counter_n: in unsigned(WORD_LEN-1 downto 0);
        counter_n_inversed1: out unsigned(LOG_N-1 downto 0):= to_unsigned(1, LOG_N);
        counter_n_inversed2: out unsigned(LOG_N-1 downto 0):= to_unsigned(N-2, LOG_N)
    );
end entity vector_inverter;

architecture arch of vector_inverter is
    signal counter_n2: unsigned(WORD_LEN-1 downto 0) := to_unsigned(7, WORD_LEN);
begin
    counter_n2 <= counter_n when counter_n > 0 else to_unsigned(7, counter_n2'length);
        
    INVERT_VEC: for i in 0 to LOG_N -2 generate
        counter_n_inversed1(i) <= counter_n2(LOG_N-1 - i);
        counter_n_inversed2(i) <= counter_n2(LOG_N-1 - i);
    end generate INVERT_VEC;
    counter_n_inversed1(LOG_N-1) <= '0';
    counter_n_inversed2(LOG_N-1) <= '1'; 
    
end architecture arch;