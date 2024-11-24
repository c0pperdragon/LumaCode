library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;

entity Lumacode270p is	
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

 
architecture immediate of Lumacode270p is

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
	clkgen: ClockGenerator PORT MAP ( REFCLK, MHZ_24_000, CLK );
		
	process (CLK)
	variable p:integer range 0 to 3;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	
	variable R:integer range 0 to 3;
	variable G:integer range 0 to 3;
	variable B:integer range 0 to 3;
	variable tmp:std_logic_vector(1 downto 0);
	variable cx:integer range 0 to 1023;
	variable cy:integer range 0 to 511;
	variable left:integer range 0 to 1023;
	variable top:integer range 0 to 511;
	variable totalwidth:integer range 0 to 1023;
	variable totalheight:integer range 0 to 511;
	begin
		if SEL50HZ='1' then
			totalwidth := 528;
			totalheight := 303;
			left := 40;
			top := 31;
		else
			totalwidth := 490;
			totalheight := 273;
			left := 10;
			top := 2;
		end if;
		if rising_edge(CLK) then
			-- determine pattern
			R := 0;
			G := 0;
			B := 0;
			if x>=left and x<left+480 and y>=top and y<top+270 then
				cx := x-left;
				cy := y-top;
				if ((cy=0 or cy=269) and (cx<50 or cx>=430)) 
				or ((cx=0 or cx=479) and (cy<50 or cy>=220))
				then
					R := 3;
					G := 3;
					B := 3;
				elsif cx>=7 and cx<7+256 and cy>=7 and cy<7+256 then
					R := ((cx-7)/32) mod 4;
					B := ((cy-7)/32) mod 4;
					G := (cx-7)/128 + 2*((cy-7)/128);
				elsif cx>=300 and cx<350 and cy>=7 and cy<7+256 then
					R := (cy-7)/64;
				elsif cx>=360 and cx<410 and cy>=7 and cy<7+256 then
					G := (cy-7)/64;
				elsif cx>=420 and cx<470 and cy>=7 and cy<7+256 then
					B := (cy-7)/64;
				end if;
			end if;
		
			-- serialize colors
			if p=0 then
				tmp := std_logic_vector(to_unsigned(R, 2));
			elsif p=1 then
				tmp := std_logic_vector(to_unsigned(G, 2));
			else 
				tmp := std_logic_vector(to_unsigned(B, 2));
			end if;
			INV_LUM0 <= not tmp(0);
			INV_LUM1 <= not tmp(1);
			
			-- make sync
			if SEL50HZ='1' then
				if x<32 or (y<3 and x<totalwidth-32) then
					INV_CSYNC <= '1';
				else
					INV_CSYNC <= '0';
				end if;
			else
				if x<6 or (y<1 and x<totalwidth-6) then
					INV_CSYNC <= '1';
				else
					INV_CSYNC <= '0';
				end if;
			end if;
			
			-- progress counters
			if p<2 then
				p:=p+1;
			else
				p:=0;
				if x<totalwidth-1 then
					x:=x+1;
				else
					x:=0;
					if y<totalheight-1 then
						y:=y+1;
					else
						y:=0;
					end if;
				end if;
			end if;
		end if;
	end process;
	
end immediate;
