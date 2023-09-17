library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx is
    Port ( clk      : in  STD_LOGIC;
           rst_n    : in  STD_LOGIC;
           tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);
           tx_start : in  STD_LOGIC;
           tx_ready : out STD_LOGIC;
           tx_out   : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is
    signal tx_state : integer := 0;
    signal tx_count : integer := 0;
    signal tx_shift : STD_LOGIC_VECTOR(9 downto 0);
    signal baud_counter : integer := 0;
    constant BAUD_RATE : integer := 9600; -- Baud rate
    constant CLK_FREQ  : integer := 50000000; -- Clock frequency in Hz
    constant DIVISOR   : integer := CLK_FREQ / BAUD_RATE;
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            tx_state <= 0;
            tx_count <= 0;
            baud_counter <= 0;
            tx_shift <= (others => '0');
        elsif rising_edge(clk) then
            case tx_state is
                when 0 =>
                    tx_ready <= '1';
                    if tx_start = '1' then
                        tx_shift(7 downto 0) <= tx_data;
                        tx_shift(9 downto 8) <= "10"; -- Start and Stop bits
                        tx_state <= 1;
                        tx_count <= 0;
                    end if;
                when 1 =>
                    tx_ready <= '0';
                    if baud_counter = DIVISOR - 1 then
                        tx_out <= tx_shift(tx_count);
                        tx_count <= tx_count + 1;
                        if tx_count = 10 then
                            tx_state <= 0;
                        end if;
                        baud_counter <= 0;
                    else
                        baud_counter <= baud_counter + 1;
                    end if;
                when others =>
                    tx_state <= 0;
            end case;
        end if;
    end process;
end Behavioral;
