library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;
use work.sin_cos.all;

entity dft is
    port (
        clk: in std_logic;
        data: in queue_t;
        result: out queue_t;
        read_en: in std_logic;
        is_computed: out std_logic
    );
end entity dft;

architecture arch of dft is
    type state_t is (idle, compute);
    signal state_m: state_t := idle;
    
    signal x: queue_t := (others => 0);
    signal res_re, res_im: queue_t := (others => 0);
    signal res: queue_t := (others => 0);
begin
    
    process(clk)
    variable counter: integer range 0 to 1000 := 0;
    variable idx: integer range 0 to 1000 := 0;
    variable re_tmp, im_tmp: integer range 0 to 100 := 0;
    variable arg_tmp: integer := 0;
    begin
        if rising_edge(clk) then
            case state_m is
                when idle =>
                    is_computed <= '0';
                    if read_en = '1' then
                        x <= data;
                        state_m <= compute;
                        idx := 0;
                        counter := 0;
                    else
                        state_m <= idle;
                    end if;
            
                when compute =>
                    if idx = 800 then
                        is_computed <= '1';
                        state_m <= idle;
                    else
                        arg_tmp := (63 * idx * counter) / 800;
                        re_tmp := cos(arg_tmp);
                        im_tmp := sin(arg_tmp);
                        res_re(idx) <= res_re(idx) + re_tmp;
                        res_im(idx) <= res_im(idx) + im_tmp;
                        if counter = 799 then
                            res_re(idx) <= res_re(idx) / 100;
                            res_im(idx) <= res_im(idx) / 100;
                            counter := 0;
                            idx := idx + 1;
                        else
                            counter := counter + 1;
                        end if;   
                    end if;

                when others =>
                    state_m <= idle;
            
            end case;
        end if;
    end process;

    result <= res_im;
    
end architecture arch;