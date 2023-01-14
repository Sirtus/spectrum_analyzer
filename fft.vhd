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
        -- res: out osignal_t;
        wr_en: in std_logic;
        fifoA_addr, fifoB_addr: out unsigned(LOG_N-1 downto 0);
        fifoA_q, fifoB_q: in std_logic_vector(11 downto 0);
        -- data_in: in std_logic_vector(23 downto 0);
        general_ram_addr: out std_logic_vector(14 downto 0);
        general_ram_data: out std_logic_vector(15 downto 0);
        general_ram_wren: out std_logic;
        last_column: out integer range 0 to 255 := 0
    );
end entity fft;

architecture rtl of fft is

    constant TRIANGLE_N: integer := N;
    constant TRIANGLE_N_DIV_2: integer := TRIANGLE_N/2;
    constant FFT_DELAY: integer := 2; --100000
    
    type state_t is (idle, read_signal, save_signal, transform, clean, save_data, wait_for_ram, butterfly, transform_end, test);
    signal state_m, next_state, state_m_next, next_state_next: state_t := idle;
    signal dataAi, dataBi, dataAi_next, dataBi_next, dataAo, dataBo: std_logic_vector(DOUBLE_WORD_WIDTH-1 downto 0) := (others => '0');
    signal Sa, Sb: cplx := (others => 0);
    signal addrA, addrB, addrA_next, addrB_next: std_logic_vector(WORD_LEN-1 downto 0) := (others => '0');
    signal counter_n, counter_n_next: unsigned(WORD_LEN-1 downto 0):= (others => '0');
    signal pairs_number, pair_counter, pair_counter_next: natural range 0 to N := 0;
    signal counter_m, counter_divider, counter_m_next, counter_divider_next: integer range 0 to N := 1; 
    signal alpha: integer := 0;
    signal x,y: cplx := (others => 0);
    signal data: isignal_t := (others => 0);
    signal new_data: osignal_t := (others => 0);
    signal new_data2: integer := 0;

    signal wr: std_logic := '0';
    signal rd: std_logic := '1';  
    signal rdwr_wait: std_logic := '0';
    signal do_btfly_step: std_logic := '0';
    signal btfl_done: std_logic := '0';
    signal last_column_o: integer range 0 to 255 := 0;
    signal last_column_addr: integer := 0;

    signal counter_n_inversed1, counter_n_inversed2: unsigned(LOG_N-1 downto 0):= (others => '1');
    signal block_shift, block_shift_div2: integer range 0 to N := 1;
    signal do_butterfly_step: boolean := false;
    signal dA, dA_next, dB: cplx := (others => 0);
    signal column_counter, column_counter_next: integer range 0 to 199 := 0;
    signal triangle_function_0, triangle_function_1 : integer range 1 to N*2 := 1;

    signal next_fft_ctr, next_fft_ctr_next: integer := 0;
    signal fifoA_data, fifoB_data: integer := 0;
    signal general_ram_addr_reg, general_ram_addr_next: std_logic_vector(14 downto 0);
    signal general_ram_wren_reg, general_ram_wren_next: std_logic;

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

    butterfly_struct: entity work.butterfly
    port map(
        clk => clk, 
        transform => do_btfly_step,
        transformed => btfl_done,
        x => x, y => y,
        alpha => alpha, 
        Sa => Sa, Sb => Sb 
    );

    inverter: entity work.vector_inverter
    port map(
        counter_n => counter_n,
        counter_n_inversed1 => counter_n_inversed1,
        counter_n_inversed2 => counter_n_inversed2
    );

    process(clk)
    begin
        if rising_edge(clk) then
            state_m <= state_m_next;
            next_state <= next_state_next;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            counter_n <= counter_n_next;
            counter_m <= counter_m_next;
            next_fft_ctr <= next_fft_ctr_next;
            pair_counter <= pair_counter_next;
            counter_divider <= counter_divider_next;
            dA <= dA_next;
            column_counter <= column_counter_next;
            
            last_column <= column_counter_next;
            last_column_addr <= column_counter_next * N_DIV_2;
            general_ram_addr_reg <= general_ram_addr_next;
            general_ram_wren_reg <= general_ram_wren_next;
            addrA <= addrA_next;
            addrB <= addrB_next;
            dataAi <= dataAi_next;
            dataBi <= dataBi_next;
            -- if dA(0) /= 0 then
            --     general_ram_data <= std_logic_vector(to_unsigned(210, general_ram_data'length));
            -- else
            --     general_ram_data <= std_logic_vector(to_unsigned(16, general_ram_data'length));
            -- end if;
            -- if da(0) >= 0 then
            --     general_ram_data <= std_logic_vector(to_unsigned(dA(0), general_ram_data'length));
            -- else
            --     general_ram_data <= std_logic_vector(to_unsigned(-dA(0), general_ram_data'length));
            -- end if;
            general_ram_data <= std_logic_vector(to_unsigned(dA(0)*dA(0) + dA(1)*dA(1), general_ram_data'length));
        end if;
    end process;
    -- general_ram_data <= std_logic_vector(to_unsigned(dA(0)*dA(0) + dA(1)*dA(1), general_ram_data'length));
    process(clk)
    begin
        if rising_edge(clk) then
            case state_m is
                when idle =>
                    if next_fft_ctr = FFT_DELAY then --100000
                        next_fft_ctr_next <= 0;
                    else
                        next_fft_ctr_next <= next_fft_ctr + 1;
                    end if;

                when wait_for_ram =>
                    if next_fft_ctr = 7 then --100000
                        next_fft_ctr_next <= 0;
                    else
                        next_fft_ctr_next <= next_fft_ctr + 1;
                    end if;
            
                when others =>
                    next_fft_ctr_next <= 0;
            end case;            
        end if;
    end process;

    process(clk)
    begin
        if falling_edge(clk) then
            counter_n_next <= counter_n;
            case state_m is
                when read_signal =>
                    if counter_n < N then
                        counter_n_next <= counter_n;
                    else
                        counter_n_next <= (others => '0');
                    end if;

                when save_signal =>
                    counter_n_next <= counter_n + 2;

                when transform =>
                    if counter_n > N-1 then
                        counter_n_next <= (others => '0');
                    else
                        counter_n_next <= counter_n;
                    end if;
                
                when save_data =>
                    if btfl_done = '1' then
                        counter_n_next <= counter_n + 2;
                    else
                        counter_n_next <= counter_n;
                    end if;

                when wait_for_ram =>
                    counter_n_next <= counter_n;
                    
    
                when butterfly =>
                    counter_n_next <= counter_n;
                
                when transform_end =>
                    counter_n_next <= counter_n + 1;
            
                when others =>
                    counter_n_next <= (others => '0');
            end case;            
        end if;
    end process;

    process(clk)
    begin
        if falling_edge(clk) then
            case state_m is
                when transform =>
                    if counter_n > N-1 then
                        if counter_m < LOG_N then
                            counter_m_next <= counter_m + 1;
                        else
                            counter_m_next <= counter_m;
                        end if;
                    else
                        counter_m_next <= counter_m;
                    end if;

                when save_data =>
                    counter_m_next <= counter_m;

                when wait_for_ram =>
                    counter_m_next <= counter_m;
                    
    
                when butterfly =>
                    counter_m_next <= counter_m;
            
                when others =>
                    counter_m_next <= 1;
            
            end case;
        end if;
    end process;
    
    process(state_m, next_state, counter_n, counter_m, do_fft, next_fft_ctr, fifoA_data, fifoB_data, triangle_function_0, triangle_function_1,
            pair_counter, block_shift, block_shift_div2, btfl_done, Sa, Sb, counter_divider, column_counter, dA, last_column_addr, dataAo, general_ram_addr_reg)
    variable adA, adB: integer := 0; 
    variable wait_counter: integer range 0 to 7 := 0;
    
    begin
        wr <= '0';
        done <= '0';
        counter_divider_next <= counter_divider;
        pair_counter_next <= pair_counter;
        -- rdwr_wait <= '0';
        next_state_next <= next_state;
        state_m_next <= idle;
        addrA_next <= addrA;
        addrB_next <= addrB;
        dataAi_next <= (others => '0');
        dataBi_next <= (others => '0');
        general_ram_addr_next <= (others => '0');
        do_btfly_step <= '0';
        general_ram_wren_next <= '0';
        dA_next <= (others => 0);
        column_counter_next <= column_counter;


        case state_m is
            when idle =>
                counter_divider_next <= N;
                if do_fft = '1' then
                    if next_fft_ctr = FFT_DELAY then --100000
                        state_m_next <= read_signal;
                    end if;
                end if;

            when read_signal =>
                report "aasdfpoij";
                if counter_n > N-1 then
                    state_m_next <= transform;
                else
                    wr <= '1';
                    state_m_next <= wait_for_ram;
                    next_state_next <= save_signal;
                end if;

            when save_signal =>
                wr <= '1';
                addrA_next <= std_logic_vector(counter_n);
                addrB_next <= std_logic_vector(counter_n + 1);
                -- dataAi_next <= std_logic_vector(to_signed(fifoA_data/triangle_function_0, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                -- dataBi_next <= std_logic_vector(to_signed(fifoB_data/triangle_function_1, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                dataAi_next <= std_logic_vector(to_signed(fifoA_data, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                dataBi_next <= std_logic_vector(to_signed(fifoB_data, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                -- dataAi_next <= std_logic_vector(to_signed(16, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                -- dataBi_next <= std_logic_vector(to_signed(255, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                report "SIGNAL A: " & integer'image(to_integer(unsigned(dataAi)));-- & ", " & integer'image(dataAi(1));
                report "SIGNAL B: " & integer'image(to_integer(unsigned(dataBi)));-- & ", " & integer'image(dataBi(1));
                state_m_next <= wait_for_ram;
                next_state_next <= read_signal;

            when transform =>
                wr <= '0';
                state_m_next <= transform;
                if counter_n > N-1 then
                    if counter_m = LOG_N then
                        state_m_next <= wait_for_ram;
                        next_state_next <= transform_end;
                    else
                        counter_divider_next <= counter_divider / 2;
                        pair_counter_next <= 0;
                    end if;
                else
                    if (pair_counter mod (block_shift)) < block_shift_div2 then
                        adA := pair_counter;
                        adB := pair_counter + block_shift_div2;
                        addrA_next <= std_logic_vector(to_unsigned(adA, addrA'length));
                        addrB_next <= std_logic_vector(to_unsigned(adB, addrB'length)); 
                        state_m_next <= wait_for_ram;
                        next_state_next <= butterfly;
                    else
                        pair_counter_next <= (pair_counter + 1) mod N;
                    end if;
                end if;

            when wait_for_ram =>
                -- state_m_next <= next_state;
                -- general_ram_wren_next <= general_ram_wren_reg;
                -- dataAi_next <= dataAi;
                -- dataBi_next <= dataBi;

                case next_state is
                    when transform =>
                        dataAi_next <= std_logic_vector(to_signed(Sa(0), WORD_WIDTH) & to_signed(Sa(1), WORD_WIDTH));
                        dataBi_next <= std_logic_vector(to_signed(Sb(0), WORD_WIDTH) & to_signed(Sb(1), WORD_WIDTH));
                
                    when others =>
                        dataAi_next <= std_logic_vector(to_signed(fifoA_data, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                        dataBi_next <= std_logic_vector(to_signed(fifoB_data, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                
                end case;
                

                addrA_next <= addrA;
                addrB_next <= addrB;
                general_ram_addr_next <= general_ram_addr_reg;
                dA_next <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH+2))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 2))));
                general_ram_wren_next <= general_ram_wren_reg;
                wr <= wr;
                if next_fft_ctr = 7 then --100000
                    state_m_next <= next_state;
                else
                    state_m_next <= wait_for_ram;
                end if;
                

            when butterfly =>
                state_m_next <= save_data;
                do_btfly_step <= '1';

            when save_data =>
                do_btfly_step <= '0';
                if btfl_done = '1' then
                    wr <= '1';
                    dataAi_next <= std_logic_vector(to_signed(Sa(0), WORD_WIDTH) & to_signed(Sa(1), WORD_WIDTH));
                    dataBi_next <= std_logic_vector(to_signed(Sb(0), WORD_WIDTH) & to_signed(Sb(1), WORD_WIDTH));
                    report "SAVED A: " & integer'image(Sa(0)) & ", " & integer'image(Sa(1));
                    report "SAVED B: " & integer'image(Sb(0)) & ", " & integer'image(Sb(1));
                    pair_counter_next <= (pair_counter + 1) mod N;
                    state_m_next <= wait_for_ram;
                    next_state_next <= transform;
                else
                    state_m_next <= save_data;
                end if;
             

            when transform_end =>
                done <= '1';
                if counter_n >= N_DIV_2 then
                    column_counter_next <= column_counter + 1;
                else
                    general_ram_wren_next <= '1';
                    adA := to_integer(counter_n) + last_column_addr;
                    general_ram_addr_next <= std_logic_vector(to_unsigned(adA, general_ram_addr'length));
                    addrA_next <= std_logic_vector(counter_n + 1);
                    dA_next <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH+2))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 2))));
                    state_m_next <= wait_for_ram;
                    next_state_next <= transform_end;
                end if;
                report "SIDFPISDJFPSIFJ";
                

            when clean =>
                state_m_next <= idle;
        
            when others =>
                state_m_next <= idle;
        
        end case;
    end process;

    block_shift <= 2**(counter_m);
    block_shift_div2 <= 2**(counter_m-1);
    -- alpha <= ((pair_counter mod (block_shift_div2)) * counter_divider/2)mod N/2 ;
    -- do_butterfly_step <= (pair_counter mod (block_shift)) < block_shift_div2;
    -- new_data2 <= 40*to_integer(counter_n);--((dA(0) * dA(0)) + (dA(1) * dA(1)));
    -- general_ram_data <= std_logic_vector(to_unsigned(new_data2, general_ram_data'length));
    general_ram_wren <= general_ram_wren_reg;

    triangle_function_0 <= 2*(TRIANGLE_N_DIV_2/(to_integer(counter_n_inversed1 + 1)));
    triangle_function_1 <= 2*(TRIANGLE_N_DIV_2/(N - to_integer(counter_n_inversed2)));

    x <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 0))));
    y <= (to_integer(signed(dataBo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataBo(WORD_WIDTH-1 downto 0))));
    alpha <= ((pair_counter mod (block_shift_div2)) * counter_divider/2)mod N_DIV_2 ;

    general_ram_addr <= general_ram_addr_reg;

    fifoA_data <= to_integer(signed(fifoA_q));
    fifoB_data <= to_integer(signed(fifoB_q));
    fifoA_addr <= counter_n_inversed1;
    fifoB_addr <= counter_n_inversed2;
    
end architecture rtl;