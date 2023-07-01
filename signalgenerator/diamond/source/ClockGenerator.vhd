library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;

entity ClockGenerator is	
	port (
	    -- 80 mhz oscillator input
		CLK80           : in std_logic;
		-- selected output frequency
		frequency       : in t_Frequency;
		-- generated clock
		CLK             : out std_logic
	);	
end entity;
 
architecture immediate of ClockGenerator is

component PLL_21_375     -- 80Mhz -> 21.375 Mhz
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic
	);
end component;

begin
	pll : PLL_21_375 PORT MAP ( CLKI => CLK80, CLKOP => CLK );

end immediate;
