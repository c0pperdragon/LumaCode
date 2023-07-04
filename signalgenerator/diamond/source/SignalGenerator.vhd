library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;

entity SignalGenerator is	
	port (
	    -- reference oscillator input
		REFCLK          : in std_logic;
		-- dip switches to select output signal
		selector        : in std_logic_vector(3 downto 0);
		-- generated lumacode signals
		INV_CSYNC       : out std_logic;
		INV_LUM0        : out std_logic;
		INV_LUM1        : out std_logic;
		-- debug
		debug : out std_logic
	);	
end entity;
 
architecture immediate of SignalGenerator is

component ClockGenerator
	port (
	    -- reference oscillator input
		REFCLK           : in std_logic;
		-- selected output frequency
		frequency       : in t_Frequency;
		-- generated clock
		CLK             : out std_logic
	);	
end component;

signal FREQUENCY : t_Frequency;
signal CLK : std_logic;

signal w : integer range 0 to 1023;
signal h : integer range 0 to 512;
signal samples : integer range 0 to 7;
signal x1 : integer range 0 to 511;
signal y1 : integer range 0 to 511;
signal pattern : integer range 0 to 3;
signal syncdelay : boolean;

begin
	clkgen : ClockGenerator PORT MAP ( REFCLK => REFCLK, frequency => FREQUENCY, CLK => CLK );

	process (selector)
	begin
		case selector is 
		when "1000" => FREQUENCY<=MHZ_16_363; w<=520; h<=262; samples<=2; x1<=122; y1<=40; pattern<=0; syncdelay<=true; -- C64 NTSC		
		when "0001" => FREQUENCY<=MHZ_21_281; w<=228; h<=312; samples<=6; x1<=46;  y1<=68; pattern<=1; syncdelay<=false; -- Atari 8-bit PAL
		when "1001" => FREQUENCY<=MHZ_21_477; w<=228; h<=262; samples<=6; x1<=46;  y1<=43; pattern<=1; syncdelay<=false; -- Atari 8-bit NTSC
		when "0010" => FREQUENCY<=MHZ_8_867;  w<=284; h<=312; samples<=2; x1<=50;  y1<=50; pattern<=2; syncdelay<=false; -- VIC 20 PAL
		when "1010" => FREQUENCY<=MHZ_8_181;  w<=280; h<=262; samples<=2; x1<=50;  y1<=30; pattern<=2; syncdelay<=false; -- VIC 20 NTSC
		when "0011" => FREQUENCY<=MHZ_14_187; w<=228; h<=312; samples<=4; x1<=50;  y1<=50; pattern<=3; syncdelay<=false; -- Atari 2600 PAL
		when "1011" => FREQUENCY<=MHZ_14_318; w<=228; h<=262; samples<=4; x1<=50;  y1<=30; pattern<=3; syncdelay<=false; -- Atari 2600 NTSC		
		when others => FREQUENCY<=MHZ_15_763; w<=504; h<=312; samples<=2; x1<=122; y1<=66; pattern<=0; syncdelay<=true; -- C64 PAL
		end case;		
		debug <= selector(3) or selector(2) or selector(1) or selector(0);
	end process;
	
	process (CLK)
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 512 := 0;
	variable s:integer range 0 to 5 := 0;	
	variable csync : std_logic;
	variable outbuffer: std_logic_vector(11 downto 0);
	variable tmp_long: integer range 0 to 511;
	variable tmp_short: integer range 0 to 511;
	variable tmp_half: integer range 0 to 511;
	type int_array is array(0 to 15) of integer range 0 to 15;
	constant c64patterns : int_array := (0,15,2,7,3,12,1,11,8,4,13,5,6,14,9,10);
	begin
		if rising_edge(CLK) then
			-- generate sync
			INV_CSYNC <= not csync;
			tmp_long := w/16;
			tmp_short := w/32;
			tmp_half := w/2;
			if (y=0) and (x<tmp_long or (x>=tmp_half and x<tmp_half+tmp_short)) then                   -- normal sync, short sync
				csync := '0';
			elsif (y=1 or y=2) and (x<tmp_short or (x>=tmp_half and x<tmp_half+tmp_short)) then       -- 2x 2 short syncs
				csync := '0';
			elsif (y=3 or y=4) and (x<tmp_half-tmp_short or (x>=tmp_half and x<w-tmp_short)) then     -- 2x 2 vsyncs
				csync := '0';
			elsif (y=5) and (x<tmp_half-tmp_short or (x>=tmp_half and x<tmp_half+tmp_short)) then      -- one vsync, one short sync
				csync := '0';
			elsif (y=6 or y=7) and (x<tmp_short or (x>=tmp_half and x<tmp_half+tmp_short)) then        -- 2x 2 short syncs
				csync := '0';
			elsif (y>=8) and (x<tmp_long) then                                                           -- normal syncs
				csync := '0';
			else
				csync := '1';
			end if;	
			if not syncdelay then INV_CSYNC <= not csync; end if;
			-- sequence out samples
			INV_LUM0 <= not outbuffer(2*(samples-1-s));
			INV_LUM1 <= not outbuffer(2*(samples-1-s)+1);
			-- progress counters
			if s+1 /= samples then
				s := s+1;
			else
				s:=0;
				if x+1 /= w then
					x := x+1;
				else
					x := 0;
					if y+1 /= h then
						y := y+1;
					else
						y := 0;
					end if;
				end if;
			end if; 
			-- create next pixel
			if s=0 then
				outbuffer := "000000000000";
				case pattern is 
				when 0 =>  -- C64
					if x>=x1 and x<x1+320 and y>=y1 and y<y1+200 then 
						if x>=x1+1 and x<x1+319 and y>=y1+1 and y<y1+199 then  -- inner area
							if x>=x1+10 and x<x1+310 and y>=y1+10 and y<y1+190 then -- colored box
								outbuffer := std_logic_vector(to_unsigned(c64patterns(((x+y)/16) mod 16),12));
							end if;
						else
							outbuffer := "000000001111";   -- bounding rectangle
						end if;
					end if;
				when 1 =>  -- Atari 8-bit 
					if x>=x1 and x<x1+160 and (y=y1 or y=y1+191) then 
						outbuffer := "000011111111"; -- top and bottom edge
					elsif x=x1 and y>=y1 and y<y1+192  then
						outbuffer := "000011110000"; -- left edge
					elsif x=x1+159 and y>=y1 and y<y1+192  then
						outbuffer := "000000001111"; -- right edge
					elsif x>=x1+5 and x<x1+155 and y>=y1+10 and y<y1+182 then -- colored box
						outbuffer(11 downto 8) := std_logic_vector(to_unsigned(((y)/8+5) mod 16,4));
						outbuffer(7 downto 4) := std_logic_vector(to_unsigned(((2*x+y)/16) mod 16,4));
						outbuffer(3 downto 0) := std_logic_vector(to_unsigned(((2*x+1+y)/16) mod 16,4));
					end if;
				when 2 =>  -- VIC 20
				when 3 =>  -- Atari 2600
				when others =>
				end case;
			end if;
		end if;
	end process;

end immediate;
