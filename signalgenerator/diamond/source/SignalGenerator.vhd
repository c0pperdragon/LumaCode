library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;

entity SignalGenerator is	
	port (
	    -- reference oscillator input
		REFCLK          : in std_logic;
		-- dip switches to select output signal
		SELECTION       : in std_logic_vector(3 downto 0);
		-- generated lumacode signals
		INV_CSYNC       : out std_logic;
		INV_LUM0        : out std_logic;
		INV_LUM1        : out std_logic
	);	
end entity;

 
architecture immediate of SignalGenerator is
component ClockGenerator     
	port (
	    -- reference oscillator input
		REFCLK          : in std_logic;
		-- selected output frequency
		FREQUENCY       : in t_Frequency;
		-- generated clock
		CLK             : out std_logic
	);
end component;

signal FREQUENCY: t_Frequency;
signal CLK:std_logic;

signal w : integer range 0 to 1023;
signal h : integer range 0 to 512;
signal samples : integer range 0 to 7;
signal sw : integer range 0 to 63;
signal x1 : integer range 0 to 511;
signal y1 : integer range 0 to 511;
signal syncdelay : integer range 0 to 1;
signal syncsimple: boolean;
type t_pattern is
      (C64, VIC20, Atari8, Atari2600, TMS, NES, Speccy);
signal pattern : t_pattern;


function logoC64(x,y : integer) return std_logic is
type logo_t is array(0 to 6) of std_logic_vector(54 downto 1);
constant logo:logo_t := (
	"011110000111100000001100000000000011000001111000011110",
	"110011001100110000011100000001100011000011001100110011",
	"110000001100000000111100000011000111000000001100110011",
	"110000001111100011001100000110000011000000011000011110",
	"110000001100110011111110001100000011000001100000110011",
	"110011001100110000001100011000000011000011000000110011",
	"011110000111100000001100110000001111110011111100011110"
);
begin
	if x>=0 and x<320 and y>=0 and y<200 then
		if x>=1 and x<319 and y>=1 and y<199 then 
			if x>=8+1 and x<=8+54 and y>=8 and y<8+7 then
				return logo(y-8)(8+1+54-x);
			end if;
		else
			return '1';
		end if;
	end if;
	return '0';
end logoC64;

function logoVIC20(x,y : integer) return std_logic is
type logo_t is array(0 to 6) of std_logic_vector(46 downto 1);
constant logo:logo_t := (
	"1000010000111000001110000000000001111000011110",
	"1000010000010000010001000000000010000100100001",
	"1000010000010000100000000000000000000100100011",
	"0100100000010000100000001111110000011000101101",
	"0100100000010000100000000000000001100000110001",
	"0011000000010000010001000000000010000000100001",
	"0011000000111000001110000000000011111100011110"
);
begin
	if x>=0 and x<176 and y>=0 and y<184 then
		if x>=1 and x<176-1 and y>=1 and y<184-1 then 
			if x>=4+1 and x<=4+46 and y>=8 and y<8+7 then
				return logo(y-8)(4+1+46-x);
			end if;
		else
			return '1';
		end if;
	end if;
	return '0';
end logoVIC20;

function logoSpeccy(x,y : integer) return std_logic is
type logo_t is array(1 to 7) of std_logic_vector(85 downto 1);
constant logo:logo_t := (
	"1111110010000100000000000111100000000000000000000000000000100000000000000000000000000",
	"0000100001001000000000001000000011110000011100000111000001110000001110001000100011010",
	"0001000000110000000000000111100010001000100010001000000000100000010000001000100010101",
	"0010000000110000000000000000010010001000111100001000000000100000010000001000100010101",
	"0100000001001000000000001000010011110000100000001000000000100000010000001000100010101",
	"1111110010000100000000000111100010000000011110000111000000011000010000000111000010101",
	"0000000000000000000000000000000010000000000000000000000000000000000000000000000000000"
);
begin
	if x>=0 and x<256 and y>=0 and y<192 then
		if x>=1 and x<256-1 and y>=1 and y<192-1 then 
			if x>=8+1 and x<=8+85 and y>=8+1 and y<8+8 then
				return logo(y-8)(8+1+85-x);
			end if;
		else
			return '1';
		end if;
	end if;
	return '0';
