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
    type butterfly_sm is (idle, read_from_rom, trns1, trns2 );
    signal state : butterfly_sm := idle;
    signal w_i, w_r: integer range -512 to 512;
    signal Sb_r, Sb_i: integer range -20000 to 20000 := 0;
begin

    process(clk)
    variable Sb_r_v, Sb_i_v: integer := 0;
    begin
        if rising_edge(clk) then
            case state is
            
                when idle =>
                    transformed <= '0';
                    if transform = '1' then
                        state <= read_from_rom;
                    end if;
            
                when read_from_rom =>
                    w_r <= cos_from_table(alpha);
                    w_i <= sin_from_table(alpha);
                    state <= trns1 ;
                
                when trns1 =>
                    Sb_r_v := ((w_r * y(0)) - (w_i * y(1)));
                    Sb_i_v := ((w_i * y(0)) + (w_r * y(1)));
                    Sb_r <= Sb_r_v/512;
                    Sb_i <= Sb_i_v/512;
                    
                    state <= trns2;

                when trns2 =>
                    Sa(0) <= (x(0) + Sb_r);
                    Sa(1) <= (x(1) + Sb_i);
                    Sb(0) <= (x(0) - Sb_r);
                    Sb(1) <= (x(1) - Sb_i);
                    transformed <= '1';
                    state <= idle;

                when others =>
                    state <= idle;
            
            end case;
        end if;
    end process;
    
    -- process(x, y, alpha)
    -- variable w_r: integer range -512 to 512;
    -- variable w_i: integer range -512 to 512;
    -- variable Sb_r, Sb_i: integer range -20000 to 20000 := 0;
    -- begin
    --     -- report "x: " & integer'image(x(0)) & " " & integer'image(x(1)) ;
    --     -- report "y: " & integer'image(y(0)) & " " & integer'image(y(1)) ;
    --     w_r := cos_from_table(alpha);
    --     w_i := sin_from_table(alpha);
    --     Sb_r := ((w_r * y(0)) - (w_i * y(1)))/512;
    --     Sb_i := ((w_i * y(0)) + (w_r * y(1)))/512;
    --     Sa(0) <= (x(0) + Sb_r);
    --     Sa(1) <= (x(1) + Sb_i);
    --     Sb(0) <= (x(0) - Sb_r);
    --     Sb(1) <= (x(1) - Sb_i);
    --     -- report "alpha: " & integer'image(alpha);
    --     -- report "w_r: " & integer'image(w_r);
    --     -- report "w_i: " & integer'image(w_i);
    --     -- report "Sb_r: " & integer'image(Sb_r);
    --     -- report "Sb_i: " & integer'image(Sb_i);
    --     -- report "Sa: " & integer'image(Sa(0)) & ", " & integer'image(Sa(1));
    --     -- report "Sb: " & integer'image(Sb(0)) & ", " & integer'image(Sb(1));
    -- end process;
    
end architecture rtl;