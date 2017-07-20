library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port (
		-- clock
		clock_50    : in  std_logic;
		-- basic input
		key         : in  std_logic_vector( 3 downto 0); -- push button
		sw          : in  std_logic_vector(17 downto 0); -- toggle switch
		-- led output
		ledg        : out std_logic_vector( 8 downto 0); -- green
		ledr        : out std_logic_vector(17 downto 0); -- red
		-- seven segment output
		hex0        : out std_logic_vector( 6 downto 0);
		hex1        : out std_logic_vector( 6 downto 0);
		hex2        : out std_logic_vector( 6 downto 0);
		hex3        : out std_logic_vector( 6 downto 0);
		hex4        : out std_logic_vector( 6 downto 0);
		hex5        : out std_logic_vector( 6 downto 0);
		hex6        : out std_logic_vector( 6 downto 0);
		hex7        : out std_logic_vector( 6 downto 0);
		-- adv7123 interface
		vga_r       : out std_logic_vector( 7 downto 0);
		vga_g       : out std_logic_vector( 7 downto 0);
		vga_b       : out std_logic_vector( 7 downto 0);
		vga_clk     : out std_logic;
		vga_blank_n : out std_logic;
		vga_hs      : out std_logic;
		vga_vs      : out std_logic;
		vga_sync_n  : out std_logic
	);
end main;

architecture rtl of main is
	signal reset          : std_logic;
	signal clk            : std_logic;
	signal pclk_r, pclk_x : std_logic;
	signal hcount_s       : std_logic_vector(9 downto 0);
	signal vcount_s       : std_logic_vector(9 downto 0);
	signal hblank_s       : std_logic;
	signal vblank_s       : std_logic;
begin
	-- standard signals
	reset <= not key(0);
	clk   <= clock_50;
	-- constants
	vga_sync_n <= '0'; -- unused
	
	-- sequential logic
	process(clk, reset)
	begin
		if (reset = '1') then
			pclk_r <= '0';
		elsif (clk'event and clk = '1') then
			pclk_r <= pclk_x;
		end if;
	end process;
	
	-- pixel clock
	pclk_x <= not pclk_r;

	-- vga timer unit
	u0: entity work.vga_timer(rtl)
		port map(
			reset    => reset,
			pclk     => pclk_r,
			hcount   => hcount_s,
			vcount   => vcount_s,
			hblank_n => hblank_s,
			vblank_n => vblank_s,
			hsync_n  => vga_hs,
			vsync_n  => vga_vs
		);
	
	-- vga blank
	vga_clk <= pclk_r;
	vga_blank_n <= hblank_s and vblank_s;
	
	-- vga color
	--(hcount_s = "1001111100") and (vcount_s = "0111011101")
	vga_r <= hcount_s(9 downto 2);
	vga_g <= hcount_s(9 downto 2) xor vcount_s(9 downto 2);
	vga_b <= vcount_s(9 downto 2);
	
end rtl;