library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
    Port ( clk      : in  STD_LOGIC;
           rst_n    : in  STD_LOGIC;
           rx_in    : in  STD_LOGIC;
           rx_data  : out STD_LOGIC_VECTOR(7 downto 0);
           rx_ready : out STD_LOGIC);
end uart_rx;

architecture Behavioral of uart_rx is
    signal rx_state : integer := 0;
    signal rx_count : integer := 0;
    signal rx_shift : STD_LOGIC_VECTOR(9 downto 0);
    signal baud_counter : integer := 0;
    constant BAUD_RATE : integer := 9600; -- Baud rate
    constant CLK_FREQ  : integer := 50000000; -- Clock frequency in Hz
    constant DIVISOR   : integer := CLK_FREQ / BAUD_RATE;
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            rx_state <= 0;
            rx_count <= 0;
            baud_counter <= 0;
            rx_shift <= (others => '0');
        elsif rising_edge(clk) then
            case rx_state is
                when 0 =>
                    rx_ready <= '0';
                    if rx_in = '0' then  -- Start bit detected
                        rx_state <= 1;
                        rx_count <= 0;
                        baud_counter <= DIVISOR / 2;  -- Sample in the middle of the bit
                    end if;
                when 1 =>
                    if baud_counter = DIVISOR - 1 then
                        rx_shift(rx_count) <= rx_in;
                        rx_count <= rx_count + 1;
                        if rx_count = 10 then
                            rx_state <= 0;
                            rx_data <= rx_shift(7 downto 0);
                            rx_ready <= '1';
                        end if;
                        baud_counter <= 0;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;
                when others =>
                    rx_state <= 0;
            end case;
        end if;
    end process;
end Behavioral;
