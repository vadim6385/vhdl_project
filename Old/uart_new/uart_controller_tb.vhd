library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_controller_tb is
end uart_controller_tb;

architecture sim of uart_controller_tb is
    signal clk      : STD_LOGIC := '0';
    signal rst_n    : STD_LOGIC := '0';
    signal tx_data  : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal tx_start : STD_LOGIC := '0';
    signal tx_ready : STD_LOGIC;
    signal tx_out   : STD_LOGIC;
    signal rx_in    : STD_LOGIC := '1';
    signal rx_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_ready : STD_LOGIC;

    constant clk_period : time := 20 ns;
begin
    -- Instantiate the UART controller
    UUT: entity work.uart_controller
        port map (
            clk      => clk,
            rst_n    => rst_n,
            tx_data  => tx_data,
            tx_start => tx_start,
            tx_ready => tx_ready,
            tx_out   => tx_out,
            rx_in    => rx_in,
            rx_data  => rx_data,
            rx_ready => rx_ready
        );

    -- Clock generation
    clk_process : process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process;

    -- Testbench stimulus
    stim_proc: process
    begin
        -- Reset the UART controller
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait for clk_period;

        -- Wait for UART controller to be ready for transmission
        wait until tx_ready = '1';

        -- Transmit 'H' (ASCII 0x48)
        tx_data <= "01001000";
        tx_start <= '1';
        wait for clk_period;
        tx_start <= '0';
        wait until tx_ready = '1';

        -- Transmit 'i' (ASCII 0x69)
        tx_data <= "01101001";
        tx_start <= '1';
        wait for clk_period;
        tx_start <= '0';
        wait until tx_ready = '1';

        -- Simulate receiving 'H' (ASCII 0x48) with start and stop bits "0100100010"
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;

        -- Simulate receiving 'i' (ASCII 0x69) with start and stop bits "0101101001"
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '0'; wait for clk_period;
        rx_in <= '1'; wait for clk_period;

        -- End simulation
        wait;
    end process;
end sim;
