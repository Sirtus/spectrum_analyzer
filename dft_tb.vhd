library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.common.all;

entity dft_tb is
end dft_tb;

architecture sim of dft_tb is

    constant clk_period : time := 10 ps;

    signal clk : std_logic := '1';
    signal res: queue_t := (others => 0);

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.dft_test
    port map (
        clk => clk,
        res => res    
    );


end architecture;