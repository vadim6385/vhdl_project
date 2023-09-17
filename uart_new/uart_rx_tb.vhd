library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture sim of uart_rx_tb is
    signal clk      : STD_LOGIC := '0';
    signal rst_n    : STD_LOGIC := '0';
    signal rx_in    : STD_LOGIC := '1';
    signal rx_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_ready : STD_LOGIC;

    constant clk_period : time := 20 ns;
begin
    -- Instantiate the UART receiver
    UUT: entity work.uart_rx
        port map (
            clk      => clk,
            rst_n    => rst_n,
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
        -- Reset the UART receiver
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait for clk_period;

        -- Transmit 'H' (ASCII 0x48) with start and stop bits "0100100010"
        rx_in <= "0100100010";
        wait for 10 * clk_period;

        -- Transmit 'i' (ASCII 0x69) with start and stop bits "0101101001"
        rx_in <= "0101101001";
        wait for 10 * clk_period;

        -- End simulation
        wait;
    end process;
end sim;
