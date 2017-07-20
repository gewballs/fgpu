library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VGA 640 x 480 timer signal generator
entity vga_timer is
	port(
		reset    : in  std_logic;
		pclk     : in  std_logic; -- pixel clock, 25 MHz
		hcount   : out std_logic_vector(9 downto 0); -- 800 pixels
		vcount   : out std_logic_vector(9 downto 0); -- 525 lines
		hblank_n : out std_logic;
		vblank_n : out std_logic;
		hsync_n  : out std_logic;
		vsync_n  : out std_logic
	);
end vga_timer;

architecture rtl of vga_timer is
	-- counters
	signal hcount_r, hcount_x : unsigned(9 downto 0);
	signal vcount_r, vcount_x : unsigned(9 downto 0);
	-- counter up signals
	signal hup_s : std_logic;
	signal vup_s : std_logic;
begin
	-- sequential logic
	process(pclk, reset)
	begin
		if (reset = '1') then
			hcount_r <= (others => '0');
			vcount_r <= (others => '0');
		elsif (pclk'event and pclk = '1') then
			hcount_r <= hcount_x;
			vcount_r <= vcount_x;
		end if;
	end process;
		
	-- counter up signals
	hup_s <= '1' when (hcount_r = 799) else '0';
	vup_s <= '1' when (vcount_r = 524) else '0';
	
	-- counters next value logic
	hcount_x <=
		(others => '0') when (hup_s = '1') else
		hcount_r + 1;
	vcount_x <=
		vcount_r when (hup_s = '0') else
		(others => '0') when (vup_s = '1') else
		vcount_r + 1;
  
	-- timer signal output
	hcount   <= std_logic_vector(hcount_r);
	vcount   <= std_logic_vector(vcount_r);
	hblank_n <= '0' when (hcount_r >= 640) else '1';
	vblank_n <= '0' when (vcount_r >= 480) else '1';
	hsync_n  <= '0' when ((655 <= hcount_r) and (hcount_r <= 751)) else '1';
	vsync_n  <= '0' when ((490 <= vcount_r) and (vcount_r <= 491)) else '1';

end rtl;