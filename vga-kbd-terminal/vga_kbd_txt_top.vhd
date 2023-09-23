library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        uart_rx                 : in std_logic;
        --Switch to change input between KB and UART
        input_sw                : in std_logic
        );
end vga_kbd_txt_top;

architecture arc_vga_kbd_txt_top of vga_kbd_txt_top is
    -- vga signals
    signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
    signal video_on, pixel_tick : std_logic;
    signal rgb_reg, rgb_next : std_logic_vector(3 downto 0);
    --kbd signals
    signal kb_not_empty, kb_buf_empty : std_logic;
    signal key_code, ascii_code : std_logic_vector(7 downto 0);
    signal kb_enter_tick : std_logic;
    signal up_tick, down_tick, left_tick, right_tick : std_logic;
    signal kb_bck_spc_tick : std_logic;
    --UART signals
    signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
    signal tx_full, rx_empty : std_logic;
    signal data_available : std_logic;
    signal enter_tick_uart : std_logic;
    signal bck_spc_tick_uart : std_logic;
    --Signals for selection
    signal key_code_to_vga : std_logic_vector(6 downto 0);
    signal enter_tick : std_logic;
    signal bck_spc_tick : std_logic;
    signal to_we : std_logic;
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
                    key_code => key_code_to_vga,
                    video_on => video_on, 
                    pixel_x => pixel_x, 
                    pixel_y => pixel_y, 
                    we => to_we, 
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
                    enter_tick => kb_enter_tick,
                    kb_buf_empty => kb_buf_empty, 
                    up_tick => up_tick, 
                    down_tick => down_tick, 
                    left_tick => left_tick,
                    right_tick => right_tick, 
                    bck_spc_tick => kb_bck_spc_tick);

    key2a_unit : entity work.key2ascii(arch)
        port map(   key_code => key_code, 
                    ascii_code => ascii_code);

    uart_unit  : entity work.uartcore(str_arch)
        port map(   clk => clk_50,
                    reset => not(key(0)),
                    rx => uart_rx,
                    tx => uart_tx,
                    tx_full => tx_full,
                    enter_tick => enter_tick_uart,
                    bck_spc_tick => bck_spc_tick_uart,
                    r_data => rec_data,
                    w_data => rec_data1,
                    data_available => data_available);

    process(clk_50)
    begin
        if(clk_50'event and clk_50 = '1') then
            if(pixel_tick = '1') then
                rgb_reg <= rgb_next;
            end if;
        end if;
        if(input_sw = '1') then
            key_code_to_vga <= rec_data(6 downto 0);
            enter_tick <= enter_tick_uart;
            bck_spc_tick <= bck_spc_tick_uart;
            to_we <= data_available;
        else
            key_code_to_vga <= ascii_code(6 downto 0);
            enter_tick <= kb_enter_tick;
            bck_spc_tick <= kb_bck_spc_tick;
            to_we <= kb_not_empty;
        end if;
    end process;
    kb_not_empty <= not kb_buf_empty;
    rec_data1 <= std_logic_vector(unsigned(rec_data));
    vga_r <= (others => rgb_reg(2));
    vga_g <= (others => rgb_reg(1));
    vga_b <= (others => rgb_reg(0));
end arc_vga_kbd_txt_top;
        