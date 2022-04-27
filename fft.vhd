library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
library work;
use work.common.all;
use work.trigonometric.all;

entity fft is
    port (
        clk: in std_logic;
        data: in queue_t;
        do_fft: in std_logic;
        done: out std_logic;
        res: out queue_t
    );
end entity fft;

architecture rtl of fft is

    
    type state_t is (idle, write_to_ram, transform, clean, write_data, read_data, butterfly_step, transform_end);
    signal state_m: state_t := idle;
    signal dataAi, dataBi, dataAo, dataBo, Sa, Sb: cplx := (others => 0);
    signal addrAi, addrBi, addrAo, addrBo: integer range 0 to N*2;
    signal counter_n, counter_n_inversed1, counter_n_inversed2: unsigned(LOG_N downto 0):= (others => '0');
    signal pairs_number, pairs_amount, pair_counter: natural range 0 to N := 0;
    signal counter_m, counter_divider: integer range 0 to N := 0; 
    signal alpha: integer := 0;
    signal x,y: cplx;

    signal wr, rd: std_logic := '0';
begin

    ram: entity work.ram
    port map(
        addrAo => addrAo, 
        addrBo => addrBo,
        addrAi => addrAi,
        addrBi => addrBi,
        dataAi => dataAi,
        dataBi => dataBi,
        dataAo => dataAo,
        dataBo => dataBo,
        wr => wr, rd => rd
    );

    butterfly: entity work.butterfly
    port map(
        x => x, y => y,
        alpha => alpha, 
        Sa => Sa, Sb => Sb 
    );
    
    process(clk)
    variable alpha_counter: natural range 0 to N/2+1;
    variable counter_n_ninv: unsigned(LOG_N downto 0) := (others => '0');
    variable adA, adB: integer := 0;
    begin
        if rising_edge(clk) then
            case state_m is
                when idle =>
                    done <= '0';
                    if do_fft = '1' then
                        state_m <= write_to_ram;
                        counter_m <= 1;
                        counter_n <= (others => '0');
                        alpha_counter := 0;
                        counter_divider <= N;
                        pair_counter <= 0;
                    end if;

                when write_to_ram =>
                    if counter_n = N/2 then
                        wr <= '0';
                        counter_n <= (others => '0');
                        state_m <= transform;
                    else
                        wr <= '1';
                        adA := to_integer(counter_n) *2;
                        adB := adA + 1;
                        addrAi <= adA;
                        addrBi <= adA + 1;
                        dataAi(0) <= data(adA);
                        dataBi(0) <= data(adB);
                        counter_n <= counter_n + 1;
                    end if;

                when transform =>
                    wr <= '0';
                    if counter_n > queue_t'high-1 then
                        if counter_m = LOG_N then
                            state_m <= transform_end;
                            addrAo <= 0;
                            addrBo <= 0;
                            counter_n <= (others => '0');
                            done <= '1';    
                        else
                            counter_m <= counter_m + 1;
                            counter_n <= (others => '0');
                            alpha_counter := 0;
                            counter_n_ninv := (others => '0');
                            counter_divider <= counter_divider / 2;
                            pairs_amount <= 2*N/counter_divider;
                        end if;
                    else
                    -- counter_n_ninv := to_unsigned(to_integer(counter_n) * 2**counter_m, LOG_N+1);
                    -- counter_n_ninv := to_unsigned(to_integer(counter_n_ninv) / 2**counter_m, LOG_N+1);
                    -- report "asdf " & integer'image(counter_m);
                        if counter_m = 1 then
                            counter_n_ninv := counter_n;
                            for i in 0 to LOG_N -1 loop
                                counter_n_inversed1(i) <= counter_n_ninv(LOG_N-1 - i);
                                counter_n_inversed2(i) <= counter_n_ninv(LOG_N-1 - i);
                            end loop;
                            counter_n_inversed1(LOG_N-1) <= '0';
                            counter_n_inversed2(LOG_N-1) <= '1'; 
                            addrAo <= to_integer(counter_n_inversed1);
                            addrBo <= to_integer(counter_n_inversed2);
                            state_m <= read_data;
                            rd <= '1';
                        else
                            if (pair_counter mod pairs_amount) < counter_divider/2 then
                                addrAo <= pair_counter;
                                addrBo <= pair_counter + counter_divider/2;
                                state_m <= read_data;
                            else
                                pair_counter <= pair_counter + 1;
                            end if;
                        end if;
                        

                        
                        
                        
                    end if;

                when read_data =>
                    
                    state_m <= butterfly_step;
                    x <= dataAo;
                    y <= dataBo;

                when butterfly_step =>
                    rd <= '0';
                    -- report "m: " & integer'image(counter_m);
                    alpha <= 63*((alpha_counter mod 2**counter_m) * counter_divider/2);
                    -- alpha <= 628 * (alpha_counter mod 2**counter_m) ;
                    state_m <= write_data;

                when write_data =>
                    dataAi <= (Sa(0)/(N*100), Sa(1)/(N*100));
                    dataBi <= (Sb(0)/(N*100), Sb(1)/(N*100));
                    addrAi <= x;
                    addrBi <= y;
                    wr <= '1';
                    report "alpha: " & integer'image(alpha);
                    -- report "alpha counter: " & integer'image(alpha_counter);
                    -- report "counter_m: " & integer'image(counter_m);
                    report "@@@ args: " & integer'image(to_integer(counter_n_inversed1)) & " " & integer'image(to_integer(counter_n_inversed2));
                    report "1 x: " & integer'image(x(0)) & " " & integer'image(x(1));
                    report "1 wynik: " & integer'image(Sa(0)) & " " & integer'image(Sb(1));
                    report "2 arg: " & integer'image(y(0)) & " " & integer'image(y(1));
                    report "2 wynik: " & integer'image(Sb(0)) & " " & integer'image(Sa(1));
                    
                    counter_n <= counter_n + 2;
                    alpha_counter := alpha_counter + 1;
                    state_m <= transform;
                    counter_n_inversed1 <= (others => '0');
                    counter_n_inversed2 <= (others => '0');
                    

                when transform_end =>
                    wr <= '0';
                    if counter_n >= N -1 then
                        counter_n <= (others => '0');
                        state_m <= clean;
                    else
                        counter_n <= counter_n + 2;
                        pair_counter <= pair_counter + 1;
                        res(to_integer(counter_n)) <= dataAo(0) + dataAo(1);
                        res(to_integer(counter_n)+1) <= dataBo(0) + dataBo(1);
                        addrAo <= to_integer(counter_n);
                        addrBo <= to_integer(counter_n + 1); 
                    end if;
                
                when clean =>
                    state_m <= idle;
            
                when others =>
                    state_m <= idle;
            
            end case;
        end if;
    end process;
    
end architecture rtl;