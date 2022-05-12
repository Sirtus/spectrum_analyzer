library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mic_rec is
    generic(
        mclk_sclk_ratio: integer := 8;
        sclk_ws_ratio: integer := 64;
        d_width: integer := 24
    );
    port (
        mclk: in std_logic;
        sclk: out std_logic;
        ws: out std_logic;
        d_rx: in std_logic;

        l_data: out std_logic_vector(d_width-1 downto 0);
        r_data: out std_logic_vector(d_width-1 downto 0);

        read_en: out std_logic
    );
end entity mic_rec;

architecture arch of mic_rec is
    
    signal sclk_int: std_logic := '0';
    signal ws_int: std_logic := '0';
    signal l_data_int: std_logic_vector(d_width-1 downto 0) := (others => '0');
    signal r_data_int: std_logic_vector(d_width-1 downto 0) := (others => '0');

begin
    
    process(mclk)
        variable sclk_cnt: integer := 0;
        variable ws_cnt: integer := 0;
    begin
        if falling_edge(mclk) then
            read_en <= '0';
            if sclk_cnt < mclk_sclk_ratio/2 - 1  then
                sclk_cnt := sclk_cnt + 1;
            else
                sclk_cnt := 0;
                sclk_int <= not sclk_int;
                if ws_cnt < sclk_ws_ratio - 1 then
                    ws_cnt := ws_cnt + 1;
                    if sclk_int = '0' and ws_cnt > 1 and ws_cnt < d_width*2 + 2 then
                        if ws_int = '1' then
                            r_data_int <= r_data_int(d_width-2 downto 0) & d_rx;
                        else 
                            
                            l_data_int <= l_data_int(d_width-2 downto 0) & d_rx;
                        end if;
                    end if;
                else
                    ws_cnt := 0;
                    ws_int <= not ws_int;
                    r_data <= r_data_int;
                    l_data <= l_data_int;
                    read_en <= '1';
                end if;
            end if;
        end if;
    end process;
    
    sclk <= sclk_int;
    ws <= ws_int;
    
end architecture arch;