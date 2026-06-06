library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;
 
entity NoninvertingGenerator is	
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
 
 
architecture immediate of NoninvertingGenerator is

component SignalGenerator    
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
end component;

signal INNER_CSYNC : std_logic;
signal INNER_LUM0 : std_logic;
signal INNER_LUM1 : std_logic;

begin
	gen: SignalGenerator PORT MAP ( 
		REFCLK,
		SEL50HZ,
		SELECTION,
		INNER_CSYNC,
		INNER_LUM0,
		INNER_LUM1
	);
		
	process (INNER_CSYNC, INNER_LUM0, INNER_LUM1)
	begin
		INV_CSYNC <= not INNER_CSYNC;
		INV_LUM0 <= not INNER_LUM0;
		INV_LUM1 <= not INNER_LUM1;
	end process;
	
end immediate;
