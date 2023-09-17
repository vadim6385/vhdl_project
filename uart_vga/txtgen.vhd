-- text generator for VGA
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
entity txtgen is
    port    ( clk       : in        std_logic                   ;
              count_v   : in        std_logic_vector(9 downto 0);
              count_h   : in        std_logic_vector(9 downto 0);
              char_code : buffer    std_logic_vector(9 downto 0);
              pospix_v  : buffer    std_logic_vector(2 downto 0);
              pospix_h  : buffer    std_logic_vector(2 downto 0));
end txtgen;