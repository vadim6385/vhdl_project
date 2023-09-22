library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_controller is
    Port ( clk      : in  STD_LOGIC;
           rst_n    : in  STD_LOGIC;
           tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
           tx_start : in  STD_LOGIC;
           tx_ready : out STD_LOGIC;
           tx_out   : out STD_LOGIC;
           rx_in    : in  STD_LOGIC;
           rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
           rx_ready : out STD_LOGIC);
end uart_controller;

architecture Behavioral of uart_controller is
    signal tx_ready_internal : STD_LOGIC;
    signal rx_ready_internal : STD_LOGIC;
begin
    -- Instantiate UART transmitter
    uart_tx_inst: entity work.uart_tx
        port map (
            clk      => clk,
            rst_n    => rst_n,
            tx_data  => tx_data,
            tx_start => tx_start,
            tx_ready => tx_ready_internal,
            tx_out   => tx_out
        );

    -- Instantiate UART receiver
    uart_rx_inst: entity work.uart_rx
        port map (
            clk      => clk,
            rst_n    => rst_n,
            rx_in    => rx_in,
            rx_data  => rx_data,
            rx_ready => rx_ready_internal
        );

    -- Controller logic for tx_ready and rx_ready
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            tx_ready <= '0';
            rx_ready <= '0';
        elsif rising_edge(clk) then
            tx_ready <= tx_ready_internal;
            rx_ready <= rx_ready_internal;
        end if;
    end process;
end Behavioral;
