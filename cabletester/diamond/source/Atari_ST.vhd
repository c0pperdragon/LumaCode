library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity Atari_ST is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of Atari_ST is

component PLL_32 is
    port (
        CLKI:  in  std_logic;
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;

signal CLK32: std_logic;

begin
	pll : PLL_32 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK32 );

	process (CLK32)
	begin
		CP <= "0" & (not CLK32) & "00"; 
	end process;

	process(CLK32)
	constant top:integer := 40;
	constant left:integer := 210;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	variable VI:std_logic;
	variable HS:std_logic;
	variable VS:std_logic;
	begin 
		if rising_edge(CLK32) then
			VI := '0';
			HS := '1';
			VS := '1';
			if y<3 then
				VS := not VS;
			end if;
			if x<65 then
				HS := not HS;
			end if;

			if ((y=top or y=top+400-1) and x>=left and x<left+640)
			or ((x=left or x=left+640-1) and y>=top and y<top+400)
			then
				VI := '1';
			elsif x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+256 then
				if (x + y) mod 2 = 0 then
					VI := '1';
				end if;
			end if;
			
			D <= "00" & HS & "0" & VI & "0" & VS & "0";	
			
			if x<896-1 then
				x:=x+1;
			else
				x:=0;
				if y<501-1 then
					y:=y+1;
				else
					y:=0;
				end if;
			end if;
		end if;
	end process;
	
end immediate;

