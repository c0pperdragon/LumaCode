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

begin
	clkgen : ClockGenerator PORT MAP ( REFCLK => REFCLK, frequency => FREQUENCY, CLK => CLK );

	process (selector)
	begin
		case selector is 
		when "0000" => FREQUENCY <= MHZ_15_763;  -- C64 PAL
		when "1000" => FREQUENCY <= MHZ_16_363;  -- C64 NTSC		
		when "0001" => FREQUENCY <= MHZ_21_281;  -- Atari 8-bit PAL
		when "1001" => FREQUENCY <= MHZ_21_477;  -- Atari 8-bit NTSC
		when "0010" => FREQUENCY <= MHZ_8_867;   -- VIC 20 PAL
		when "1010" => FREQUENCY <= MHZ_8_181;   -- VIC 20 NTSC
		when "0011" => FREQUENCY <= MHZ_14_187;  -- Atari 2600 PAL
		when "1011" => FREQUENCY <= MHZ_14_318;  -- Ataru 2600 NTSC		
		when others => FREQUENCY <= MHZ_15_763;  -- C64 PAL
		end case;		
		debug <= selector(3) or selector(2) or selector(1) or selector(0);
	end process;
	
	process (CLK)
	variable counter : integer range 0 to 15;
	begin
		if rising_edge(CLK) then
			if counter<4 then
				if counter=1 or counter=3 then
					INV_LUM0 <= '0';
				else
					INV_LUM0 <= '1';
				end if;
				if counter>=2 then
					INV_LUM1 <= '0';
				else
					INV_LUM1 <= '1';
				end if;
				INV_CSYNC <= '0';
			else
				INV_CSYNC <= '1';
				INV_LUM0 <= '1';
				INV_LUM1 <= '1';
			end if;

			if counter=9 then
				counter := 0;
			else
				counter := counter+1;
			end if;
		end if;
	end process;

end immediate;
