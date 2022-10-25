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
        do_fft: in std_logic;
        done: out std_logic;
        res: out osignal_t;
        wr_en: in std_logic;
        data_in: in std_logic_vector(23 downto 0)
    );
end entity fft;

architecture rtl of fft is

    constant NORM : integer := 16;
    
    type state_t is (idle, write_to_ram, transform, clean, save_data, wait_for_ram, butterfly_step, transform_end, test);
    signal state_m, next_state: state_t := idle;
    signal dataAi, dataBi, dataAo, dataBo: std_logic_vector(31 downto 0) := (others => '0');
    signal Sa, Sb: cplx := (others => 0);
    signal addrA, addrB: std_logic_vector(WORD_LEN-1 downto 0) := (others => '0');
    signal counter_n: unsigned(WORD_LEN-1 downto 0):= (others => '0');
    signal pairs_number, pair_counter: natural range 0 to N := 0;
    signal counter_m, counter_divider: integer range 0 to N := 0; 
    signal alpha: integer := 0;
    signal x,y: cplx := (others => 0);
    signal data: isignal_t := (others => 0);
    signal new_data: osignal_t := (others => 0);

    signal wr: std_logic := '0';
    signal rd: std_logic := '1';  
    signal rdwr_wait: std_logic := '0';
    signal do_btfly_step: std_logic := '0';
    signal btfl_done: std_logic := '0';
    
