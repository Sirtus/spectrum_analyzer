library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_tb is
end ram_tb;

architecture sim of ram_tb is

    constant clk_period : time := 10 ps;

    signal clk : std_logic := '1';

    signal dataAi, dataBi, dataAo, dataBo: std_logic_vector(23 downto 0) := (others => '0');

    signal addrA, addrB: std_logic_vector(4 downto 0);
    signal counter_n: unsigned(4 downto 0):= (others => '0');

    signal wr: std_logic := '0';
    signal wr_b: std_logic := '0';
    signal rd: std_logic := '1';  
begin

    clk <= not clk after clk_period / 2;

    ram: entity work.ram_ip
    port map(
        address_a => addrA,
        address_b => addrB,
        clock => clk,
        data_a => dataAi,
        data_b => dataBi,
        wren_a => wr,
        wren_b => wr_b,
        q_a => dataAo,
        q_b => dataBo
    );


    process
    begin
        wait for clk_period*3;
        wait for clk_period;
        wr <= '1';
        wr_b <= '1';
        addrA <= "00000";
        addrB <= "00001";
        dataAi(16 downto 10) <= "0000001";
        dataBi(16 downto 10) <= "0000010";

        wait for clk_period*3;
        wr <= '1';
        wr_b <= '1';
        
        addrA <= "00010";
        addrB <= "00011";
        dataAi(16 downto 10) <= "0000100";
        dataBi(16 downto 10) <= "0000110";

        wait for clk_period*3;
        wr <= '1';
        wr_b <= '1';
        addrA <= "00100";
        addrB <= "00101";
        dataAi(16 downto 10) <= "0010001";
        dataBi(16 downto 10) <= "0010010";

        wait for clk_period*3;
        wr <= '1';
        wr_b <= '1';
        addrA <= "00110";
        addrB <= "00111";
        dataAi(16 downto 10) <= "0000111";
        dataBi(16 downto 10) <= "0001110";

        wait for clk_period *3;
        wr <= '0';
        wr_b <= '0';
        addrA <= "00000";
        addrB <= "00001";
        report "0 data: "& integer'image(to_integer(unsigned(dataAo(16 downto 10)))) ;       
        report "0 data: "& integer'image(to_integer(unsigned(dataBo(16 downto 10)))) ;  

        wait for clk_period*3;
        report "data: "& integer'image(to_integer(unsigned(dataAo(16 downto 10)))) & " 1";       
        report "data: "& integer'image(to_integer(unsigned(dataBo(16 downto 10))))  & " 2";       
        wr <= '0';
        wr_b <= '0';
        addrA <= "00100";
        addrB <= "00101";

        wait for clk_period*2;
        report "2data: "& integer'image(to_integer(unsigned(dataAo(16 downto 10)))) & " 17" ; 
        report "2data: "& integer'image(to_integer(unsigned(dataBo(16 downto 10))))  & " 18";         
        wr <= '0';
        wr_b <= '0';
        addrA <= "00110";
        addrB <= "00111";

        wait for clk_period*2;
        report "3 data: "& integer'image(to_integer(unsigned(dataAo(16 downto 10))))  & " 7";
        report "3data: "& integer'image(to_integer(unsigned(dataBo(16 downto 10)))) & " 14" ;          
        wr <= '0';
        wr_b <= '0';
        addrA <= "00000";
        addrB <= "00001";    

        wait for 100 ps;
    end process;

end architecture;