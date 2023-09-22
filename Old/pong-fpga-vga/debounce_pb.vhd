-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration
entity debounce_pb is
    Port ( in_clk : in STD_LOGIC;      -- Clock input
           pb_in : in STD_LOGIC;       -- Push-button input
           pb_out : out STD_LOGIC);    -- Debounced push-button output
end debounce_pb;

-- Architecture declaration
architecture Behavioral of debounce_pb is
    -- Constants
    constant clks_ms : integer := 500000;  -- Clock cycles to elapse 10ms
    
    -- Internal signals
    signal button_state : STD_LOGIC := '1';  -- Not pressed
    signal clk_counter : STD_LOGIC_VECTOR(18 downto 0) := "0000000000000000000";
    
begin
    -- Assign internal signal to output port
    pb_out <= button_state;
    
    -- Process for debouncing the push-button
    process(in_clk)
    begin
        if rising_edge(in_clk) then
            -- Check if button state has changed and counter is below threshold
            if (pb_in /= button_state and clk_counter < clks_ms) then
                clk_counter <= clk_counter + 1;
            
            -- Check if button state has changed and counter has reached threshold
            elsif (pb_in /= button_state and clk_counter = clks_ms) then
                clk_counter <= "0000000000000000000";
                button_state <= pb_in;
            
            -- Reset counter if none of the above conditions are met
            else
                clk_counter <= "0000000000000000000";
            end if;
        end if;
    end process;
    
end Behavioral;
