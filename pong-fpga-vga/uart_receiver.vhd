-- Importing necessary libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entity declaration
entity uart_receiver is
    Port ( clk_in : in STD_LOGIC;
           serial_data_in : in STD_LOGIC;
           data_valid : out STD_LOGIC;
           data_byte_op : out STD_LOGIC_VECTOR(7 downto 0));
end uart_receiver;

-- Architecture declaration
architecture Behavioral of uart_receiver is
    -- Constants
    constant baudRate : integer := 115200;
    constant clk_per_bit : integer := 434;
    
    -- State encoding
    constant idle : STD_LOGIC_VECTOR(2 downto 0) := "000";
    constant startBit : STD_LOGIC_VECTOR(2 downto 0) := "001";
    constant stopBit : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant dataReceive : STD_LOGIC_VECTOR(2 downto 0) := "011";
    constant clear : STD_LOGIC_VECTOR(2 downto 0) := "100";
    
    -- Internal signals
    signal clk_count : integer := 0;
    signal bit_index : integer := 0;
    signal output_byte : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal fsm_state : STD_LOGIC_VECTOR(2 downto 0) := idle;
    signal valid_data : STD_LOGIC := '0';
    
begin
    -- Assign internal signals to output ports
    data_valid <= valid_data;
    data_byte_op <= output_byte;
    
    -- FSM process
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            case fsm_state is
                when idle =>
                    valid_data <= '0';
                    clk_count <= 0;
                    bit_index <= 0;
                    if serial_data_in = '0' then
                        fsm_state <= startBit;
                    else
                        fsm_state <= idle;
                    end if;
                    
                when startBit =>
                    if clk_count = (clk_per_bit / 2) then
                        if serial_data_in = '0' then
                            clk_count <= 0;
                            fsm_state <= dataReceive;
                        else
                            fsm_state <= idle;
                        end if;
                    else
                        clk_count <= clk_count + 1;
                        fsm_state <= startBit;
                    end if;
                    
                when dataReceive =>
                    if clk_count < clk_per_bit - 1 then
                        clk_count <= clk_count + 1;
                        fsm_state <= dataReceive;
                    else
                        clk_count <= 0;
                        output_byte(bit_index) <= serial_data_in;
                        if bit_index <= 6 then
                            bit_index <= bit_index + 1;
                            fsm_state <= dataReceive;
                        else
                            bit_index <= 0;
                            fsm_state <= stopBit;
                        end if;
                    end if;
                    
                when stopBit =>
                    if clk_count < clk_per_bit - 1 then
                        clk_count <= clk_count + 1;
                        fsm_state <= stopBit;
                    else
                        valid_data <= '1';
                        clk_count <= 0;
                        fsm_state <= clear;
                    end if;
                    
                when clear =>
                    clk_count <= 0;
                    valid_data <= '0';
                    fsm_state <= idle;
                    
                when others =>
                    fsm_state <= idle;
                    
            end case;
        end if;
    end process;
    
end Behavioral;
