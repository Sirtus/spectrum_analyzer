library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.common.all;
 use work.sin_cos.all;
use ieee.math_real.all;
 
entity dft is
    generic(
        data_len: integer := 256
    );
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
	 signal res_out: queue_t := (others => 0);
	 signal computed: std_logic := '0';
    
    signal x: queue_t := (others => 0);
    signal res_re: queue_t := (others => 0);
    signal res: queue_t := (others => 0);
    signal counter: integer range 0 to 1000 := 0;
    signal idx: integer range 0 to 1000 := 0;
    signal idx2: integer := 31;
    signal re_tmp: integer range -100 to 100 := 0;
    
    signal res_re_tmp: integer := 0;
    signal res_re_next, res_im_next: integer := 0;
    shared variable res_im : queue_t := (others => 0);
	 
--    procedure sin_t(signal x: in integer; signal y: out integer) is
--        variable v, tmp: integer := 0;
--        variable div, x1, x2: integer := 0;
--        begin
--            x2 := x*10000;
--            div := integer(x2 /157079);
--            x1 :=  integer((x2 -div*157079)/1000);
--				if div mod 4 = 1 or div mod 4 = 3 then
--                x1  := 157 - x1;
--            end if;
--            v := x1 - (x1**3)/60000;
--            tmp := x1**3/12000;
--            tmp := (tmp * (x1**2))/1000;
--            v := v + tmp/1000;
--            if div mod 4 = 2 or div mod 4 = 3 then
--                v := v * (-1);
--            end if;
--            y <= v;
--    end procedure;

	 
    function sin_t(x: integer) return integer is
        variable v, tmp: integer := 0;
        variable div, x1, x2: integer := 0;
        begin
            x2 := x*10000;
            div := integer(x2 /157079);
            x1 :=  integer((x2 -div*157079)/1000);
				if div mod 4 = 1 or div mod 4 = 3 then
                x1  := 157 - x1;
            end if;
            v := x1 - (x1**3)/60000;
            tmp := x1**3/12000;
            tmp := (tmp * (x1**2))/1000;
            v := v + tmp/1000;



            if div mod 4 = 2 or div mod 4 = 3 then
                v := v * (-1);
            end if;
            return v;
    end function;
begin
    

    process(clk)
    variable arg_tmp, im_tmp, res_im_tmp: integer := 0;
    
    begin


        if rising_edge(clk) then
            case state_m is
                when idle =>
                    computed <= '0';
                    if read_en = '1' then
                        x <= data;
                        state_m <= compute;
                        idx <= 0;
                        counter <= 0;
						res_re_tmp <= 0;
						res_im_tmp := 0;
                    else
                        state_m <= idle;
                    end if;
            
                when compute =>
                    -- res_re(idx) <= 0;--res_re_next;
--                    res_im(idx) <= res_im_tmp ; --res_im_tmp;
                    -- state_m <= idle;
                    if idx = data_len then
                        computed <= '1';
                        state_m <= idle;
                    else
                        arg_tmp:= (628 * idx * counter)/(data_len*10);
                        -- arg_tmp := integer(real(100)*sin(6.28*real(idx*counter)/real(data_len)));
                        -- re_tmp <= 50;--cos(arg_tmp);
                        -- im_tmp <= sin(idx);
                        
--                        res_re_tmp <= res_re_tmp + re_tmp;
                        -- if counter = 52 then
                            im_tmp:= sin_t(arg_tmp);
                            
                            res_im_tmp := res_im_tmp +  (im_tmp*x(idx));
                            -- report "i: " & integer'image(idx) & " counter: " & integer'image(counter) &" : arg: "& integer'image(arg_tmp) & " im: " & integer'image(im_tmp) & " res: "&integer'image(res_im_tmp);
                        -- end if;
                        
                        if counter = data_len then
--                            res_re_next <= res_re(idx) / 100;
--                            res_im_next <= res_im(idx) / 100;
							res_im(idx) := (res_im_tmp/80) + 300;
                            res_im_tmp := 0;
                            counter <= 0;
                            idx <= idx + 1;
                        else
                            counter <= counter + 1;
--                            res_re_next <= res_re_tmp;
                        --    res_im_next <= res_im_tmp;
                        end if;   
                    end if;

                when others =>
                    state_m <= idle;
            
            end case;
        end if;
    end process;

    is_computed <= computed;
	 res_out <= res_im when computed = '1' else res_out;
    result <= res_out;
    
end architecture arch;