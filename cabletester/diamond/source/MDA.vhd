library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity MDA is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of MDA is

component PLL_16 is
    port (
        CLKI:  in  std_logic;
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;

signal CLK16: std_logic;

begin
	pll : PLL_16 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK16 );

	process (CLK16)
	begin
		CP <= "000" & (not CLK16); 
	end process;

	process(CLK16)
	constant top:integer := 4;
	constant left:integer := 73;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	variable VI:std_logic_vector(1 downto 0);
	variable HS:std_logic;
	variable VS:std_logic;
	begin 
		if rising_edge(CLK16) then
			VI := "00";
			HS := '0';
			VS := '1';
			if y<3 then
				VS := not VS;
			end if;
			if x<65 then
				HS := not HS;
			end if;

			if ((y=top or y=top+350-1) and x>=left and x<left+720)
			or ((x=left or x=left+720-1) and y>=top and y<top+350)
			then
				VI := "11";
			elsif x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+256 then
				VI(1) := '1';
				VI(0 downto 0) := std_logic_vector(to_unsigned(((y-(top+20))/128) mod 2, 1));
			end if;
			
			D <= "0000" & VS & HS & VI(1) & VI(0);	
			
			if x<882-1 then
				x:=x+1;
			else
				x:=0;
				if y<370-1 then
					y:=y+1;
				else
					y:=0;
				end if;
			end if;
		end if;
	end process;
	
end immediate;

