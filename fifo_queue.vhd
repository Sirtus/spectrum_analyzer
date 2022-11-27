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
        fifoA_addr_a: out std_logic_vector(8 downto 0);
        fifoA_data_a: out std_logic_vector(11 downto 0);
        fifo_last_column: out unsigned(LOG_N-1 downto 0)
    );
end queue;

architecture arch of queue is
    signal data: isignal_t := (others => 0);
    type queue_state is (idle, write_to_array);
    signal state: queue_state := write_to_array; 
    signal ram_address: std_logic_vector(8 downto 0);
    signal ram_data: std_logic_vector(11 downto 0);
    signal last_column: unsigned(LOG_N-1 downto 0) := (others => '0');
begin
    
    COLLECT_DATA: process(clk)
    variable temp: integer range -600 to 600 := 0;
    type queue_state is (idle, write_to_array);
    variable queue_s: queue_state := write_to_array;
    begin
        if rising_edge(clk) then
            case queue_s is
                when idle =>
                    if wr_en = '0' then
                        queue_s := write_to_array;
                    end if;
                when write_to_array =>
                    if wr_en = '1' then
                        last_column <= last_column + 1;
                        temp :=(to_integer(signed(data_in(23 downto 10))) + 427)/4 ;
                        ram_data <= std_logic_vector(to_signed(temp, ram_data'length));
                        ram_address <= '0' & std_logic_vector(last_column);
                        queue_s := idle;
                    end if;
            
                when others =>
                    
            
            end case;

        end if;
    end process;
    fifoA_addr_a <= ram_address;
    fifoA_data_a <= ram_data;
    fifo_last_column <= last_column;
    
end architecture arch;