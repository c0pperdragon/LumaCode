library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;
 
entity AppleIISignal is	
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
 
 
architecture immediate of AppleIISignal is

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

signal CLK28:std_logic;

begin
	clkgen: ClockGenerator PORT MAP ( REFCLK, MHZ_28_636, CLK28 );		

	process (CLK28)

	constant top:integer := 38;
	constant left:integer := 250;
	variable phase:integer range 0 to 1 :=0;
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 511 := 0;
	variable level:integer range 0 to 7;
	begin
		if rising_edge(CLK28) then
			level := 2;
			if x<68 or (y<3 and x<912-68) then
				level := 0;
			elsif (x>=80 and x<120) then
				if y>=top+160 and y<top+192 then
					if (x mod 4)>=2 then
						level := 3;
					else
						level := 1;
					end if;
				else
					if (x mod 4)>=2 then
						level := 5;
					end if;
				end if;
			end if;
			if x>=left and x<left+560 and y>=top and y<top+192 then
				if x>=left+1 and x<left+560-1 and y>=top+1 and y<top+192-1 then
					if x>=left+20 and x<left+560-20 and y>=top+10 and y<top+192-10 then
						if ((x+y)/2) mod 2 = 1 then
							level := 7;
						end if;
					end if;
				else
					level := 7;
				end if;
			end if;
			
			-- level := x mod 8;
			
			case level is
			when 0 => 
				INV_CSYNC <= '1';
				INV_LUM1 <= '1';
				INV_LUM0 <= '1';
			when 1 =>
				INV_CSYNC <= '1';
				INV_LUM1 <= '1';
				INV_LUM0 <= '0';
			when 2 =>
				INV_CSYNC <= '0';
				INV_LUM1 <= '1';
				INV_LUM0 <= '1';				
			when 3 =>
				INV_CSYNC <= '1';
				INV_LUM1 <= '0';
				INV_LUM0 <= '1';
			when 4 =>
				INV_CSYNC <= '0';
				INV_LUM1 <= '1';
				INV_LUM0 <= '0';
			when 5 =>
				INV_CSYNC <= '1';
				INV_LUM1 <= '0';
				INV_LUM0 <= '0';
			when 6 =>
				INV_CSYNC <= '0';
				INV_LUM1 <= '0';
				INV_LUM0 <= '1';
			when 7 =>
				INV_CSYNC <= '0';
				INV_LUM1 <= '0';
				INV_LUM0 <= '0';
			end case;
						
			if phase<1 then
				phase:=phase+1;
			else
				phase := 0;
				if x<912-1 then
					x:=x+1;
				else
					x:=0;
					if y<262-1 then
						y:=y+1;
					else
						y:=0;
					end if;
				end if;
			end if;
		end if;
		
	end process;


end immediate;
