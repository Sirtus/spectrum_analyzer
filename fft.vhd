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

    constant NORM : integer := 16;
    constant TRIANGLE_N: integer := 256;
    constant TRIANGLE_N_DIV_2: integer := TRIANGLE_N/2;
    
    type state_t is (idle, read_signal, save_signal, transform, clean, save_data, wait_for_ram, butterfly, transform_end, test);
    signal state_m, next_state: state_t := idle;
    signal dataAi, dataBi, dataAo, dataBo: std_logic_vector(DOUBLE_WORD_WIDTH-1 downto 0) := (others => '0');
    signal Sa, Sb: cplx := (others => 0);
    signal addrA, addrB: std_logic_vector(WORD_LEN-1 downto 0) := (others => '0');
    signal counter_n: unsigned(WORD_LEN-1 downto 0):= (others => '0');
    signal pairs_number, pair_counter: natural range 0 to N := 0;
    signal counter_m, counter_divider: integer range 0 to N := 0; 
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
    signal fft_counter: integer range 0 to 255 := 0;

    signal counter_n_inversed1, counter_n_inversed2: unsigned(LOG_N-1 downto 0):= (others => '0');
    signal block_shift, block_shift_div2: integer range 0 to N := 0;
    signal do_butterfly_step: boolean := false;
    signal dA, dB: cplx := (others => 0);
    signal column_counter: integer range 0 to 199 := 0;
    signal triangle_function_0, triangle_function_1 : integer range 1 to N*2 := 1;

    signal next_fft_ctr: integer := 0;
    signal fifoA_data, fifoB_data: integer := 0;
    
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

    variable adA, adB: integer := 0; 
    variable wait_counter: integer range 0 to 7 := 0;
    
    begin
        if rising_edge(clk) then
            case state_m is
                when idle =>
                    done <= '0';
                    if do_fft = '1' then
                        if next_fft_ctr = 100000 then
                            state_m <= read_signal;
                            counter_m <= 1;
                            counter_n <= (others => '0');
                            counter_divider <= N;
                            pair_counter <= 0;
                            rdwr_wait <= '0';
                            next_fft_ctr <= 0;
                        else
                            next_fft_ctr <= next_fft_ctr + 1;
                        end if;
                    else
                        state_m <= idle;
                    end if;

                when read_signal =>
                    if counter_n > N-1 then
                        counter_n <= (others => '0');
                        wr <= '0';
                        addrA <= (others => '0');
                        addrB <= (others => '0');
                        state_m <= transform;
                    else
                        wr <= '1';
                        state_m <= wait_for_ram;
                        next_state <= save_signal;
                    end if;

                when save_signal =>
                    wr <= '1';
                    addrA <= std_logic_vector(counter_n);
                    addrB <= std_logic_vector(counter_n + 1);
                    dataAi <= std_logic_vector(to_signed(fifoA_data/triangle_function_0, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                    dataBi <= std_logic_vector(to_signed(fifoB_data/triangle_function_1, WORD_WIDTH)) & std_logic_vector(to_unsigned(0, WORD_WIDTH));
                    state_m <= wait_for_ram;
                    next_state <= read_signal;
                    counter_n <= counter_n + 2;

                when transform =>
                    wr <= '0';
                    if counter_n > isignal_t'high-1 then
                        if counter_m = LOG_N then
                            fft_counter <= 0;
                            state_m <= wait_for_ram;
                            next_state <= transform_end;
                            addrA <= (others => '0');
                            general_ram_addr <= (others => '0');
                            counter_n <= (others => '0');  

                        else
                            counter_m <= counter_m + 1;
                            counter_n <= (others => '0');
                            counter_divider <= counter_divider / 2;
                            pair_counter <= 0;
                        end if;
                    else

                        if do_butterfly_step then
                            adA := pair_counter;
                            adB := pair_counter + block_shift_div2;
                            addrA <= std_logic_vector(to_unsigned(adA, addrA'length));
                            addrB <= std_logic_vector(to_unsigned(adB, addrB'length)); 
                            state_m <= wait_for_ram;
                            next_state <= butterfly;
                        else
                            pair_counter <= pair_counter + 1;
                        end if;
                    end if;

                when wait_for_ram =>
                    state_m <= next_state;
                    

                when butterfly =>
                    state_m <= save_data;
                    do_btfly_step <= '1';

                when save_data =>
                    do_btfly_step <= '0';
                    if btfl_done = '1' then
                        wr <= '1';
                        dataAi <= std_logic_vector(to_signed(Sa(0), WORD_WIDTH) & to_signed(Sa(1), WORD_WIDTH));
                        dataBi <= std_logic_vector(to_signed(Sb(0), WORD_WIDTH) & to_signed(Sb(1), WORD_WIDTH));
                        counter_n <= counter_n + 2;
                        pair_counter <= pair_counter + 1;
                        state_m <= wait_for_ram;
                        next_state <= transform;
                    else
                        state_m <= save_data;
                    end if;
                    

                when transform_end =>
                    done <= '1';
                    if counter_n >= N_DIV_2 then
                        general_ram_wren <= '0';
                        counter_n <= (others => '0');
                        state_m <= idle;
                        column_counter <= column_counter + 1;
                    else
                        general_ram_wren <= '1';
                        adA := to_integer(counter_n) + last_column_addr;
                        general_ram_addr <= std_logic_vector(to_unsigned(adA, general_ram_addr'length));
                        addrA <= std_logic_vector(counter_n + 1);
                        dA <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH+2))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 2))));
                        state_m <= wait_for_ram;
                        next_state <= transform_end;
                        counter_n <= counter_n + 1;
                    end if;
                    

                when clean =>
                    state_m <= idle;
            
                when others =>
                    state_m <= idle;
            
            end case;
        end if;
    end process;

    block_shift <= 2**(counter_m);
    block_shift_div2 <= 2**(counter_m-1);
    alpha <= (pair_counter mod (block_shift_div2)) * counter_divider/2 ;
    do_butterfly_step <= (pair_counter mod (block_shift)) < block_shift_div2;
    new_data2 <= ((dA(0) * dA(0)) + (dA(1) * dA(1)));
    general_ram_data <= std_logic_vector(to_unsigned(new_data2, general_ram_data'length));


    triangle_function_0 <= 2*(TRIANGLE_N_DIV_2/(to_integer(counter_n_inversed1 + 1)));
    triangle_function_1 <= 2*(TRIANGLE_N_DIV_2/(N - to_integer(counter_n_inversed2)));

    x <= (to_integer(signed(dataAo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataAo(WORD_WIDTH-1 downto 0))));
    y <= (to_integer(signed(dataBo(DOUBLE_WORD_WIDTH-1 downto WORD_WIDTH))), to_integer(signed(dataBo(WORD_WIDTH-1 downto 0))));

    last_column <= column_counter;
    last_column_addr <= column_counter * N_DIV_2;

    fifoA_data <= to_integer(signed(fifoA_q));
    fifoB_data <= to_integer(signed(fifoB_q));
    fifoA_addr <= counter_n_inversed1;
    fifoB_addr <= counter_n_inversed2;
    
end architecture rtl;