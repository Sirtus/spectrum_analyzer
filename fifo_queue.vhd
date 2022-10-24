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
        do_fft: in std_logic;
        data_out: out isignal_t
    );
end queue;

architecture arch of queue is
    signal data: isignal_t := (others => 0);
    type queue_state is (idle, write_to_array);
    signal state: queue_state := write_to_array; 
begin
    
    process(clk)
        variable temp: integer range -600 to 600 := 0;
    begin
        if rising_edge(clk) then
            case state is
                when idle =>
                    if wr_en = '0' then
                        state <= write_to_array;
                    end if;
                when write_to_array =>
                    if wr_en = '1' and do_fft = '1' then
                        temp :=(to_integer(signed(data_in(23 downto 10))) + 427)/4 ;
                        data <= temp & data(0 to data'high-1);
                        state <= idle;
                    end if;
            
                when others =>
                    
            
            end case;

        end if;
    end process;
    data_out <= data;
    
end architecture arch;