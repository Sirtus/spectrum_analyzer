library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;
use work.trigonometric.all;

entity butterfly is
    port (
        clk:in std_logic;
        transform: in std_logic;
        transformed: out std_logic;
        x, y: in cplx;
        alpha: in integer range 0 to N/2; 
        Sa, Sb : out cplx
    );
end entity butterfly;

architecture rtl of butterfly is
    type butterfly_sm is (idle, read_from_rom, trns, trns2);
    signal state : butterfly_sm := idle;
    signal w_i, w_r: integer range -512 to 512;
    signal Sb_r, Sb_i: integer range -20000 to 20000 := 0;
    signal x_v, y_v: cplx := (0,0);
    signal x_r, y_r: cplx := (0,0);
    signal Sb_r_v, Sb_i_v: integer := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
            
                when idle =>
                    transformed <= '0';
                    if transform = '1' then
                        state <= trns;
                        x_r(0) <= x(0);
                        x_r(1) <= x(1);
                        y_r(0) <= y(0);
                        y_r(1) <= y(1);
                        w_r <= cos_from_table(alpha);
                        w_i <= sin_from_table(alpha);
                    end if;

                when trns =>
                    Sa(0) <= (x_v(0) + Sb_r);
                    Sa(1) <= (x_v(1) + Sb_i);
                    Sb(0) <= (x_v(0) - Sb_r);
                    Sb(1) <= (x_v(1) - Sb_i);
                    transformed <= '1';
                    state <= idle;

                when others =>
                    state <= idle;
            
            end case;
        end if;
    end process;
    
    y_v(0) <= y_r(0)/10000 when y_r(0) > 100000 or y_r(0) < -100000 else 
    y_r(0)/7000 when y_r(0) > 60000 or y_r(0) < -60000 else
    y_r(0)/4096 when y_r(0) > 40000 or y_r(0) < -40000  else
    y_r(0)/2048 when y_r(0) > 20000 or y_r(0) < -20000  else
    y_r(0)/1024 when y_r(0) > 8000 or y_r(0) < -8000 else
    y_r(0);
    
    
    y_v(1) <= y_r(1)/10000 when y_r(1) > 100000 or y_r(1) < -100000 else 
    y_r(1)/7000 when y_r(1) > 60000 or y_r(1) < -60000 else
    y_r(1)/4096 when y_r(1) > 40000 or y_r(1) < -40000  else
    y_r(1)/2048 when y_r(1) > 20000 or y_r(1) < -20000  else
    y_r(1)/1024 when y_r(1) > 8000 or y_r(1) < -8000 else
    y_r(1);
    
    x_v(0) <= x_r(0)/10000 when x_r(0) > 100000 or x_r(0) < -100000 else 
    x_r(0)/7000 when x_r(0) > 60000 or x_r(0) < -60000 else
    x_r(0)/4096 when x_r(0) > 40000 or x_r(0) < -40000  else
    x_r(0)/2048 when x_r(0) > 20000 or x_r(0) < -20000  else
    x_r(0)/1024 when x_r(0) > 8000 or x_r(0) < -8000 else
    x_r(0);
    
    x_v(1) <= x_r(1)/10000 when x_r(1) > 100000 or x_r(1) < -100000 else 
    x_r(1)/7000 when x_r(1) > 60000 or x_r(1) < -60000 else
    x_r(1)/4096 when x_r(1) > 40000 or x_r(1) < -40000  else
    x_r(1)/2048 when x_r(1) > 20000 or x_r(1) < -20000  else
    x_r(1)/1024 when x_r(1) > 8000 or x_r(1) < -8000 else
    x_r(1);
    
    Sb_r_v <= ((w_r * y_v(0)) - (w_i * y_v(1)));
    Sb_i_v <= ((w_i * y_v(0)) + (w_r * y_v(1)));
    Sb_r <= Sb_r_v/512;
    Sb_i <= Sb_i_v/512;
    
end architecture rtl;