library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity Generate14_3MHz is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of Generate14_3MHz is

component PLL28_6 is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic);
end component;

signal CLK28_6: std_logic;

begin
	pll : PLL28_6 PORT MAP ( CLKI => CLK25, CLKOP => CLK28_6 );

	process (CLK28_6)
	variable x:std_logic := '0';
	begin
		if falling_edge(CLK28_6) then
			x := not x;
		end if;
		CP <= "000" & CLK28_6;
		D <= "000000" & x & (not x);
	end process;
	
end immediate;
