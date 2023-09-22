-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration
entity displayScore_SSD is
    Port ( i_clk : in STD_LOGIC;              -- Clock input
           score : in STD_LOGIC_VECTOR(2 downto 0);  -- Score input
           segment : out STD_LOGIC_VECTOR(6 downto 0)); -- Seven-segment display output
end displayScore_SSD;

-- Architecture declaration
architecture Behavioral of displayScore_SSD is
    -- Internal signal
    signal hex_value : STD_LOGIC_VECTOR(6 downto 0) := "0000000";
    
begin
    -- Process for converting score to seven-segment display value
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            -- Case statement to map score to seven-segment display value
            case score is
                when "000" => hex_value <= "0111110";  -- 0
                when "001" => hex_value <= "0011000";  -- 1
                when "010" => hex_value <= "0110110";  -- 2
                when "011" => hex_value <= "0111100";  -- 3
                when "100" => hex_value <= "0011001";  -- 4
                when "101" => hex_value <= "0101101";  -- 5
                when "110" => hex_value <= "0101111";  -- 6
                when "111" => hex_value <= "0111000";  -- 7
                when others => hex_value <= "0000000";  -- Default
            end case;
        end if;
    end process;
    
    -- Assign internal signal to output port
    segment <= hex_value;
    
end Behavioral;
