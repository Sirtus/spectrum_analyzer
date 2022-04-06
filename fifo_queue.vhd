library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity queue is
    port(
        clk: in std_logic;
        wr_en: in std_logic;
        data_in: in std_logic_vector(23 downto 0);
        data_out: out queue_t
    );
end queue;

architecture arch of queue is
    signal data: queue_t := (others => 600);
    constant c: integer := 200;
    constant r: real := 0.000035763;
begin
    
    process(clk)
        variable temp: integer;
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                temp := to_integer(unsigned(data_in(20 downto 12)));
                data <= temp & data(0 to 254);
            end if;
        end if;
    end process;
    data_out <= data;
    
end architecture arch;