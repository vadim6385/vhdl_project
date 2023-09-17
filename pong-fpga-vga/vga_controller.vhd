-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- Use this library for to_unsigned and other arithmetic operations

-- Entity declaration
entity vga_controller is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC;
           h_pos : out STD_LOGIC_VECTOR(11 downto 0);
           v_pos : out STD_LOGIC_VECTOR(11 downto 0));
end vga_controller;

-- Architecture declaration
architecture Behavioral of vga_controller is
    -- Constants
    constant h_display : integer := 640;
    constant h_frontporch : integer := 16;
    constant h_syncpulse : integer := 96;
    constant h_backporch : integer := 48;
    
    constant v_display : integer := 480;
    constant v_frontporch : integer := 10;
    constant v_syncpulse : integer := 2;
    constant v_backporch : integer := 33;
    
    -- Internal signals
    signal clk_25 : STD_LOGIC := '0';
    signal h_pos_internal : integer := 0;
    signal v_pos_internal : integer := 0;
    signal active_display : integer := 0;
    
begin
    -- Assign internal signals to output ports
    h_pos <= std_logic_vector(to_unsigned(h_pos_internal, 12));
    v_pos <= std_logic_vector(to_unsigned(v_pos_internal, 12));
    
    -- Clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            clk_25 <= not clk_25;
        end if;
    end process;
    
    -- Horizontal position counter
    process(clk_25, rst)
    begin
        if rst = '0' then
            h_pos_internal <= 0;
        elsif rising_edge(clk_25) then
            if h_pos_internal = (h_display + h_frontporch + h_syncpulse + h_backporch) then
                h_pos_internal <= 0;
            else
                h_pos_internal <= h_pos_internal + 1;
            end if;
        end if;
    end process;
    
    -- Vertical position counter
    process(clk_25, rst)
    begin
        if rst = '0' then
            v_pos_internal <= 0;
        elsif rising_edge(clk_25) then
            if h_pos_internal = (h_display + h_frontporch + h_syncpulse + h_backporch) then
                if v_pos_internal = (v_display + v_frontporch + v_syncpulse + v_backporch) then
                    v_pos_internal <= 0;
                else
                    v_pos_internal <= v_pos_internal + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Horizontal synchronization pulse generator
    process(clk_25, rst)
    begin
        if rst = '0' then
            Hsync <= '0';
        elsif rising_edge(clk_25) then
            if (h_pos_internal <= (h_display + h_frontporch)) or (h_pos_internal > (h_display + h_syncpulse + h_backporch)) then
                Hsync <= '1';
            else
                Hsync <= '0';
            end if;
        end if;
    end process;
    
    -- Vertical synchronization pulse generator
    process(clk_25, rst)
    begin
        if rst = '0' then
            Vsync <= '0';
        elsif rising_edge(clk_25) then
            if (v_pos_internal <= (v_display + v_frontporch)) or (v_pos_internal > (v_display + v_syncpulse + v_backporch)) then
                Vsync <= '1';
            else
                Vsync <= '0';
            end if;
        end if;
    end process;
    
    -- Active display area
    process(clk_25, rst)
    begin
        if rst = '0' then
            active_display <= 0;
        elsif rising_edge(clk_25) then
            if h_pos_internal <= h_display and v_pos_internal <= v_display then
                active_display <= 1;
            else
                active_display <= 0;
            end if;
        end if;
    end process;
    
end Behavioral;
