library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity Generate100MHz is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of Generate100MHz is

component PLL200 is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic);
end component;

signal CLK200: std_logic;

begin
	pll : PLL200 PORT MAP ( CLKI => CLK25, CLKOP => CLK200 );

	process (CLK200)
	variable x:std_logic := '0';
	begin
		if falling_edge(CLK200) then
			x := not x;
		end if;
		CP <= CLK200 & "000";
		D <= "0000000" & x;
	end process;
	
end immediate;
