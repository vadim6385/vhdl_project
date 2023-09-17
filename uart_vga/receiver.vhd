package uart_constants is

   constant clockfreq  : integer := 25000000 ;
   constant baud       : integer := 115200   ;
   constant t1_count   : integer := clockfreq / baud ; -- 217
   constant t2_count   : integer := t1_count / 2     ; -- 108

end uart_constants ;

-- UART code --
use work.uart_constants.all ;
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use ieee.numeric_std.all;

entity receiver is
	port ( resetN     : in std_logic                    ;
		   clk        : in std_logic                    ;
		   rx         : in std_logic                    ;
		   read_dout  : in std_logic                    ;
		   dout       : out std_logic_vector(7 downto 0);
		   rx_ready   : out std_logic                   ;
           dout_new   : out std_logic                   ;
		   dout_ready : out std_logic             	   );
end receiver ;

architecture arc_receiver of receiver is

	-- internal shift register
	signal ena_shift  : std_logic                    ; 
	signal rxs        : std_logic                    ;
	signal dint       : std_logic_vector(7 downto 0) ;

	-- data counter
	signal dcount     : std_logic_vector(2 downto 0) ; -- data counter
	signal ena_dcount : std_logic                    ; -- enable data counter
	signal clr_dcount : std_logic                    ; -- clear data counter
	signal eoc        : std_logic                    ; -- end count

	-- Timer
	signal tcount     : std_logic_vector(12 downto 0);
	signal te         : std_logic                    ; -- Timer enable/reset
	signal t1         : std_logic                    ; -- End of one time slot
	signal t2         : std_logic                    ; -- End of two time slot

	-- Output flip flop
	signal dout_ena   : std_logic                    ; -- flip flop enable
	
	-- state machine
	type state is
	(
		idle       ,
		start_wait ,
		start_chk  ,
		data_wait  ,
		data_chk   ,
		data_count ,
		stop_wait  ,
		stop_chk   ,
		break_wait ,
		update_out ,
		tell_out ) ;
	
	signal present_state, next_state: state;

	begin
	
		-- state changer --
		process (resetN, clk, next_state)
		begin 
			if resetN = '0' then present_state <= idle;
			elsif rising_edge(clk) then
				present_state <= next_state;
			end if;
		end process;

		-- data counter --
		process (resetN, clk)
		begin
			if resetN = '0' then dcount <= (others => '0') ;
			elsif rising_edge(clk) then
				if clr_dcount = '1' then dcount <= (others => '0') ;
				elsif ena_dcount = '1' then dcount <= dcount + 1 ;
				end if ;
			end if ;
		end process ;
		eoc <= '1' when (dcount = "111") else '0' ;
	
		-- timer --
		process (resetN,clk)
			begin
				if resetN = '0' then tcount <= (others => '0');
				elsif rising_edge(clk) then
					if te = '1' then 
					 if tcount /= t1_count then tcount <= tcount + 1;
					end if ;
				else
					tcount <= (others => '0') ;
				end if ;
			end if ;
		end process;
		t1 <= '1' when (t1_count = tcount) else '0' ;
		t2 <= '1' when (t2_count = tcount) else '0' ;

		-- shift register --
		process (resetN, clk)
		begin 
			if resetN = '0' then dint <= (others => '0') ;
			elsif rising_edge(clk) then
				if ena_shift = '1' then 
				-- dint(7) <= rxs;  dint (6 downto 0) <= dint (7 downto 1) ;
				dint <= rxs & dint(7 downto 1) ;
				end if ;
			end if ;
		end process ;

		-- Input synch Flip flop
		process (resetN, clk)
		begin 
			if resetN = '0' then rxs <='1';
			elsif rising_edge(clk) then rxs<=rx;
			end if ;
		end process ;

		-- Output flag Flip flop
		process (resetN, clk)
		begin 
			if rising_edge(clk) then 
				--if read_dout = '1' then dout_ready <= '0';
				--elsif dout_ena = '1' then dout_ready <= '1';
				--end if;
				if   dout_ena = '1' and read_dout = '1' then
					dout_ready <= 'Z' ;
				elsif  dout_ena = '0' and read_dout = '1' then
					dout_ready <= '0' ; 
				elsif  dout_ena = '1' and read_dout = '0' then
					dout_ready <= '1' ;  
				end if ;
			end if ;
		end process ;

		-- Output register Flip flop
		process (resetN, clk)
		begin 
			if resetN = '0' then dout <= (others => '0');
			elsif rising_edge(clk) then 
				if dout_ena = '1' then dout <= dint;
				end if;
			end if ;
		end process ;

			-- state machine-
	process(rxs,t1,t2, eoc,present_state, clk)
	begin 
		ena_shift <= '0'; ena_dcount <= '0' ; clr_dcount <= '0' ; 
		te <= '0' ; rx_ready <= '0'; dout_ena <= '0' ; dout_new <= '0' ;
		case present_state is
			when idle =>
			report "idle" ; 
			rx_ready <= '1'; clr_dcount <= '1'; dout_new <= '0';
			if rxs = '1' then next_state <= idle;
			else next_state <= start_wait ;
			end if;						
			
			when start_wait =>
			report "start_wait" ; --0
			te <= '1';	
			if t2 = '0' then next_state <= start_wait;
			else next_state <= start_chk ;
			end if;						
			
			when start_chk =>
			report "start_chk" ; --1
			if rxs = '1' then next_state <= idle;
			else next_state <= data_wait ;
			end if;						

			when data_wait =>
			report "data_wait" ; --2
			te <= '1';	
			if t1 = '0' then next_state <= data_wait;
			else next_state <= data_chk ;
			end if;		
			
			when data_chk =>
			report "data_chk" ; --3
			ena_shift <= '1';	
			if eoc = '0' then next_state <= data_count;
			else next_state <= stop_wait ;
			end if;						

			when data_count =>
			report "data_count" ; --4
			ena_dcount <= '1';	
			next_state <= data_wait;

			when stop_wait =>
			report "stop_wait" ; --5
			te <= '1';	
			if t1 = '0' then next_state <= stop_wait;
			else next_state <= stop_chk ;
			end if;						

			when stop_chk =>
			report "stop_chk" ; --6
			if rxs = '0' then next_state <= break_wait;
			else next_state <= update_out ;
			end if;						

			when break_wait =>
		    report "break_wait" ; --7
			if rxs = '0' then next_state <= break_wait;
			else next_state <= idle ;
			end if;						

			when update_out =>
			report "update_out" ; --8
			dout_ena <= '1';	
			next_state <= tell_out;
			
			when tell_out =>
			report "tell_out" ; --9
			dout_new <= '1';	
			next_state <= idle;
			
			when others => next_state <=idle;

		end case;
	end process;

end arc_receiver ;