end logoSpeccy;

subtype logvec2 is std_logic_vector(1 downto 0);
function logoAtari8bit(x,y : integer) return logvec2 is
type logo_t is array(1 to 6) of std_logic_vector(87 downto 0);
constant logo:logo_t := (
	"0001100000011000000000000000000000011000000000000011110000000000011000000001100000011000",
	"0011110001111110001111000111110000000000000000000110011000000000011000000000000001111110",
	"0110011000011000000001100110011000111000000000000011110001111110011111000011100000011000",
	"0110011000011000001111100110000000011000000000000110011000000000011001100001100000011000",
	"0111111000011000011001100110000000011000000000000110011000000000011001100001100000011000",
	"0110011000001100001111100110000000111100000000000011100000000000011111000011110000001100"
);
begin
	if x>=4 and x<=4+44 and y>=8+1 and y<8+7 then   -- logo itself
		return logo(y-8)((4+44-x)*2+1 downto (4+44-x)*2 );
	elsif (y=0 or y=191) and x>=0 and x<160 then -- top or bottom border
		return "11";
	elsif x=0 and (y>=0 and y<192) then -- left border
		return "10";
	elsif x=159 and (y>=0 and y<192) then -- right border
		return "01";
	else
		return "00";
	end if;
end logoAtari8bit;

function logoAtari2600(x,y : integer) return std_logic is
type logo_t is array(1 to 6) of std_logic_vector(68 downto 1);
constant logo:logo_t := (
	"00110000011000000000000000000110000000000011110001111000111100011110",
	"01111001111110011110011111000000000000000110011011000001100110110011",
	"11001100011000000011011001101110000000000000110011111001101110110111",
	"11001100011000011111011000000110000000000001100011001101110110111011",
	"11111100011000110011011000000110000000000011000011001101100110110011",
	"11001100001100011111011000001111000000000111111001111000111100011110"
);
begin
	if x>=4+1 and x<=4+68 and y>=8+1 and y<8+7 then   -- logo itself
		return logo(y-8)(4+68+1-x);
	elsif (x>=0 and x<160 and y>=0 and y<200) and 
      not (x>=1 and x<159 and y>=1 and y<199) then
		return '1';
	else
		return '0';
	end if;
end logoAtari2600;

function logoTMS(x,y : integer) return std_logic is
type logo_t is array(0 to 6) of std_logic_vector(52 downto 0);
constant logo:logo_t := (
	"11111000100010000111000001110000011100000010000001110",
	"00100000110110001000100010001000100010000110000010001",
	"00100000101010001000000010001000100010000010000010001",	
	"00100000101010000111000001111000011110000010000001110",
	"00100000100010000000100000001000000010000010000010001",
	"00100000100010001000100000010000000100000010000010001",
	"00100000100010000111000011100000111000000111000001110"
);
begin
	if x>=8 and x<=8+52 and y>=8 and y<8+7 then   -- logo itself
		return logo(y-8)(8+52-x);
	elsif (x>=0 and x<256 and y>=0 and y<192) and 
      not (x>=1 and x<255 and y>=1 and y<191) then
		return '1';
	else
		return '0';
	end if;
end logoTMS;

