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
    signal data, result: queue_t := (others => 0);
    signal read_en : std_logic := '1';

begin
    data <= ccc;
    clk <= not clk after clk_period / 2;

    DUT : entity work.dft
    --generic map( data_len => 10)
    port map (
        clk => clk,
        data => data,
        result => result,
        read_en => read_en,
        is_computed => open
        
    );


end architecture;