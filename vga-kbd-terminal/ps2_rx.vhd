-- Import required libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity definition for PS/2 Receiver
entity ps2_rx is
    port(
        clk, reset : in std_logic;          -- Clock and reset signals
        ps2d, ps2c : in std_logic;           -- PS/2 data and clock signals
        rx_en      : in std_logic;           -- Receiver enable
        rx_done_tick : out std_logic;        -- Receive done tick
        dout : out std_logic_vector(7 downto 0) -- Output data
    );
end ps2_rx;

-- Architecture definition
architecture arch of ps2_rx is
    -- State type definition
    type statetype is(idle, dps, load);
    
    -- Internal signals
    signal state_reg, state_next : statetype;
    signal filter_reg, filter_next : std_logic_vector(7 downto 0);
    signal f_ps2c_reg, f_ps2c_next : std_logic;
    signal b_reg, b_next : std_logic_vector(10 downto 0);
    signal n_reg, n_next : unsigned(3 downto 0);
    signal fall_edge : std_logic;
begin
    -- Process to update the filtered clock and reset signals
    process(clk, reset)
    begin
        if reset = '1' then
            filter_reg <= (others => '0');
            f_ps2c_reg <= '0';
        elsif(clk'event and clk = '1') then
            filter_reg <= filter_next;
            f_ps2c_reg <= f_ps2c_next;
        end if;
    end process;
    
    -- Filter the PS/2 clock signal
    filter_next <= ps2c & filter_reg(7 downto 1);
    f_ps2c_next <= '1' when filter_reg = "11111111" else
                   '0' when filter_reg = "00000000" else
                   f_ps2c_reg;
    
    -- Detect falling edge of the filtered clock
    fall_edge <= f_ps2c_reg and (not f_ps2c_next);
    
    -- State transition and register update process
    process(clk, reset) 
    begin
        if(reset = '1') then
            state_reg <= idle;
            n_reg <= (others => '0');
            b_reg <= (others => '0');
        elsif(clk'event and clk = '1') then
            state_reg <= state_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end if;
    end process;
    
    -- Main state machine
    process(state_reg, n_reg, b_reg, fall_edge, rx_en, ps2d)
    begin
        rx_done_tick <= '0';
        state_next <= state_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        
        case state_reg is
            when idle => 
                if fall_edge = '1' and rx_en = '1' then
                    b_next <= ps2d & b_reg(10 downto 1);
                    n_next <= "1001";
                    state_next <= dps;
                end if;
            when dps =>
                if fall_edge = '1' then    
                    b_next <= ps2d & b_reg(10 downto 1);
                    if n_reg = 0 then
                        state_next <= load;
                    else
                        n_next <= n_reg - 1;
                    end if;
                end if;
            when load =>
                state_next <= idle;
                rx_done_tick <= '1';
        end case;
    end process;
    
    -- Output data signal
    dout <= b_reg(8 downto 1);
end arch;
