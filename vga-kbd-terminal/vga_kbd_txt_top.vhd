library ieee;
use ieee.std_logic_1164.all;
entity vga_kbd_txt_top is
    port(
        -- vga signals
        clk_50                  : in std_logic;
        key                     : in std_logic_vector(2 downto 0);
        vgaHsync, vgaVsync      : out std_logic;    
        vga_r, vga_b, vga_g     : out std_logic_vector(3 downto 0);
        --kbd signals
        kbd_dat, kbd_clk        : in std_logic;
        --UART signals
        uart_tx                 : out std_logic;
        uart_rx                 : in std_logic );
end vga_kbd_txt_top;

architecture arc_vga_kbd_txt_top of vga_kbd_txt_top is

    component vga_kbd_txt
    port(
        clk, reset : in std_logic;
        btn : in std_logic_vector(1 downto 0);
        key_code : in std_logic_vector(6 downto 0);
        video_on : in std_logic;
        pixel_x, pixel_y : in std_logic_vector(9 downto 0);
        enter_tick : in std_logic;
        up_tick, down_tick , left_tick, right_tick : in std_logic;
        bck_spc_tick : in std_logic;
        we : in std_logic;
        text_rgb : out std_logic_vector(3 downto 0)
    );
    end component;

    component vga_sync
        port(
            clk, reset : in std_logic;
            hsync, vsync : out std_logic;
            video_on, p_tick : out std_logic;
            pixel_x, pixel_y : out std_logic_vector(9 downto 0)
        );
    end component;
    
    component kb_code
    generic(W_SIZE : integer := 2);
    port(
        clk, reset : in std_logic;
        ps2d, ps2c : in std_logic;
        rd_key_code : in std_logic;
        key_code : out std_logic_vector(7 downto 0);
        enter_tick : out std_logic;
        up_tick, down_tick , left_tick, right_tick : out std_logic;
        bck_spc_tick : out std_logic;
        kb_buf_empty : out std_logic
    );
    end component;
    
    component key2ascii
       port (
          key_code: in std_logic_vector(7 downto 0);  -- Input keyboard scan code
          ascii_code: out std_logic_vector(7 downto 0) -- Output ASCII code
       );
    end component;
    
    component uart
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

    -- vga signals
    signal pixel_x, pixel_y     : std_logic_vector(9 downto 0);
    signal video_on, pixel_tick : std_logic;
    signal rgb_reg, rgb_next    : std_logic_vector(3 downto 0);
    signal vga_reg, vga_next    : std_logic_vector(6 downto 0);
    --kbd signals
    signal scan_data, w_data : std_logic_vector(7 downto 0);
    signal kb_not_empty, kb_buf_empty : std_logic;
    signal key_code, ascii_code : std_logic_vector(7 downto 0);
    signal enter_tick : std_logic;
    signal up_tick, down_tick, left_tick, right_tick : std_logic;
    signal bck_spc_tick : std_logic;
    --uart_signals
    signal dout_sig : std_logic;
    signal uart_din, uart_din_next : std_logic_vector(7 downto 0);
    signal uart_dout, uart_dout_next : std_logic_vector(7 downto 0);
begin
    vga_sync_unit : entity work.vga_sync
        port map(   clk => clk_50, 
                    reset => not(key(0)),
                    vsync => vgaVsync, 
                    hsync => vgaHsync, 
                    video_on => video_on,
                    p_tick => pixel_tick, 
                    pixel_x => pixel_x, 
                    pixel_y => pixel_y);
    text_gen_unit : entity work.vga_kbd_txt
        port map(   clk => clk_50, 
                    reset => not(key(0)), 
                    btn => not(key(2 downto 1)), 
                    key_code => vga_reg,
                    video_on => video_on, 
                    pixel_x => pixel_x, 
                    pixel_y => pixel_y, 
                    we => kb_not_empty, 
                    enter_tick => enter_tick,
                    text_rgb => rgb_next, 
                    up_tick => up_tick, 
                    down_tick => down_tick, 
                    left_tick => left_tick,
                    right_tick => right_tick, 
                    bck_spc_tick => bck_spc_tick);
    kb_code_unit : entity work.kb_code(arch)
        port map(   clk => clk_50, 
                    reset => not(key(0)), 
                    ps2d => kbd_dat, 
                    ps2c => kbd_clk,
                    rd_key_code => kb_not_empty, 
                    key_code => key_code, 
                    enter_tick => enter_tick,
                    kb_buf_empty => kb_buf_empty, 
                    up_tick => up_tick, 
                    down_tick => down_tick, 
                    left_tick => left_tick,
                    right_tick => right_tick, 
                    bck_spc_tick => bck_spc_tick);
    key2a_unit : entity work.key2ascii(arch)
        port map(   key_code => key_code, 
                    ascii_code => ascii_code);
    uart_unit  : entity work.uart
        port map(   clk => clk_50,
                    resetN => not(key(0)),
                    rx => uart_rx,
                    tx => uart_tx,
                    din => uart_din_next,
                    dout => uart_dout_next,
                    read_dout => enter_tick,
                    write_din => dout_sig,
                    dout_new => dout_sig
                    );
    process(clk_50)
    begin
        if(clk_50'event and clk_50 = '1') then
            if(pixel_tick = '1') then
                rgb_reg <= rgb_next;
                vga_reg <= vga_next;
                uart_din <= uart_din_next;
                uart_dout <= uart_dout_next;
            end if;
        end if;
    end process;
    vga_next <= ascii_code(6 downto 0);
    uart_din_next <= ascii_code;
    --vga_next <= uart_dout(6 downto 0);
    kb_not_empty <= not kb_buf_empty;
    vga_r <= (others => rgb_reg(2));
    vga_g <= (others => rgb_reg(1));
    vga_b <= (others => rgb_reg(0));
end arc_vga_kbd_txt_top;
        