library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;
 
entity Gameboy is	
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

  
architecture immediate of Gameboy is

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
	clkgen: ClockGenerator PORT MAP ( REFCLK, MHZ_8_388, CLK );
		
	process (CLK)	
	constant w:integer := 268;
	constant h:integer := 524;
	constant s:integer := 20;
	variable x:integer range 0 to 511 := 0;
	variable y:integer range 0 to 1023 := 0;
	variable csync:std_logic;
	variable lum:std_logic_vector(1 downto 0);
	variable cx:integer range 0 to 255;
	variable cy:integer range 0 to 255;
	variable dx:integer range 0 to 50;
	variable dy:integer range 0 to 50;
	variable d2:integer range 0 to 4095;
	variable extratick:boolean;
	begin
		if rising_edge(CLK) then
			lum := "00";
			csync := '1';
				
			-- calculate position in active area
			cx := 255;
			cy := 255;
			if x>=70 and x<70+160 then
				cx := x-70;
			end if;
			if y>=62 and y<62+3*144 then
				cy := (y-62)/3;
			end if;
			extratick := y>=62+3*144 and y<62+3*144+16;
				
			-- create test pattern
			if cx/=255 and cy/=255 then
				if cx=0 or cx=159 or cy=0 or cy=143 then
					lum := "11";
				elsif cx>=80-50 and cx<=80+50 and cy>=72-50 and cy<=72+50 then
					if cx>=80 then
						dx := cx-80;
					else
						dx := 80-cx;
					end if;
					if cy>=72 then
						dy := cy-72;
					else
						dy := 72-cy;
					end if;
					d2 := dx*dx+dy*dy;
					if d2<=12*12 then
						lum := "00";
					elsif d2<=25*25 then
						lum := "01";
					elsif d2<=37*37 then
						lum := "10";
					elsif d2<=50*50 then
						lum := "11";
					end if;
				end if;			
			end if;
						
			-- generate csync 
			if y<3 then
				if x<w-s then
					csync := '0';
				end if;
			else
				if x<s then
					csync := '0';
				end if;
			end if;
					
			-- progress counters
			if x<w-1 or (x<w and extratick) then
				x := x+1;
			else
				x := 0;
				if y<h-1 then
					y:=y+1;
				else
					y:=0;
				end if;
			end if;

			INV_CSYNC <= not csync;
			INV_LUM0 <= not lum(0);
			INV_LUM1 <= not lum(1);
		end if;
	end process;
	
end immediate;
