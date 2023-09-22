library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;        
entity rise is
   port ( resetN,clk,din : in  std_logic ;
          dout           : out std_logic ) ;
end rise ;
architecture arc_rise of rise is
   signal sampled1 , sampled2 : std_logic ;
begin

   -- sync
   process ( clk , resetN )
   begin
      if resetN = '0' then
        sampled1 <= '0' ;
        sampled2 <= '0' ;
      elsif rising_edge(clk) then
        sampled1 <= din      ;
        sampled2 <= sampled1 ;
      end if ;
   end process ;
   
   -- logic
   dout <= sampled1 and not sampled2 ;
end arc_rise ;
