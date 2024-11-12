library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity AmigaBoost is	
	port (
	    CLK       : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of AmigaBoost is

component PLL_56_94 is
    port (
        CLKI: in  std_logic; 
        CLKOS: out  std_logic;
        CLKOP: out  std_logic
	);
end component;

signal CLK_56: std_logic;

begin
	pll : PLL_56_94 PORT MAP ( CLKI => CLK, CLKOP => open, CLKOS => CLK_56 );

	process (CLK_56)
	variable x:std_logic := '0';
	begin
		if falling_edge(CLK_56) then
			x := not x;
		end if;
		CP <= CLK_56 & "000";
		D <= "0000000" & x;
	end process;
	
end immediate;
