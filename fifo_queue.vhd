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
<<<<<<< HEAD
    signal data: queue_t := (others => 0);
=======
    signal data: queue_t := (others => 600);
>>>>>>> main
begin
    
    process(clk)
        variable temp: integer range -600 to 600 := 0;
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
<<<<<<< HEAD
                temp := to_integer(signed(data_in(18 downto 10))) - 84;
                data <= temp & data(0 to queue_t'high-1);
=======
                -- temp :=(to_integer(unsigned(data_in(23 downto 16)))-242) ;
                -- temp :=(to_integer(signed(data_in(23 downto 15)))) ;
                temp :=(to_integer(signed(data_in(23 downto 10))) + 427) ;
                -- if data_in(23) = '1' then
                --     temp := -100;
                -- else
                --     temp := 100;
                -- end if;
                data <= temp & data(0 to data'high-1);
>>>>>>> main
            end if;
        end if;
    end process;
    data_out <= data;
    
end architecture arch;