-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration
entity ball_ctrl is
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           gameRunning : in STD_LOGIC;
           h_pos : in STD_LOGIC_VECTOR(11 downto 0);
           v_pos : in STD_LOGIC_VECTOR(11 downto 0);
           disp_ball : out STD_LOGIC;
           ball_x : out STD_LOGIC_VECTOR(5 downto 0);
           ball_y : out STD_LOGIC_VECTOR(5 downto 0));
end ball_ctrl;

-- Architecture declaration
architecture Behavioral of ball_ctrl is
    -- Constants
    constant ball_width : integer := 16;
    constant ball_height : integer := 16;
    constant screenWidth : integer := 640;
    constant screenHeight : integer := 480;
    constant waitCycles : integer := 2500000;
    
    -- Internal signals
    signal ball_x_internal : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    signal ball_y_internal : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    signal ball_x_p : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    signal ball_y_p : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    signal count_clk : integer := 0;
    
begin
    -- Assign internal signals to output ports
    ball_x <= ball_x_internal;
    ball_y <= ball_y_internal;
    
    -- Process for ball position control
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if (gameRunning = '0' or reset = '0') then
                ball_x_internal <= conv_std_logic_vector(screenWidth/2, 6);
                ball_y_internal <= conv_std_logic_vector(screenHeight/2, 6);
                ball_x_p <= conv_std_logic_vector(screenWidth/2 + 1, 6);
                ball_y_p <= conv_std_logic_vector(screenHeight/2 - 1, 6);
            else
                if (count_clk < waitCycles) then
                    count_clk <= count_clk + 1;
                else
                    count_clk <= 0;
                    ball_x_p <= ball_x_internal;
                    ball_y_p <= ball_y_internal;
                    
                    if ((ball_x_p < ball_x_internal and ball_x_internal = conv_std_logic_vector(screenWidth-1, 6)) or 
                        (ball_x_p > ball_x_internal and ball_x_internal /= "000000")) then
                        ball_x_internal <= ball_x_internal - 1;
                    else
                        ball_x_internal <= ball_x_internal + 1;
                    end if;
                    
                    if ((ball_y_p < ball_y_internal and ball_y_internal = conv_std_logic_vector(screenHeight-1, 6)) or 
                        (ball_y_p > ball_y_internal and ball_y_internal /= "000000")) then
                        ball_y_internal <= ball_y_internal - 1;
                    else
                        ball_y_internal <= ball_y_internal + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Process for display control
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if (v_pos = ball_x_internal and h_pos = ball_y_internal) then
                disp_ball <= '1';
            else
                disp_ball <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