begin

    ram: entity work.ram_ip
    port map(
        address_a => addrA,
        address_b => addrB,
        clock => clk,
        data_a => dataAi,
        data_b => dataBi,
        wren_a => wr,
        wren_b => wr,
        q_a => dataAo,
        q_b => dataBo
    );

    butterfly: entity work.butterfly
    port map(
        clk => clk, 
        transform => do_btfly_step,
        transformed => btfl_done,
        x => x, y => y,
        alpha => alpha, 
        Sa => Sa, Sb => Sb 
    );
    
    process(clk)

    variable adA, adB: integer := 0;
    variable dA, dB: cplx := (others => 0);
    variable counter_n_inversed1, counter_n_inversed2: unsigned(LOG_N downto 0):= (others => '0');
    variable wait_counter: integer range 0 to 7 := 0;
    
    begin
        if rising_edge(clk) then
            case state_m is
                when idle =>
                    done <= '0';
                    if do_fft = '1' then
                        state_m <= write_to_ram;
                        counter_m <= 1;
                        counter_n <= (others => '0');
                        counter_divider <= N;
                        pair_counter <= 0;
                        -- data <= data_i;
                        rdwr_wait <= '0';
                    end if;

                when write_to_ram =>
                    if counter_n > N-1 then
                        counter_n <= (others => '0');
                        wr<= '0';
                        addrA <= (others => '0');
                        addrB <= (others => '0');
                        state_m <= transform;
                    else
                        wr <= '1';
                        for i in 0 to LOG_N -1 loop
                            counter_n_inversed1(i) := counter_n(LOG_N-1 - i);
                            counter_n_inversed2(i) := counter_n(LOG_N-1 - i);
                        end loop;
                        counter_n_inversed1(LOG_N-1) := '0';
                        counter_n_inversed2(LOG_N-1) := '1'; 
                        addrA <= std_logic_vector(counter_n);
                        addrB <= std_logic_vector(counter_n + 1);

                        adA := to_integer(counter_n_inversed1);
                        adB := to_integer(counter_n_inversed2);
                      
                        dataAi <= std_logic_vector(to_signed(data(adA), WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                        dataBi <= std_logic_vector(to_signed(data(adB), WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));

                        report "adrA: " & integer'image(adA) & " data: " & integer'image(data(adA)) & " addr " & integer'image(to_integer(unsigned(addrA)));
                        report "adrB: " & integer'image(adB) & " data: " & integer'image(data(adB)) & " addr " & integer'image(to_integer(unsigned(addrB)));
                        counter_n <= counter_n + 2;
                        next_state <= write_to_ram;
                        wait_counter := 0;
                        state_m <= wait_for_ram;
                    end if;

                when transform =>
                    report "!!!!!!!!!!!!counter_n" & integer'image(to_integer(counter_n));
                    -- for i in 0 to 7 loop
                    --     report "Mess:" & integer'image(ram_arr(i)(0))& " res: " & integer'image(ram_arr(i)(1));
                    -- end loop;
                    wr <= '0';
                    if counter_n > isignal_t'high-1 then
                        if counter_m = LOG_N then
                            state_m <= wait_for_ram;
                            next_state <= transform_end;
                            addrA <= (others => '0');
                            addrB <= (std_logic_vector(to_unsigned(1, addrB'length)));
                            counter_n <= (others => '0');  
                        else
                            counter_m <= counter_m + 1;
                            counter_n <= (others => '0');
                            counter_divider <= counter_divider / 2;
                            pair_counter <= 0;
                        end if;
                    else

                        if (pair_counter mod (2**(counter_m))) < 2**(counter_m-1) then
                            adA := pair_counter;
                            adB := pair_counter + 2**(counter_m-1);
                            -- x <= ram_arr(adA);
                            -- y <= ram_arr(adB);
                            report ")))) adrA: " & integer'image(adA) & " adrB: " & integer'image(adB);
                            addrA <= std_logic_vector(to_unsigned(adA, addrA'length));
                            addrB <= std_logic_vector(to_unsigned(adB, addrB'length));
                            
                            state_m <= wait_for_ram;
                            next_state <= butterfly_step;
                        else
                            pair_counter <= pair_counter + 1;
                        end if;
 
                    end if;

                when wait_for_ram =>

                    if wait_counter = 4 then
                        state_m <= next_state;
                        wait_counter := 0;
                   else
                        state_m <= wait_for_ram;
                        wait_counter := wait_counter + 1;
                    end if;
                    

                when butterfly_step =>
                    x <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 0))));
                    y <= (to_integer(signed(dataBo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataBo(WORD_WIDTH-1 downto 0))));
                    alpha <= (pair_counter mod (2**(counter_m-1)))* counter_divider/2 ; --((alpha_counter mod 2**counter_m) * counter_divider/2);
                    -- alpha <= 628 * (alpha_counter mod 2**counter_m) ;
                    state_m <= save_data;
                    do_btfly_step <= '1';

                    -- report "hmm " & integer'image(to_integer(signed(dataAo(23 downto 12))));

                when save_data =>
                    do_btfly_step <= '0';
                    if btfl_done = '1' then
                        wr <= '1';
                        dataAi <= std_logic_vector(to_signed(Sa(0), WORD_WIDTH) & to_signed(Sa(1), WORD_WIDTH));
                        dataBi <= std_logic_vector(to_signed(Sb(0), WORD_WIDTH) & to_signed(Sb(1), WORD_WIDTH));
                        -- ram_arr(adA) <= Sa;
                        -- ram_arr(adB) <= Sb;
                        -- report "alpha: " & integer'image(alpha);
                        -- report "alpha counter: " & integer'image(alpha_counter);
                        -- report "counter_m: " & integer'image(counter_m);
                        -- report "@@@ args: " & integer'image(to_integer(counter_n_inversed1)) & " " & integer'image(to_integer(counter_n_inversed2));
                        report "1 x: " & integer'image(x(0)) & " " & integer'image(x(1));
                        report "2 y: " & integer'image(y(0)) & " " & integer'image(y(1));
                        report "1 wynik: " & integer'image(Sa(0)) & " " & integer'image(Sa(1));
                        -- -- report "2 arg: " & integer'image(y(0)) & " " & integer'image(y(1));
                        report "2 wynik: " & integer'image(Sb(0)) & " " & integer'image(Sb(1));
                        counter_n <= counter_n + 2;
                        pair_counter <= pair_counter + 1;
                        state_m <= wait_for_ram;
                        next_state <= transform;
                    else
                        state_m <= save_data;
                    end if;
                    

                when transform_end =>

                    if counter_n >= osignal_t'length-1 then
                        counter_n <= (others => '0');
                        state_m <= clean;
                        res <= new_data;
                        done <= '1';
                    else
                        adA := to_integer(counter_n );
                        adB := to_integer(counter_n + 1);
                        if counter_n < osignal_t'length-3 then

                            -- addrA <= std_logic_vector(to_unsigned(1, addrA'length));--
                            -- addrB <= std_logic_vector(to_unsigned(0, addrA'length));--
                            addrA <= std_logic_vector(counter_n + 2);
                            addrB <= std_logic_vector(counter_n + 3);
                        end if;
                        dA := (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 0))));
                        dB := (to_integer(signed(dataBo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataBo(WORD_WIDTH-1 downto 0))));
                        counter_n <= counter_n + 2;
                        new_data(adA) <= ((dA(0)/NORM * dA(0)/NORM) + (dA(1)/NORM * dA(1)/NORM)) mod 512;
                        new_data(adB) <= ((dB(0)/NORM * dB(0)/NORM) + (dB(1)/NORM * dB(1)/NORM)) mod 512;
                        state_m <= wait_for_ram;
                        next_state <= transform_end;
                        -- res(adA) <= (ram_arr(adA)(0)*ram_arr(adA)(0))/4000  + (ram_arr(adA)(1)*ram_arr(adA)(1))/4000;
                        -- res(adB) <= (ram_arr(adB)(0)*ram_arr(adB)(0))/4000  + (ram_arr(adB)(1)*ram_arr(adB)(1))/4000; -- + ram_arr(adB)(1);
                    end if;
                
                when clean =>
                    -- done <= '1';
                    
                    state_m <= idle;
            
                when others =>
                    state_m <= idle;
            
            end case;
        end if;
    end process;

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
                        temp :=(to_integer(signed(data_in(23 downto 10))) + 427)/8 ;
                        data <= temp & data(0 to data'high-1);
                        queue_s := idle;
                    end if;
            
                when others =>
                    
            
            end case;

        end if;
    end process;
    
end architecture rtl;