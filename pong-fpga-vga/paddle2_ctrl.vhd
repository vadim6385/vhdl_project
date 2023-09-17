-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity paddle2_ctrl is
    Port ( in_clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           push1 : in STD_LOGIC;
           push2 : in STD_LOGIC;
           h_pos : in STD_LOGIC_VECTOR(11 downto 0);
           v_pos : in STD_LOGIC_VECTOR(11 downto 0);
           y_paddle : out STD_LOGIC_VECTOR(11 downto 0);
           dispPaddle2 : out STD_LOGIC);
end paddle2_ctrl;

-- Architecture declaration
architecture Behavioral of paddle2_ctrl is
    -- Constants
    constant paddleHeight : integer := 48;
    constant paddleWidth : integer := 10;
    constant screenWidth : integer := 640;
    constant screenHeight : integer := 480;
    constant waitCycles : integer := 2500000;
    
    -- Internal signals
    signal count_clk : integer := 0;
    signal y_paddle_internal : integer := 0;
    
begin
    -- Assign internal signals to output ports
    y_paddle <= std_logic_vector(to_unsigned(y_paddle_internal, 12));
    
    -- Process for counting cycles
    process(in_clk)
    begin
        if rising_edge(in_clk) then
            if count_clk = waitCycles then
                count_clk <= 0;
            else
                count_clk <= count_clk + 1;
            end if;
        end if;
    end process;
    
    -- Process for paddle control
    process(in_clk)
    begin
        if rising_edge(in_clk) then
            -- Reset condition
            if reset = '0' then
                y_paddle_internal <= 240;  -- center of screen: 480/2
            end if;
            
            -- Paddle movement control
            if push1 = '0' and count_clk = waitCycles then
                y_paddle_internal <= y_paddle_internal - 1;
            elsif push2 = '0' and count_clk = waitCycles then
                y_paddle_internal <= y_paddle_internal + 1;
            end if;
        end if;
    end process;
    
    -- Process for paddle display control
    process(in_clk)
    begin
        if rising_edge(in_clk) then
            if (to_integer(unsigned(v_pos)) > screenWidth - paddleWidth) and (to_integer(unsigned(h_pos)) >= y_paddle_internal) and (to_integer(unsigned(h_pos)) <= y_paddle_internal + paddleHeight) then
                dispPaddle2 <= '1';
            else
                dispPaddle2 <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