function logoNES(x,y : integer) return std_logic is
type logo_t is array(0 to 6) of std_logic_vector(22 downto 0);
constant logo:logo_t := (
	"11000110111111100111100",
	"11100110110000001100110",
	"11110110110000001100000",	
	"11111110111111000111110",
	"11011110110000000000011",
	"11001110110000001100011",
	"11000110111111100111110"
);
begin
	if x>=8 and x<=8+22 and y>=8 and y<8+7 then   -- logo itself
		return logo(y-8)(8+22-x);
	elsif (x>=0 and x<256 and y>=0 and y<240) and 
      not (x>=1 and x<255 and y>=1 and y<239) then
		return '1';
	else
		return '0';
	end if;
end logoNES;


begin
	clkgen: ClockGenerator PORT MAP ( REFCLK, FREQUENCY, CLK );

	process (SELECTION)
	begin
		syncdelay <= 0;
		syncsimple <= false;		
		case SELECTION is 
		when "0000" => FREQUENCY<=MHZ_15_763; w<=504; h<=312; samples<=2; x1<=128; y1<=65; sw<=37; pattern<=C64; syncdelay<=1;          -- 50Hz C64/C128
		when "0001" => FREQUENCY<=MHZ_14_000; w<=448; h<=312; samples<=2; x1<=120; y1<=66; sw<=33; pattern<=Speccy;                      -- 50Hz ZX Spectrum
		when "0010" => FREQUENCY<=MHZ_8_867;  w<=284; h<=312; samples<=2; x1<=73;  y1<=75; sw<=16; pattern<=VIC20; syncdelay<=1;         -- 50Hz VIC 20		
		when "0011" => FREQUENCY<=MHZ_21_281; w<=228; h<=312; samples<=6; x1<=49;  y1<=69; sw<=16; pattern<=Atari8;                      -- 50Hz Atari 8-bit
		when "0100" => FREQUENCY<=MHZ_14_187; w<=228; h<=312; samples<=4; x1<=48;  y1<=65; sw<=14; pattern<=Atari2600; syncsimple<=true; -- 50Hz Atari 2600 PAL
		when "0101" => FREQUENCY<=MHZ_14_318; w<=228; h<=312; samples<=4; x1<=48;  y1<=65; sw<=14; pattern<=Atari2600; syncsimple<=true; -- 50Hz Atari 2600 NTSC
		when "0110" => FREQUENCY<=MHZ_10_738; w<=342; h<=313; samples<=2; x1<=60;  y1<=68; sw<=26; pattern<=TMS; syncsimple<=true;       -- 50Hz TMS99xxA
		when "0111" => FREQUENCY<=MHZ_31_922; w<=341; h<=312; samples<=6; x1<=66;  y1<=42; sw<=25; pattern<=NES; syncsimple<=true;       -- 50Hz NES
		when "1000" => FREQUENCY<=MHZ_16_363; w<=520; h<=263; samples<=2; x1<=129; y1<=41; sw<=37; pattern<=C64; syncdelay<=1;           -- 60Hz C64/C128
		when "1001" => FREQUENCY<=MHZ_16_363; w<=512; h<=262; samples<=2; x1<=129; y1<=41; sw<=37; pattern<=C64; syncdelay<=1;           -- 60Hz C64 6567R56A
		when "1010" => FREQUENCY<=MHZ_8_181;  w<=260; h<=261; samples<=2; x1<=71-28; y1<=75-26; sw<=16; pattern<=VIC20;                  --60Hz VIC 20
		when "1011" => FREQUENCY<=MHZ_21_477; w<=228; h<=262; samples<=6; x1<=49;  y1<=41; sw<=16; pattern<=Atari8;                      -- 60Hz Atari 8-bit		
		when "1100" => FREQUENCY<=MHZ_14_187; w<=228; h<=262; samples<=4; x1<=48;  y1<=42; sw<=14; pattern<=Atari2600; syncsimple<=true; -- 60Hz Atari 2600 PAL
		when "1101" => FREQUENCY<=MHZ_14_318; w<=228; h<=262; samples<=4; x1<=48;  y1<=42; sw<=14; pattern<=Atari2600; syncsimple<=true; -- 60Hz Atari 2600 NTSC
		when "1110" => FREQUENCY<=MHZ_10_738; w<=342; h<=262; samples<=2; x1<=60;  y1<=43; sw<=26; pattern<=TMS; syncsimple<=true;       -- 60Hz TMS99xxA
		when others => FREQUENCY<=MHZ_32_216; w<=341; h<=262; samples<=6; x1<=66;  y1<=20; sw<=25; pattern<=NES; syncsimple<=true;       -- 60Hz NES
		end case;
	end process;


	process (CLK)
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 512 := 0;
	variable s:integer range 0 to 5 := 0;	
	
	variable csync : std_logic;
	variable prev_csync: std_logic;
	variable outbuffer: std_logic_vector(11 downto 0);
	variable tmp_long: integer range 0 to 511;
	variable tmp_short: integer range 0 to 511;
	variable tmp_half: integer range 0 to 511;
	type lum_array is array(0 to 15) of std_logic_vector(3 downto 0);
	constant c64colors : lum_array := (
		"0000","1111","0010","0111","0011","1100","0001","1011",
	    "1000","0100","1101","0101","0110","1110","1001","1010");
	constant zxcolors  : lum_array := (
		"0000","0100","0101","0011","1001","0111","1101","1110",
	    "0001","0010","1000","0110","1100","1010","1011","1111");
	constant tmscolors  : lum_array := (
		"0000","0100","1001","1010","0001","0110","0101","0111",
	    "0010","0011","1101","1110","1000","1100","1011","1111");		
	variable tmp_2bit : std_logic_vector(1 downto 0);
	variable tmp_col:integer range 0 to 63;
	begin
		if rising_edge(CLK) then
			-- create pixel
			outbuffer := "000000000000";
			case pattern is
			when C64 =>
				if logoC64(x-x1,y-y1)='1' then
					outbuffer(3 downto 0) := "1111"; 
				elsif x>=x1+16 and x<x1+320-16 and y>=y1+56 and y<y1+56+128 then
					outbuffer(3 downto 0) := c64colors((y-y1-56)/8);	
				elsif x>=x1 and x<x1+320 and y>=y1 and y<y1+200 then
					outbuffer(3 downto 0) := "0001";
				end if;
			when VIC20 => 
				if logoVIC20(x-x1,y-y1)='1' then
					outbuffer(3 downto 0) := "1111"; 
				elsif x>=x1+16 and x<x1+176-16 and y>=y1+40 and y<y1+40+128 then
					outbuffer(3 downto 0) := c64colors((y-y1-40)/8);					
				elsif x>=x1 and x<x1+176 and y>=y1 and y<y1+184 then
					outbuffer(3 downto 0) := "0001";
				end if;
			when Speccy =>
				if logoSpeccy(x-x1,y-y1)='1' then
					outbuffer(3 downto 0) := "1111"; 
				elsif x>=x1+16 and x<x1+256-16 and y>=y1+48 and y<y1+48+128 then
					outbuffer(3 downto 0) := zxcolors((y-y1-48)/8);					
				elsif x>=x1 and x<x1+256 and y>=y1 and y<y1+192 then
					outbuffer(3 downto 0) := "0100";
				end if;				
			when Atari8 => 
				tmp_2bit := logoAtari8bit(x-x1,y-y1);
				if tmp_2bit/="00" then
					outbuffer(7 downto 4) := tmp_2bit(1) & tmp_2bit(1) & tmp_2bit(1) & tmp_2bit(1); 
					outbuffer(3 downto 0) := tmp_2bit(0) & tmp_2bit(0) & tmp_2bit(0) & tmp_2bit(0); 
				elsif x>=x1+16 and x<x1+16+128 and y>=y1+48 and y<y1+48+128 then
					outbuffer(11 downto 8) := std_logic_vector(to_unsigned((y-y1-48)/8,4));					
					outbuffer(7 downto 4) := std_logic_vector(to_unsigned((x-x1-16)/8,4));
					outbuffer(3 downto 0) := std_logic_vector(to_unsigned((x-x1-16)/8,4));
				elsif x>=x1 and x<x1+160 and y>=y1 and y<y1+192 then
					outbuffer := "011100000000";
				end if;				
			when Atari2600 =>
				if logoAtari2600(x-x1,y-y1)='1' then
					outbuffer(7 downto 0) := "00001110"; 
				elsif x>=x1+16 and x<x1+16+128 and y>=y1+56 and y<y1+56+128 then
					outbuffer(7 downto 4) := std_logic_vector(to_unsigned((y-y1-56)/8,4));					
					outbuffer(3 downto 1) := std_logic_vector(to_unsigned((x-x1-16)/16,3));
				elsif x>=x1 and x<x1+160 and y>=y1 and y<y1+200 then
					outbuffer(7 downto 0) := "10010000";
				end if;
			when TMS =>
				if logoTMS(x-x1,y-y1)='1' then
					outbuffer(3 downto 0) := "1111";
				elsif x>=x1+16 and x<x1+256-16 and y>=y1+48 and y<y1+48+128 then
					outbuffer(3 downto 0) := tmscolors((y-y1-48)/8);	
				elsif x>=x1 and x<x1+256 and y>=y1 and y<y1+192 then
					outbuffer(3 downto 0) := "0001";
				end if;
			when NES =>
				if logoNES(x-x1,y-y1)='1' then
					outbuffer(5 downto 0) := "110010";
				elsif y>=y1+96 and y<y1+96+128 then
					if x>=x1+12 and x<x1+12+112 then
						tmp_col := (x-x1-12)/8 + ((y-y1-96)/8) * 16;
						if (tmp_col mod 16) >= 14 then
							tmp_col := 13;
						end if;
						outbuffer(5 downto 0) := std_logic_vector(to_unsigned(8 - (tmp_col/16)*2 + tmp_col, 6));
					elsif x>=x1+132 and x<x1+132+112 then
						tmp_col := (x-x1-132)/8 + ((y-y1-96)/8) * 16;
						if (tmp_col mod 16) >= 14 then
							tmp_col := 13;
						end if;
						outbuffer(5 downto 0) := std_logic_vector(to_unsigned(8 - (tmp_col/16)*2 + tmp_col, 6));					
					elsif x=x1+11 then
						outbuffer(5 downto 0) := std_logic_vector(to_unsigned((y-y1-96)/32, 6));
					elsif x=x1+131 then
						outbuffer(5 downto 0) := std_logic_vector(to_unsigned(4+(y-y1-96)/32, 6));					
					end if;
				end if;
				outbuffer := outbuffer(5 downto 4) & outbuffer(5 downto 4) 
				           & outbuffer(3 downto 2) & outbuffer(3 downto 2)
						   & outbuffer(1 downto 0) & outbuffer(1 downto 0);
			when others =>
			end case;
			
			-- generate sync
			prev_csync := csync;
			tmp_long := sw;
			tmp_short := sw/2;
			tmp_half := w/2;
			csync := '1';
			if syncsimple then
				if y<3 then
					if x<w-tmp_long then
						csync:='0';
					end if;
				else
					if x<tmp_long then
						csync:='0';
					end if;
				end if;
			else
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
				end if;	
			end if;
			
			-- sequence out samples and sync
			INV_LUM0 <= not outbuffer(2*(samples-1-s));
			INV_LUM1 <= not outbuffer(2*(samples-1-s)+1);
			if syncdelay=0 then
				INV_CSYNC <= not csync; 
			else
				INV_CSYNC <= not prev_csync;
			end if;
			
			-- progress counters
			if SELECTION="1111" and s=0 and x=200 and y=260 then -- skip half pixel for NES 60 Hz
				s:=4;
			elsif s+1 /= samples then
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
		end if;
	end process;

end immediate;
