library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity i2s_receiver is
    generic(
        sclk_ws_ratio: integer := 32;
        d_width: integer := 24
    );
    port (
        sclk: in std_logic;
        ws: out std_logic;
        sel: out std_logic;
        d_rx: in std_logic;

        l_data: out std_logic_vector(d_width-1 downto 0);
        r_data: out std_logic_vector(d_width-1 downto 0);

        read_en: out std_logic
    );
end entity i2s_receiver;

architecture rtl of i2s_receiver is
    signal ws_int: std_logic := '0';
    signal l_data_int: std_logic_vector(d_width-1 downto 0) := (others => '0');
    signal r_data_int: std_logic_vector(d_width-1 downto 0) := (others => '0');
    signal sel_int : std_logic := '0';
begin
    
    process(sclk)
        variable ws_counter: integer := 0;
    begin
        if falling_edge(sclk) then
            read_en <= '0';
            if ws_int = '0' then
                if ws_counter = sclk_ws_ratio-1 then
                    ws_counter := 0;
                    ws_int <= '1';
                    read_en <= '0';
                    l_data <= l_data_int;
                    l_data_int <= (others => '0');
                else
                    if ws_counter >= 0 and ws_counter < d_width  then
                        l_data_int <= l_data_int(d_width-2 downto 0) & d_rx;
                    end if;
                    ws_counter := ws_counter + 1;
                end if;
            else
                if  ws_counter = sclk_ws_ratio-1 then
                    ws_counter := 0;
                    ws_int <= '0';
                    sel_int <= not sel_int;
                    read_en <= '1';
                    r_data <= r_data_int;
                else
                    if ws_counter >= 0 and  ws_counter < d_width then
                        r_data_int <= r_data_int(d_width-2 downto 0) & d_rx;
                    end if;
                    ws_counter := ws_counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    ws <= ws_int;
    sel <= '0';

end architecture rtl;
