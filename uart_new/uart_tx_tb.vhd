library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx_tb is
end uart_tx_tb;

architecture sim of uart_tx_tb is
    signal clk      : STD_LOGIC := '0';
    signal rst_n    : STD_LOGIC := '0';
    signal tx_data  : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal tx_start : STD_LOGIC := '0';
    signal tx_ready : STD_LOGIC;
    signal tx_out   : STD_LOGIC;

    -- Clock period definitions
    constant clk_period : time := 20 ns;
begin
    -- Instantiate the UART transmitter
    UUT: entity work.uart_tx
        port map (
            clk      => clk,
            rst_n    => rst_n,
            tx_data  => tx_data,
            tx_start => tx_start,
            tx_ready => tx_ready,
            tx_out   => tx_out
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
        -- Reset the UART transmitter
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait for clk_period;

        -- Wait for UART transmitter to be ready
        wait until tx_ready = '1';

        -- Send 'H' (ASCII 0x48)
        tx_data <= "01001000";
        tx_start <= '1';
        wait for clk_period;
        tx_start <= '0';
        wait until tx_ready = '1';

        -- Send 'i' (ASCII 0x69)
        tx_data <= "01101001";
        tx_start <= '1';
        wait for clk_period;
        tx_start <= '0';
        wait until tx_ready = '1';

        -- End simulation
        wait;
    end process;
end sim;
