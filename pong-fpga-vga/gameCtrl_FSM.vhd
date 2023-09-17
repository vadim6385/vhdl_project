-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity declaration
entity gameCtrl_FSM is
    Port ( clk_in : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           x_ball : in STD_LOGIC_VECTOR(5 downto 0);
           y_ball : in STD_LOGIC_VECTOR(5 downto 0);
           y_paddle1 : in STD_LOGIC_VECTOR(11 downto 0);
           y_paddle2 : in STD_LOGIC_VECTOR(11 downto 0);
           game_active : out STD_LOGIC;
           P1score : out integer;
           P2score : out integer);
end gameCtrl_FSM;

-- Architecture declaration
architecture Behavioral of gameCtrl_FSM is
    -- Constants
    constant max_score : integer := 5;
    constant paddleHeight : integer := 6;
    
    -- FSM states
    type state_type is (idle, gameRunning, scoreP1, scoreP2, clear);
    signal fsm : state_type := idle;
    
    -- Internal signals
    signal P1score_internal : integer := 0;
    signal P2score_internal : integer := 0;
    
begin
    -- Assign internal signals to output ports
    P1score <= P1score_internal;
    P2score <= P2score_internal;
    game_active <= '1' when (fsm = gameRunning) else '0';
    
    -- Process for game control FSM
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '0' then
                fsm <= idle;
            else
                case fsm is
                    when idle =>
                        P1score_internal <= 0;
                        P2score_internal <= 0;
                        if start = '1' then
                            fsm <= gameRunning;
                        end if;
                        
                    when gameRunning =>
                        if (to_integer(unsigned(x_ball)) = 0 and (to_integer(unsigned(y_ball)) < to_integer(unsigned(y_paddle1)) or to_integer(unsigned(y_ball)) > to_integer(unsigned(y_paddle1)) + paddleHeight)) then
                            fsm <= scoreP2;
                        elsif (to_integer(unsigned(x_ball)) = 0 and (to_integer(unsigned(y_ball)) < to_integer(unsigned(y_paddle2)) or to_integer(unsigned(y_ball)) > to_integer(unsigned(y_paddle2)) + paddleHeight)) then
                            fsm <= scoreP1;
                        end if;
                        
                    when scoreP1 =>
                        if P1score_internal < max_score then
                            P1score_internal <= P1score_internal + 1;
                        else
                            P1score_internal <= 0;
                            fsm <= clear;
                        end if;
                        
                    when scoreP2 =>
                        if P2score_internal < max_score then
                            P2score_internal <= P2score_internal + 1;
                        else
                            P2score_internal <= 0;
                            fsm <= clear;
                        end if;
                        
                    when clear =>
                        fsm <= idle;
                        
                    when others =>
                        fsm <= idle;
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;
