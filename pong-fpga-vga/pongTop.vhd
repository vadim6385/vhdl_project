library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Define the pongTop entity
entity pongTop is
    Port (
        clk_in      : in std_logic;
        Rst         : in std_logic;
        startGame   : in std_logic;
        i_serial    : in std_logic;
        paddleup2   : in std_logic;
        paddledwn2  : in std_logic;
        HSync       : out std_logic;
        VSync       : out std_logic;
        seg1        : out std_logic_vector(6 downto 0);
        seg2        : out std_logic_vector(6 downto 0);
        dout_r      : out std_logic_vector(3 downto 0) ;
        dout_g      : out std_logic_vector(3 downto 0) ;
        dout_b      : out std_logic_vector(3 downto 0) ) ;
end pongTop;

-- Define the architecture
architecture Behavioral of pongTop is
    -- Declare internal signals
    signal displayBall, displayPaddle1, displayPaddle2 : std_logic;
    signal dataValid : std_logic;
    signal dataop : std_logic_vector(7 downto 0);
    signal pu2, pd2 : std_logic;
    signal GameStart : std_logic;
    signal H_pos, V_pos : std_logic_vector(11 downto 0);
    signal paddleY1, paddleY2 : std_logic_vector(11 downto 0);
    signal GAMErunning : std_logic;
    signal ballX, ballY : std_logic_vector(5 downto 0);
    signal score_p1, score_p2 : std_logic_vector(2 downto 0);
    signal score_p1_int : integer := 0;
    signal score_p2_int : integer := 0;
    signal draw : std_logic;
    signal dsig_r, dsig_g, dsig_b : std_logic;
    
begin
    -- Convert integer scores to std_logic_vector
    score_p1 <= std_logic_vector(to_unsigned(score_p1_int, score_p1'length));
    score_p2 <= std_logic_vector(to_unsigned(score_p2_int, score_p2'length));

    -- Instantiate all the modules
    -- UART Receiver
    uart_receiver_inst : entity work.uart_receiver
        port map (
            clk_in => clk_in,
            serial_data_in => i_serial,
            data_valid => dataValid,
            data_byte_op => dataop
        );
    
    -- Debounce for startGame
    debounce_startGame : entity work.debounce_pb
        port map (
            in_clk => clk_in,
            pb_in => startGame,
            pb_out => GameStart
        );
    
    -- Debounce for paddleup2
    debounce_paddleup2 : entity work.debounce_pb
        port map (
            in_clk => clk_in,
            pb_in => paddleup2,
            pb_out => pu2
        );
    
    -- Debounce for paddledwn2
    debounce_paddledwn2 : entity work.debounce_pb
        port map (
            in_clk => clk_in,
            pb_in => paddledwn2,
            pb_out => pd2
        );
    
    -- VGA Controller
    vga_controller_inst : entity work.vga_controller
        port map (
            clk => clk_in,
            rst => Rst,
            Hsync => HSync,
            Vsync => VSync,
            h_pos => H_pos,
            v_pos => V_pos
        );
    
    -- Paddle1 Controller
    paddle1_ctrl_inst : entity work.paddle1_ctrl
        port map (
            in_clk => clk_in,
            reset => Rst,
            y_paddle => paddleY1,
            uart_o => dataop,
            dv => dataValid,
            dispPaddle1 => displayPaddle1,
            h_pos => H_pos,
            v_pos => V_pos
        );
    
    -- Paddle2 Controller
    paddle2_ctrl_inst : entity work.paddle2_ctrl
        port map (
            in_clk => clk_in,
            reset => Rst,
            push1 => pu2,
            push2 => pd2,
            y_paddle => paddleY2,
            dispPaddle2 => displayPaddle2,
            h_pos => H_pos,
            v_pos => V_pos
        );
    
    -- Ball Controller
    ball_ctrl_inst : entity work.ball_ctrl
        port map (
            clk_in => clk_in,
            reset => Rst,
            gameRunning => GAMErunning,
            h_pos => H_pos,
            v_pos => V_pos,
            disp_ball => displayBall,
            ball_x => ballX,
            ball_y => ballY
        );
    
    -- Game Controller FSM
    gameCtrl_FSM_inst : entity work.gameCtrl_FSM
        port map (
            clk_in => clk_in,
            reset => Rst,
            start => GameStart,
            x_ball => ballX,
            y_ball => ballY,
            y_paddle1 => paddleY1,
            y_paddle2 => paddleY2,
            game_active => GAMErunning,
            P1score => score_p1_int,
            P2score => score_p2_int
        );
    
    -- Display Score SSD for Player 1
    displayScore_SSD_p1 : entity work.displayScore_SSD
        port map (
            i_clk => clk_in,
            score => score_p1,
            segment => seg1
        );
    
    -- Display Score SSD for Player 2
    displayScore_SSD_p2 : entity work.displayScore_SSD
        port map (
            i_clk => clk_in,
            score => score_p2,
            segment => seg2
        );
        
    -- Duplicate RGB for VGA
    dup4_inst : entity work.dup4
        port map (
            din_r => dsig_r,
            din_g => dsig_g,
            din_b => dsig_b,
            dout_r => dout_r,
            dout_g => dout_g,
            dout_b => dout_b,
            ena => startGame
            );
    
    -- Logic for rgb output
    draw <= displayBall or displayPaddle1 or displayPaddle2;
    dsig_r <= '1' when draw = '1' else '0';
    dsig_g <= '1' when draw = '1' else '0';
    dsig_b <= '1' when draw = '1' else '0';
end Behavioral;
