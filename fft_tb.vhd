library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.common.all;


entity fft_tb is
end fft_tb;

architecture sim of fft_tb is

    constant clk_period : time := 10 ps;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';

    signal res: queue_t := (others => 0);
    -- signal data: queue_t := 
    -- (
    --     0 , 9 , 19 , 29 , 38 , 47 , 56 , 64 , 71 , 78 , 
    --     84 , 89 , 93 , 96 , 98 , 99 , 99 , 99 , 97 , 94 , 
    --     90 , 86 , 80 , 74 , 67 , 59 , 51 , 42 , 33 , 23 , 
    --     14 , 4 
    -- );
    signal data: queue_t := 
    (
        35, 35, 64, 106, 35, -106, -135,-35 
        -- 170, 170, 199, 241, 170, 29, 0, 100
        -- 255,12, 123, 255, 3, 12, 255, 12
        -- 0, 1, 2, 3, 4, 5, 6, 7
    );
    signal do_fft: std_logic := '1';
    signal done: std_logic := '0';

begin

    clk <= not clk after clk_period / 2;

    fft: entity work.fft
    port map(
        clk => clk,
        data_i => data,
        do_fft=> do_fft,
        done=> done,
        res=> res
    );


end architecture;