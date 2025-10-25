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
	variable CS:std_logic;
	variable BURST:std_logic;
	variable LUM:std_logic;
	variable CS_DELAYED:std_logic;
	begin
		if rising_edge(CLK28) then
            CS := '1';
			BURST := '0';
			LUM := '0';
			if x<68 or (y<3 and x<912-68) then
				CS := '0';
			elsif (x>=80 and x<120) and (x mod 4)>=2 and not (y>=top+160 and y<260) then
				BURST := '1';
			end if;
			if x>=left and x<left+560 and y>=top and y<top+192 then
				if x>=left+1 and x<left+560-1 and y>=top+1 and y<top+192-1 then
					if x>=left+50 and x<left+560-50 and y>=top+20 and y<top+192-20 then
						if ((x+y)/4) mod 2 = 1 then
							LUM := '1';
						end if;
					end if;
				else
					LUM := '1';
				end if;
			end if;
			
			INV_CSYNC <= not CS;
			if LUM='1' then
				INV_LUM0 <= '0';
				INV_LUM1 <= '0';
			elsif BURST='1' then
				INV_LUM0 <= '1';
				INV_LUM1 <= '0';
			else
				INV_LUM0 <= '1';
				INV_LUM1 <= '1';
			end if;
			CS_DELAYED := CS;
			
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
