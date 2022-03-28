library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_controller is
    generic(
        HF: integer := 56;
        HD: integer := 800;
        HB: integer := 64;
        HR: integer := 120;
        VF: integer := 37;
        VD: integer := 600;
        VB: integer := 23;
        VR: integer := 6;

        H_POL: std_logic := '1';
        V_POL: std_logic := '1'
    );
    port (
        clk: in std_logic;
        h_sync, v_sync: out std_logic;
        video_on: out std_logic;
        pixel_x, pixel_y: out integer
    );
end entity vga_controller;

architecture arch of vga_controller is

    signal h_counter: integer := 0;
    signal v_counter: integer := 0;

    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if h_counter = HF+HD+HB+HR then
                h_counter <= 0;
                if v_counter = VF+VD+VB+VR then
                    v_counter <= 0;
                else
                    v_counter <= v_counter + 1;
                end if;
            else
                h_counter <= h_counter + 1;
            end if;

            pixel_y <= v_counter;
            pixel_x <= h_counter;
        end if;
    end process;

    h_sync <= H_POL when h_counter >= HF+HD and h_counter < HF+HD+HR else not H_POL;
    v_sync <= V_POL when v_counter >= VF+VD and v_counter < VF+VD+VR else not V_POL;
    video_on <= '1' when h_counter < HD and v_counter < VD else '0';
    
end architecture arch;