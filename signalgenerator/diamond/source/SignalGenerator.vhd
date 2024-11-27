library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;
 
entity SignalGenerator is	
	port (
	    -- reference oscillator input
		REFCLK          : in std_logic;
		-- dip switches to select output signal
		SEL50HZ         : in std_logic;
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

COMPONENT OSCH
	GENERIC (NOM_FREQ: string);
	PORT (
		STDBY:IN std_logic;
		OSC:OUT std_logic;
		SEDSTDBY:OUT std_logic
	);
END COMPONENT;

COMPONENT TITLES
    port (
        Address: in  std_logic_vector(7 downto 0); 
        OutClock: in  std_logic; 
        OutClockEn: in  std_logic; 
        Reset: in  std_logic; 
        Q: out  std_logic_vector(95 downto 0));
END COMPONENT;


constant C64:integer:=0;
constant VIC20:integer:=1;
constant C16:integer:=2;
constant Atari8:integer:=3;
constant Atari2600:integer:=4;
constant ATARIST:integer:=5;
constant TMS:integer:=6;
constant Speccy:integer:=7;
constant NES:integer:=8;
constant SMS:integer:=9;
constant Intelli:integer:=10;
constant LC270:integer:=11;

constant SERRATED:integer:=0;
constant SIMPLE:integer:=1;
constant ANYSYNC:integer:=3;

signal FREQUENCY: t_Frequency;
signal CLK:std_logic;

signal titles_address:std_logic_vector(7 downto 0);
signal titles_data:std_logic_vector(95 downto 0);

signal w : integer range 0 to 2047;
signal h : integer range 0 to 512;
signal samples : integer range 0 to 7;
signal sw : integer range 0 to 127;
signal x1 : integer range 0 to 1023;
signal y1 : integer range 0 to 511;
signal x2 : integer range 0 to 1023;
signal y2 : integer range 0 to 511;
signal syncdelay : integer range 0 to 1;
signal synctype:integer range 0 to 3;
signal pattern : integer range 0 to 15;


begin
	clkgen: ClockGenerator PORT MAP ( REFCLK, FREQUENCY, CLK );
	alltitles: TITLES PORT MAP ( titles_address, CLK, '1', '0', titles_data);
		
	process (SELECTION, SEL50HZ)
	begin
		syncdelay <= 0;
		if SEL50HZ='0' then
			case SELECTION is 
			when "0000" => FREQUENCY<=MHZ_16_363; w<=520; h<=263; samples<=2; x1<=129; y1<=41; x2<=129+320; y2<=41+200; sw<=37; pattern<=C64;       synctype<=SERRATED; syncdelay<=1; -- 60Hz C64/C128
			when "0001" => FREQUENCY<=MHZ_16_363; w<=512; h<=262; samples<=2; x1<=129; y1<=41; x2<=129+320; y2<=41+200; sw<=37; pattern<=C64;       synctype<=SERRATED; syncdelay<=1; -- 60Hz C64 6567R56A
			when "0010" => FREQUENCY<=MHZ_8_181;  w<=260; h<=261; samples<=2; x1<=43;  y1<=49; x2<=43+176;  y2<=49+183; sw<=16; pattern<=VIC20;     synctype<=SERRATED; --60Hz VIC 20
			when "0011" => FREQUENCY<=MHZ_21_477; w<=456; h<=262; samples<=3; x1<=43;  y1<=49; x2<=43+160;  y2<=49+200; sw<=34; pattern<=C16;       synctype<=SERRATED; --60Hz C16
			when "0100" => FREQUENCY<=MHZ_21_477; w<=228; h<=262; samples<=6; x1<=49;  y1<=41; x2<=49+160;  y2<=41+192; sw<=16; pattern<=Atari8;    synctype<=SERRATED; -- 60Hz Atari 8-bit		
			when "0101" => FREQUENCY<=MHZ_14_187; w<=228; h<=262; samples<=4; x1<=48;  y1<=42; x2<=48+160;  y2<=42+200; sw<=14; pattern<=Atari2600; synctype<=SIMPLE;  -- 60Hz Atari 2600 PAL
			when "0110" => FREQUENCY<=MHZ_14_318; w<=228; h<=262; samples<=4; x1<=48;  y1<=42; x2<=48+160;  y2<=42+200; sw<=14; pattern<=Atari2600; synctype<=SIMPLE;  -- 60Hz Atari 2600 NTSC
			when "0111" => FREQUENCY<=MHZ_32_000; w<=896; h<=501; samples<=1; x1<=190; y1<=80; x2<=190+640; y2<=80+400; sw<=67; pattern<=ATARIST;   synctype<=ANYSYNC; -- 72Hz ATARI ST
			when "1000" => FREQUENCY<=MHZ_10_738; w<=342; h<=262; samples<=2; x1<=60;  y1<=43; x2<=60+256;  y2<=43+192; sw<=26; pattern<=TMS;       synctype<=SIMPLE;  -- 60Hz TMS99xxA			
			when "1001" => FREQUENCY<=MHZ_14_110; w<=448; h<=264; samples<=2; x1<=120; y1<=66; x2<=120+256; y2<=66+192; sw<=33; pattern<=Speccy;    synctype<=SERRATED;-- 60Hz ZX Spectrum
			when "1010" => FREQUENCY<=MHZ_32_216; w<=341; h<=262; samples<=6; x1<=66;  y1<=20; x2<=66+256;  y2<=20+240; sw<=25; pattern<=NES;       synctype<=SIMPLE;  -- 60Hz NES
			when "1011" => FREQUENCY<=MHZ_16_108; w<=342; h<=262; samples<=3; x1<=60;  y1<=43; x2<=60+256;  y2<=43+192; sw<=26; pattern<=SMS;       synctype<=SIMPLE;  --  Master System 60Hz
			when "1100" => FREQUENCY<=MHZ_7_159;  w<=228; h<=262; samples<=2; x1<=48;  y1<=42; x2<=48+160;  y2<=43+192; sw<=14; pattern<=Intelli;   synctype<=SIMPLE;  --  Intellivision 60Hz
			when others => FREQUENCY<=MHZ_24_000; w<=490; h<=273; samples<=3; x1<=10;  y1<=2;  x2<=10+480;  y2<=2+270;  sw<=4;  pattern<=LC270;     synctype<=SIMPLE;  --  Lumacode270p 60Hz
			end case;
		else
			case SELECTION is 
			when "0000" => FREQUENCY<=MHZ_15_763; w<=504; h<=312; samples<=2; x1<=128; y1<=65; x2<=128+320; y2<=65+200; sw<=37; pattern<=C64;      synctype<=SERRATED; syncdelay<=1; -- 50Hz C64/C128
			when "0001" => FREQUENCY<=MHZ_15_763; w<=504; h<=312; samples<=2; x1<=128; y1<=65; x2<=128+320; y2<=65+200; sw<=37; pattern<=C64;      synctype<=SERRATED; syncdelay<=1; -- 50Hz C64/C128
			when "0010" => FREQUENCY<=MHZ_8_867;  w<=284; h<=312; samples<=2; x1<=73;  y1<=75; x2<=73+176; y2<=75+183; sw<=16; pattern<=VIC20;     synctype<=SERRATED; syncdelay<=1; -- 50Hz VIC 20
			when "0011" => FREQUENCY<=MHZ_21_281; w<=456; h<=312; samples<=3; x1<=43;  y1<=49; x2<=43+160; y2<=49+200; sw<=34; pattern<=C16;       synctype<=SERRATED; --50Hz C16
			when "0100" => FREQUENCY<=MHZ_21_281; w<=228; h<=312; samples<=6; x1<=49;  y1<=69; x2<=49+160; y2<=69+192; sw<=16; pattern<=Atari8;    synctype<=SERRATED; -- 50Hz Atari 8-bit
			when "0101" => FREQUENCY<=MHZ_14_187; w<=228; h<=312; samples<=4; x1<=48;  y1<=65; x2<=48+160; y2<=65+200; sw<=14; pattern<=Atari2600; synctype<=SIMPLE;  -- 50Hz Atari 2600 PAL
			when "0110" => FREQUENCY<=MHZ_14_318; w<=228; h<=312; samples<=4; x1<=48;  y1<=65; x2<=48+160; y2<=65+200; sw<=14; pattern<=Atari2600; synctype<=SIMPLE;  -- 50Hz Atari 2600 NTSC
			when "0111" => FREQUENCY<=MHZ_32_000; w<=896; h<=501; samples<=1; x1<=190; y1<=80; x2<=190+640; y2<=80+400;sw<=67; pattern<=ATARIST;   synctype<=ANYSYNC; -- 72Hz ATARI ST
			when "1000" => FREQUENCY<=MHZ_10_738; w<=342; h<=313; samples<=2; x1<=60;  y1<=68; x2<=60+256; y2<=68+192; sw<=26; pattern<=TMS;       synctype<=SIMPLE;  -- 50Hz TMS99xxA
			when "1001" => FREQUENCY<=MHZ_14_000; w<=448; h<=312; samples<=2; x1<=120; y1<=66; x2<=120+256; y2<=66+192;sw<=33; pattern<=Speccy;    synctype<=SERRATED;-- 50Hz ZX Spectrum
			when "1010" => FREQUENCY<=MHZ_31_922; w<=341; h<=312; samples<=6; x1<=66;  y1<=42; x2<=66+256; y2<=42+240; sw<=25; pattern<=NES;       synctype<=SIMPLE;  -- 50Hz NES
			when "1011" => FREQUENCY<=MHZ_15_961; w<=342; h<=312; samples<=3; x1<=60;  y1<=43; x2<=60+256; y2<=43+224; sw<=26; pattern<=SMS;       synctype<=SIMPLE;  --  Master System 50Hz
			when "1100" => FREQUENCY<=MHZ_8_000;  w<=256; h<=312; samples<=2; x1<=60;  y1<=43; x2<=60+160; y2<=43+192; sw<=17; pattern<=Intelli;  synctype<=SIMPLE;  --  Intellivision 50Hz
			when others => FREQUENCY<=MHZ_24_000; w<=500; h<=320; samples<=3; x1<=16;  y1<=43; x2<=16+480; y2<=43+270; sw<=8;  pattern<=LC270;     synctype<=SIMPLE;  -- Lumacode270p 50Hz 
			end case;
		end if;
	end process;


	process (CLK)
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 512 := 0;
	variable s:integer range 0 to 7 := 0;	
	
	variable csync : std_logic;
	variable prev_csync: std_logic;
	variable outbuffer: std_logic_vector(11 downto 0);
	variable cx:integer range 0 to 1023;
	variable cy:integer range 0 to 511;
	variable tmp_long: integer range 0 to 511;
	variable tmp_short: integer range 0 to 511;
	variable tmp_half: integer range 0 to 1023;
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
			-- create background black and border frame
			outbuffer := "000000000000";
			-- only consider inside
			if x>=x1 and x<x2 and y>=y1 and y<y2 then			
				cx := x-x1;
				cy := y-y1;
				-- border
				if cx=0 or cy=0 or cx=x2-x1-1 or cy=y2-y1-1 then
					outbuffer := "111111111111";
				-- title 
				elsif cx>=8 and cx<8+96 and cy>=8 and cy<8+8 and titles_data(96+8-1-cx)='1' then
					outbuffer := "111111111111";
				-- specific color pattern
				else
					case pattern is
					when C64 =>
						if cx>=16 and cx<320-16 and cy>=56 and cy<56+128 then
							outbuffer(3 downto 0) := c64colors((cy-56)/8);	
						end if;
					when VIC20 => 
						if cx>=16 and cx<176-16 and cy>=40 and cy<40+128 then
							outbuffer(3 downto 0) := c64colors((cy-40)/8);					
						end if;
					when Speccy =>
						if cx>=16 and cx<256-16 and cy>=48 and cy<48+128 then
							outbuffer(3 downto 0) := zxcolors((cy-48)/8);					
						end if;				
					when Atari8 => 
						if cx>=16 and cx<16+128 and cy>=48 and cy<48+128 then
							outbuffer(11 downto 8) := std_logic_vector(to_unsigned((cy-48)/8,4));					
							outbuffer(7 downto 4) := std_logic_vector(to_unsigned((cx-16)/8,4));
							outbuffer(3 downto 0) := std_logic_vector(to_unsigned((cx-16)/8,4));
						end if;				
					when Atari2600 =>
						if cx>=16 and cx<16+128 and cy>=56 and cy<56+128 then
							outbuffer(7 downto 4) := std_logic_vector(to_unsigned((cy-56)/8,4));					
							outbuffer(3 downto 1) := std_logic_vector(to_unsigned((cx-16)/16,3));
						end if;
					when ATARIST =>
						if cx>=32 and cx<640-32 and cy>=48 and cy<400-8 then
							if (cx+cy) mod 16 < 8 then
								outbuffer(1 downto 0) := "00";	
							elsif (cx+cy) mod 16 < 10 then
								outbuffer(1 downto 0) := "11";	
							end if;
						end if;
					when TMS =>
						if cx>=16 and cx<256-16 and cy>=48 and cy<48+128 then
							outbuffer(3 downto 0) := tmscolors((cy-48)/8);	
						end if;
					when NES =>
						if cy>=96 and cy<96+128 then
							if cx>=12 and cx<12+112 then
								tmp_col := (cx-12)/8 + ((cy-96)/8) * 16;
								if (tmp_col mod 16) >= 14 then
									tmp_col := 13;
								end if;
								outbuffer(5 downto 0) := std_logic_vector(to_unsigned(8 - (tmp_col/16)*2 + tmp_col, 6));
							elsif cx>=132 and cx<132+112 then
								tmp_col := (cx-132)/8 + ((cy-96)/8) * 16;
								if (tmp_col mod 16) >= 14 then
									tmp_col := 13;
								end if;
								outbuffer(5 downto 0) := std_logic_vector(to_unsigned(8 - (tmp_col/16)*2 + tmp_col, 6));					
							elsif cx=11 then
								outbuffer(5 downto 0) := std_logic_vector(to_unsigned((cy-96)/32, 6));
							elsif cx=131 then
								outbuffer(5 downto 0) := std_logic_vector(to_unsigned(4+(cy-96)/32, 6));					
							end if;
						end if;
						outbuffer := outbuffer(5 downto 4) & outbuffer(5 downto 4) 
								   & outbuffer(3 downto 2) & outbuffer(3 downto 2)
								   & outbuffer(1 downto 0) & outbuffer(1 downto 0);
					when SMS =>
						if cx>=16 and cx<16+128 and cy>=56 and cy<56+128 then
							outbuffer(5 downto 4) := std_logic_vector(to_unsigned( ((cx-16)/16) mod 4, 2));
							outbuffer(3 downto 2) := std_logic_vector(to_unsigned( (cx-16)/64 + 2*((cy-56)/64), 2));
							outbuffer(1 downto 0) := std_logic_vector(to_unsigned( ((cy-56)/16) mod 4, 2));
						end if;
					when Intelli =>
						if cx>=16 and cx<160-16 and cy>=56 and cy<56+128 then
							outbuffer(3 downto 0) := std_logic_vector(to_unsigned( ((cy-56)/8), 4));	
						end if;
					when LC270 =>
						if cx>=7 and cx<7+256 and cy>=7 and cy<7+256 then
							outbuffer(5 downto 4) := std_logic_vector(to_unsigned( ((cx-7)/32) mod 4, 2));
							outbuffer(3 downto 2) := std_logic_vector(to_unsigned( (cx-7)/128 + 2*((cy-7)/128), 2));
							outbuffer(1 downto 0) := std_logic_vector(to_unsigned( ((cy-7)/32) mod 4, 2));
						elsif cx>=300 and cx<350 and cy>=7 and cy<7+256 then
							outbuffer(5 downto 4) := std_logic_vector(to_unsigned( (cy-7)/64, 2));
						elsif cx>=360 and cx<410 and cy>=7 and cy<7+256 then
							outbuffer(3 downto 2) := std_logic_vector(to_unsigned( (cy-7)/64, 2));
						elsif cx>=420 and cx<470 and cy>=7 and cy<7+256 then
							outbuffer(1 downto 0) := std_logic_vector(to_unsigned( (cy-7)/64, 2));
						end if;			
					when others =>
					end case;
				end if;
			end if;
						
			-- generate csync
			prev_csync := csync;
			tmp_long := sw;
			tmp_short := sw/2;
			tmp_half := w/2;
			csync := '1';
			if synctype=ANYSYNC then 
				if x<tmp_long or y<3 then
					csync := '0';
				end if;
			elsif synctype=SERRATED then
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
			else
				if y<1 or (y1>3 and y<3) then
					if x<w-tmp_long then
						csync:='0';
					end if;
				else
					if x<tmp_long then
						csync:='0';
					end if;
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
			
			-- access the titles bitmap
			titles_address(7) <= SEL50HZ;
			titles_address(6 downto 3) <= SELECTION; 			
			titles_address(2 downto 0) <= std_logic_vector(to_unsigned( y-(y1+8), 3));
			
			-- progress counters
			if SEL50HZ='0' and pattern=NES and s=0 and x=200 and y=260 then -- skip half pixel for NES 60 Hz
				s:=4;
			elsif s+1 /= samples then
				s := s+1;
			else
				s:=0;
				if x /= w-1 then
					x := x+1;
				else
					x := 0;
					if y /= h-1 then
						y := y+1;
					else
						y := 0;
					end if;
				end if;
			end if; 
		end if;
	end process;
	
end immediate;
