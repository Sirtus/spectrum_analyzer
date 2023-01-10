library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.common.all;


entity fft_tb2 is
end fft_tb2;

architecture sim of fft_tb2 is

    type ram_type is array (0 to  2*N) of std_logic_vector(15 downto 0);

    signal rm: ram_type := (others => (others => '0'));

    signal ipt1: isignal_t := (
        1, 2, 3, 4, 5,6, 7, 4,4,3,7,89,3,4,
        1,-1,-5,-6,-73,-5, 5, 7, 3, 3,7 ,7 ,
        others => '0'
    );

    signal ipt2: isignal_t := (
        1, 2, 3, 4, 5,6, 7, 4,4,3,7,89,3,4,
        1,-1,-5,-6,-73,-5, 5, 7, 3, 3,7 ,7 ,
        others => '0'
    );

    constant clk_period : time := 10 ps;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal switch: std_logic := '1';
    signal done_f: std_logic := '0';
    signal last_column: integer;

    signal addressA, addressB: std_logic_vector(14 downto 0);
    signal dataA, dataB, qA, qB: std_logic_vector(15 downto 0);
    signal fifoA_calculated_column, fifoB_calculated_column: unsigned(LOG_N-1 downto 0) := (others => '0');
    signal fifoA_addr_a, fifoA_addr_b, fifoB_addr_a, fifoB_addr_b: std_logic_vector(8 downto 0);
    signal fifoA_q_a, fifoA_q_b, fifoB_q_a, fifoB_q_b: std_logic_vector(11 downto 0);
    signal wrA, wrB: std_logic;

    signal wr_en, do_fft: std_logic := '1';
    signal done: std_logic := '0';

begin

    clk <= not clk after clk_period / 2;

--    fft: entity work.fft
--    port map(
--        clk => clk,
--        data_i => data,
--        do_fft=> do_fft,
--        done=> done,
--        res=> res
--    );

    fft: entity work.fft
    port map(clk => clk,  do_fft => switch, done => done_f, wr_en => wr_en, 
    last_column => last_column, general_ram_addr => addressB, general_ram_data => dataB, 
    general_ram_wren => wrB, fifoA_addr => fifoA_calculated_column, fifoB_addr => fifoB_calculated_column,
    fifoA_q => fifoA_q_b, fifoB_q => fifoB_q_b);

    fifoA_addr_b <= '0' & std_logic_vector(fifoA_calculated_column);
    fifoB_addr_b <= '0' & std_logic_vector(fifoB_calculated_column);

    process(clk)
    begin
        fifoA_q_b <= ipt1(fifoA_addr_b);
        fifoB_q_b <= ipt2(fifoB_addr_b);
    end process;


end architecture;