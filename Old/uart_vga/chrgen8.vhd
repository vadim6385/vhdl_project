-- 64 x 8 x 8 characters generator

library lpm;
use lpm.lpm_components.all;

library ieee ;
use ieee.std_logic_1164.all ;

entity chrgen8 is
    port ( clk          : in std_logic ;
           char_code    : in std_logic_vector(5 downto 0); -- char code
           pospix_v     : in std_logic_vector(2 downto 0); -- row
           pospix_h     : in std_logic_vector(2 downto 0); -- col
           dout         : out std_logic ) ;
end chrgen8 ;
architecture arc_chrgen8 of chrgen8 is
    signal internal_rom_address     : std_logic_vector(11 downto 0);
    signal internal_rom_data        : std_logic_vector(0 downto 0);
begin
    internal_rom_address <= char_code & pospix_v & pospix_h;
    r1: lpm_rom
    generic map (
        lpm_widthad                 => 12              , -- address width
        lpm_numwords                => 4096            , -- length**widthad
        lpm_outdata                 => "REGISTERED"    , -- registered inputs
        lpm_address_control         => "UNREGISTERED"  , -- combinatorial inputs
        lpm_file                    => "CHRGEN8.MIF"   , -- ROM code file name
        lpm_widthad                 => 1               ) -- output data width
    port map (
        address                     => internal_rom_address ,
        outclock                    => clk                  ,
        q                           => internal_rom_data    ) ;
    -- Conversion of std_logic_vector(0) to std_logic
    dout <= internal_rom_data(0) ;
end arc_chrgen8 ;