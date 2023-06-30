library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity SignalGenerator is	
	port (
	    -- 80 mhz oscillator input
		clk80           : in std_logic;
		-- dip switches to select output signal
		selector        : in std_logic_vector(3 downto 0);
		-- generated lumacode signals
		INV_CSYNC       : out std_logic;
		INV_LUM0        : out std_logic;
		INV_LUM1        : out std_logic
	);	
end entity;
 
architecture immediate of SignalGenerator is

component PLL_21_375     -- 80Mhz -> 21.375 Mhz
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic
	);
end component;

signal CLK : std_logic;

begin
	pll : PLL_21_375 PORT MAP ( CLKI => clk80, CLKOP => CLK );
	
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

			if counter=15 or counter = to_integer(unsigned(selector)) then
				counter := 0;
			else
				counter := counter+1;
			end if;
		end if;
	end process;

end immediate;
