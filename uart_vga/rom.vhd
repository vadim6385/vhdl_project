library lpm;
use lpm.lpm_components.all;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
entity rom is
      port ( address        : in     std_logic_vector(7 downto 0) ;
             clk            : in     std_logic                    ;
             data           : out std_logic_vector(7 downto 0)   );

end rom ;
	
architecture arc_rom of rom is
begin 
rom : lpm_rom
generic map (
   lpm_width => 8 ,
   lpm_widthad => 8 ,
   lpm_file => "mem.mif" ,
   lpm_numwords => 256 ,
   lpm_address_control => "REGISTERED" ,
   lpm_outdata => "REGISTERED" )
   port map ( 
      address => address ,
      inclock => clk ,
      outclock => clk ,
      q => data );
end arc_rom ;