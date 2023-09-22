-- Import IEEE standard libraries
library ieee;
-- Use std_logic for signal types and numeric_std for numeric operations
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define the entity for a dual-port synchronous RAM
entity altera_dual_port_ram_sync is
    -- Define generic parameters for address and data width
    generic(
        ADDR_WIDTH : integer := 4;
        DATA_WIDTH : integer := 8
    );
    -- Define the ports of the entity
    port(
        clk : in std_logic;        -- Clock input
        we : in std_logic;         -- Write Enable
        addr_a : in std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Address A input
        addr_b : in std_logic_vector(ADDR_WIDTH-1 downto 0);  -- Address B input
        din_a : in std_logic_vector(DATA_WIDTH-1 downto 0);   -- Data In A
        dout_a : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Data Out A
        dout_b : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Data Out B
    );
end altera_dual_port_ram_sync;

-- Implement the behavior of the dual-port synchronous RAM
architecture arc_altera_dual_port_ram_sync of altera_dual_port_ram_sync is
    -- Define the RAM type, which is an array of std_logic_vectors
    type ram_type is array(0 to 2**ADDR_WIDTH-1) 
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Declare the RAM signal
    signal ram : ram_type;
    -- Declare the registered addresses for A and B ports
    signal addr_a_reg, addr_b_reg : 
            std_logic_vector(ADDR_WIDTH-1 downto 0);
begin    
    -- Clock process
    process(clk)
    begin
        -- On a rising clock edge
        if(clk'event and clk = '1') then
            -- Write to RAM if write enable is high
            if(we = '1') then
                ram(to_integer(unsigned(addr_a))) <= din_a;
            end if;
            -- Register the addresses for future use
            addr_a_reg <= addr_a;
            addr_b_reg <= addr_b;
        end if;
    end process;
    
    -- Assign dout_a and dout_b based on the registered addresses
    dout_a <= ram(to_integer(unsigned(addr_a_reg)));
    dout_b <= ram(to_integer(unsigned(addr_b_reg)));
end arc_altera_dual_port_ram_sync;
