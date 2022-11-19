library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity draw_line is
    port (
        clk: in std_logic;
        start: in std_logic := '1';
        
        x1: in integer := 2;
        y1 : in integer := 2;

        x2: in integer := 5;
        y2 : in integer := 5;

        x, y: out integer;
        oe: in std_logic;
        done: out std_logic := '0'
    );
end entity draw_line;

architecture rtl of draw_line is
    signal swap, right: std_logic;
    signal xa, ya, xb, yb, x_end, y_end: integer;
    signal err, dx, dy: integer;
    type state_t is (IDLE, INIT_0, INIT_1, DRAW);
    signal state: state_t := IDLE;
    signal movx, movy: std_logic;
    signal x_i, y_i: integer;

begin

    swap <= '1' when y1 > y2 else '0';

    process(err, dy, dx)
    begin
        if 2*err >= dy then
            movx <= '1';
        else
            movx <= '0';
        end if;
        if 2*err <= dx then
            movy <= '1';
        else
            movy <= '0';
        end if;
        
        -- movx <= '1' when (2*err >= dy) else '0';
        -- movy <= '1' when (2*err <= dx) else '0' ; 
    end process;

    process(swap, x1, x2, y1, y2)
    begin
        if swap = '1' then
            xa <= x2;
            ya <= y2;
            xb <= x1;
            yb <= y1;
        else
            xa <= x1;
            ya <= y1;
            xb <= x2;
            yb <= y2;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
            
                when IDLE =>
                    done <= '1';
                    if start = '1' then
                        state <= INIT_0;
                        if xa < xb then
                           right <= '1';
                        else
                            right <= '0'; 
                        end if;

                    end if;

                when INIT_0 =>
                    done <= '0';
                    state <= INIT_1;
                    if right = '1' then
                        dx <= xb - xa;
                    else
                        dx <= xa - xb;
                    end if;
                    dy <= ya - yb;
                
                when INIT_1 =>
                    state <= DRAW;
                    err <= dx + dy;
                    x_i <= xa;
                    y_i <= ya;
                    x_end <= xb;
                    y_end <= yb;

                when DRAW =>
                    if oe = '1' then
                        if x_i >= x_end and y_i >= y_end then
                            state <= IDLE;
                            done <= '1';
                        else
                            if movx = '1' and movy = '0' then
                                if right = '1' then
                                    x_i <= x_i + 1;
                                else
                                    x_i <= x_i - 1;
                                end if;
                                err <= err + dy;
                            end if;
                            if movy = '1' and movx = '0' then
                                y_i <= y_i + 1;
                                err <= err + dx;
                            end if;
                            if movy = '1' and movx = '1' then
                                if right = '1' then
                                    x_i <= x_i + 1;
                                else
                                    x_i <= x_i - 1;
                                end if;
                                y_i <= y_i + 1;
                                err <= err + dy + dx;
                            end if;
                        end if;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    x <= x_i;
    y <= y_i;
end architecture rtl; 