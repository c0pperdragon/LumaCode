library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;
 
entity AmigaMonochrome is	
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

  
architecture immediate of AmigaMonochrome is

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


signal CLK:std_logic;

begin
	clkgen: ClockGenerator PORT MAP ( REFCLK, MHZ_14_187, CLK );
		
	process (CLK)	
	constant w:integer := 908;
	constant longsync:integer := 68;
	constant shortsync:integer := 31;	
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 512 := 0;
	variable oddframe:boolean := false;
	variable interlace:boolean := false;
	variable csync:std_logic;
	variable lum:std_logic_vector(1 downto 0);
	variable cx:integer range 0 to 1023;
	variable cy:integer range 0 to 1023;
	variable dx:integer range 0 to 100;
	variable dy:integer range 0 to 100;
	variable d2:integer range 0 to 20000;
	begin
		if rising_edge(CLK) then
			lum := "00";
			csync := '1';
				
			-- calculate position in active area
			cx := 1023;
			cy := 1023;
			if x>=200 and x<200+640 then
				cx := x-200;
			end if;
			if oddframe or not interlace then
				if y>=40 and y<40+256 then
					cy := 2*(y-40);
				end if;
			else
				if y>=40 and y<40+256 then
					cy := 2*(y-40) + 1;
				end if;			
			end if;
				
			-- create test pattern
			if cx/=1023 and cy/=1023 then
				if cx=0 or cx=639 or cy=0 or cy=1 or cy=510 or cy=511 then
					lum := "11";
				elsif cy>=10 and cy<500 and cx>=cy+20 and cx<cy+50 then
					lum := "11";
				elsif cy>=300 and cy<500 and cx>=20 and cx<20+200 then
					lum := std_logic_vector(to_unsigned(( (cy-300)/8 + (cx-20)/8 ) mod 4, 2));
				elsif cx>=400 and cx<600 and cy>50 and cy<250 then
					if cx>=500 then
						dx := cx-500;
					else
						dx := 500-cx;
					end if;
					if cy>=150 then
						dy := cy-150;
					else
						dy := 150-cy;
					end if;
					d2 := dx*dx+dy*dy;
					if d2<=25*25 then
						lum := "00";
					elsif d2<=50*50 then
						lum := "01";
					elsif d2<=75*75 then
						lum := "10";
					elsif d2<=100*100 then
						lum := "11";
					end if;
				end if;			
			end if;
						
			-- generate csync for progressive or first half of interlaced
			if oddframe or not interlace then
				if (y=0) and (x<longsync or (x>=w/2 and x<w/2+shortsync)) then                   -- normal sync, short sync
					csync := '0';
				elsif (y=1 or y=2) and (x<shortsync or (x>=w/2 and x<w/2+shortsync)) then         -- 2x 2 short syncs
					csync := '0';
				elsif (y=3 or y=4) and (x<w/2-longsync or (x>=w/2 and x<w-longsync)) then       -- 2x 2 vsyncs
					csync := '0';
				elsif (y=5) and (x<w/2-longsync or (x>=w/2 and x<w/2+shortsync)) then            -- one vsync, one short sync
					csync := '0';
				elsif (y=6 or y=7) and (x<shortsync or (x>=w/2 and x<w/2+shortsync)) then        -- 2x 2 short syncs
					csync := '0';
				elsif (y>=8) and (x<longsync) then                                                 -- normal syncs
					csync := '0';
				end if;	
			-- generate csync for second half of interlaced
			else
				if (y=0 or y=1) and (x<shortsync or (x>=w/2 and x<w/2+shortsync)) then            -- 2x 2 short syncs
					csync := '0';
				elsif (y=2) and (x<shortsync or (x>=w/2 and x<w-longsync)) then                 -- one short sync, one vsyncs
					csync := '0';					
				elsif (y=3 or y=4) and (x<w/2-longsync or (x>=w/2 and x<w-longsync)) then      -- 2x 2 vsyncs
					csync := '0';
				elsif (y=5 or y=6) and (x<shortsync or (x>=w/2 and x<w/2+shortsync)) then        -- 2x 2 short syncs
					csync := '0';					
				elsif (y=7) and (x<shortsync) then                                                 -- short sync
					csync := '0';
				elsif (y>=8) and (x<longsync) then                                                 -- normal syncs
					csync := '0';
				end if;	
			end if;
					
			-- progress counters
			if x<w-1 then
				x := x+1;
			else
				x := 0;
				if not interlace then
					if y<313-1 then
						y:=y+1;
					else
						y:=0;
						oddframe := not oddframe;
					end if;						
				else
					if (y<313-1 and oddframe) or 
					(y<312-1 and not oddframe) then
						y := y+1;
					else
						y := 0;
						oddframe := not oddframe;
					end if;
				end if;
				interlace := (SELECTION(0) xor SELECTION(1) xor SELECTION(2) xor SELECTION(3)) = '1';
			end if;

			INV_CSYNC <= not csync;
			INV_LUM0 <= not lum(0);
			INV_LUM1 <= not lum(1);
		end if;
	end process;
	
end immediate;
