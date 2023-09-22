-- Import required libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity definition for a debounce circuit
entity debounce is
    port(
        clk, reset      : in std_logic;  -- Clock and reset signals
        sw              : in std_logic;  -- Input switch signal
        db_level, db_tick: out std_logic -- Debounced output level and tick signals
    );
end debounce;

-- Architecture definition using a finite state machine with datapath (FSMD)
architecture arc_debounce of debounce is
    -- Constant for the counter depth
    constant N: integer := 21;
    
    -- Enumerate states for the FSM
    type state_type is(zero, wait0, one, wait1);
    
    -- State and counter registers and next-state signals
    signal state_reg, state_next : state_type;
    signal q_reg, q_next : unsigned(N-1 downto 0);
begin
    -- Synchronous process: Register updates
    process(clk, reset)
    begin
        if(reset = '1') then
            state_reg <= zero;
            q_reg <= (others => '0');
        elsif(clk'event and clk = '1') then
            state_reg <= state_next;
            q_reg <= q_next;
        end if;
    end process;
    
    -- Combinational process: Next-state logic and output assignment
    process(state_reg, q_reg, sw, q_next)
    begin
        -- Default assignments
        state_next <= state_reg;
        q_next <= q_reg;
        db_tick <= '0';
        
        -- FSM logic
        case state_reg is
            when zero =>
                db_level <= '0';
                if(sw = '1') then
                    state_next <= wait1;
                    q_next <= (others => '1');
                end if;
                
            when wait1 =>
                db_level <= '0';
                if(sw = '1') then    
                    q_next <= q_reg - 1;
                    if(q_next = 0) then    
                        state_next <= one;
                        db_tick <= '1';
                    end if;
                else
                    state_next <= zero;
                end if;
                
            when one =>
                db_level <= '1';
                if(sw = '0') then
                    state_next <= wait0;
                    q_next <= (others => '1');
                end if;
                
            when wait0 =>
                db_level <= '1';
                if(sw = '0') then
                    q_next <= q_reg - 1;
                    if(q_next = 0) then
                        state_next <= zero;
                    end if;
                else
                    state_next <= one;
                end if;
        end case;
    end process;
end arc_debounce;
