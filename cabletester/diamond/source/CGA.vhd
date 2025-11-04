library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity CGA is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of CGA is

component PLL_14 is
    port (
        CLKI:  in  std_logic;
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;

signal CLK14: std_logic;

begin
	pll : PLL_14 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK14 );

	process (CLK14)
	begin
		CP <= "000" & (not CLK14); 
	end process;

	process(CLK14)
	constant top:integer := 37;
	constant left:integer := 185;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	variable RGBI:std_logic_vector(3 downto 0);
	variable HS:std_logic;
	variable VS:std_logic;
	begin 
		if rising_edge(CLK14) then
			RGBI := "0000";
			HS := '0';
			VS := '0';
			if y<3 then
				VS := not VS;
			end if;
			if x<65 then
				HS := not HS;
			end if;

			if ((y=top or y=top+200-1) and x>=left and x<left+640)
			or ((x=left or x=left+640-1) and y>=top and y<top+200)
			then
				RGBI := "1111";
			elsif x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+128 then
				RGBI(3 downto 1) := std_logic_vector(to_unsigned(((x-(left+40))/64) mod 8, 3));
				RGBI(0 downto 0) := std_logic_vector(to_unsigned(((y-(top+20))/64) mod 2, 1));
			end if;
			
			D <= RGBI(1) & RGBI(2) & RGBI(3) & "0" & VS & HS & "0" & RGBI(0);	
			
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
	end process;
	
end immediate;
