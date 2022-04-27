library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;


entity ram is
    port (
        addrAi: in integer range 0 to N*2;
        addrBi: in integer range 0 to N*2;
        addrAo: in integer range 0 to N*2;
        addrBo: in integer range 0 to N*2;
        dataAi: in cplx ;
        dataBi: in cplx ;
        dataAo: out cplx ;
        dataBo: out cplx ;
        wr, rd: in std_logic
    );
end entity ram;

architecture rtl of ram is
    type ram_type is array(0 to N) of cplx;
    signal ram_arr : ram_type := (others => (others => 0));    
begin
    
    process(rd, wr,addrAi, addrAo, addrBi, addrBo)
    begin
        if wr = '1' then
            ram_arr(addrAi) <= dataAi;
            ram_arr(addrBi) <= dataBi;
            report "w ram: " & integer'image(addrAi) & "i: " & integer'image(dataAi(0));
            report "w ram: " & integer'image(addrBi) & "i: " & integer'image(dataBi(0));
        end if;
        if rd = '1' then
            dataAo <= ram_arr(addrAo);
            dataBo <= ram_arr(addrBo);
            report "r ram: " & integer'image(addrAo) & "i: " & integer'image(ram_arr(addrAo)(0));
            report "r ram: " & integer'image(addrBo) & "i: " & integer'image(ram_arr(addrBo)(0));
        end if;
        
        
        
            

    end process;
    
end architecture rtl;