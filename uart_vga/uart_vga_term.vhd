-- UART VGA terminal top level file

library ieee ;
use ieee.std_logic_1164.all ;

entity uart_vga_term is
    port (  resetN      : in std_logic                         ;
            clk         : in std_logic                         ;
            din         :in  std_logic_vector (7 downto 0)     ;
            write_din   :in  std_logic                         ;
            rx          :in  std_logic                         ;
            read_dout   :in  std_logic                         ;
            tx          :out std_logic                         ;
            tx_ready    :out std_logic                         ;
            rx_ready    :out std_logic                         ;
            dout        :out std_logic_vector(7 downto 0)      ;
            dout_ready  :out std_logic                         ;
            dout_new    :out std_logic                         ) ;
end uart_vga_term ;
architecture arc_uart_vga_term of uart_vga_term is
    component uart is
        port (resetN      :in  std_logic                         ;
        clk         :in  std_logic                         ;
        din         :in  std_logic_vector (7 downto 0)     ;
        write_din   :in  std_logic                         ;
        rx          :in  std_logic                         ;
        read_dout   :in  std_logic                         ;
        tx          :out std_logic                         ;
        tx_ready    :out std_logic                         ;
        rx_ready    :out std_logic                         ;
        dout        :out std_logic_vector(7 downto 0)      ;
        dout_ready  :out std_logic                         ;
        dout_new    :out std_logic                         ) ;
    end component ;
    component 