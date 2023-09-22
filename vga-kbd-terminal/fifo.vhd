-- Import standard libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FIFO Entity definition
entity fifo is
    generic(
        B : natural := 8;  -- Bit-width of data
        W : natural := 4   -- Bit-width of address (determines depth)
    );
    port(
        clk, reset          : in std_logic;  -- Clock and reset signals
        rd, wr              : in std_logic;  -- Read and write control signals
        empty, full         : out std_logic; -- Flags to indicate empty and full states
        w_data              : in std_logic_vector(B-1 downto 0);  -- Write Data
        r_data              : out std_logic_vector(B-1 downto 0)  -- Read Data
    );
end fifo;

-- FIFO Architecture
architecture arch of fifo is
    -- Type declaration for the register file (data storage)
    type reg_file_type is array(2 ** W - 1 downto 0) of 
            std_logic_vector(B - 1 downto 0);
            
    -- Internal signals
    signal array_reg : reg_file_type;
    signal w_ptr_reg, w_ptr_next, w_ptr_succ : std_logic_vector(W - 1 downto 0);
    signal r_ptr_reg, r_ptr_next, r_ptr_succ : std_logic_vector(W - 1 downto 0);
    signal full_reg, full_next   : std_logic;
    signal empty_reg, empty_next : std_logic;
    signal wr_op                 : std_logic_vector(1 downto 0);
    signal wr_en                 : std_logic;
begin    
    -- Synchronous process for writing data into FIFO
    process(clk, reset)
    begin
        if(reset = '1') then
            -- Reset the array_reg
            array_reg <= (others => (others => '0'));
        elsif(clk'event and clk = '1') then
            if wr_en = '1' then
                -- Write data into the FIFO
                array_reg(to_integer(unsigned(w_ptr_reg))) <= w_data;
            end if;
        end if;
    end process;
    
    -- Assign read data output
    r_data <= array_reg(to_integer(unsigned(r_ptr_reg)));
    
    -- Write enable signal, checks if FIFO is full
    wr_en  <= wr and (not full_reg);
    
    -- Synchronous process for pointers and flags
    process(clk, reset)
    begin
        if(reset = '1') then    
            -- Reset pointers and flags
            w_ptr_reg <= (others => '0');
            r_ptr_reg <= (others => '0');
            full_reg  <= '0';
            empty_reg <= '1';
        elsif(clk'event and clk = '1') then
            -- Update pointers and flags
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end if;
    end process;
    
    -- Calculate the next address pointers
    w_ptr_succ <= std_logic_vector(unsigned(w_ptr_reg) + 1);
    r_ptr_succ <= std_logic_vector(unsigned(r_ptr_reg) + 1);
    
    -- Determine next pointers and status flags
    wr_op <= wr & rd;
    process(w_ptr_reg, w_ptr_succ, r_ptr_reg, r_ptr_succ, wr_op, 
                empty_reg, full_reg)
    begin
        w_ptr_next <= w_ptr_reg;
        r_ptr_next <= r_ptr_reg;
        full_next <= full_reg;
        empty_next <= empty_reg;
        
        case wr_op is
            when "00" =>  -- No read or write
            when "01" =>  -- Read operation
                if(empty_reg /= '1') then
                    r_ptr_next <= r_ptr_succ;
                    full_next <= '0';
                    if(r_ptr_succ = w_ptr_reg) then
                        empty_next <= '1';
                    end if;
                end if;
            when "10" =>  -- Write operation
                if(full_reg /= '1') then
                    w_ptr_next <= w_ptr_succ;
                    empty_next <= '0';
                    if(w_ptr_succ = r_ptr_reg) then
                        full_next <= '1';
                    end if;
                end if;
            when others =>  -- Both read and write
                w_ptr_next <= w_ptr_succ;
                r_ptr_next <= r_ptr_succ;
        end case;
    end process;
    
    -- Output the FIFO status flags
    full <= full_reg;
    empty <= empty_reg;
end arch;
