library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity EGA is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of EGA is

component PLL_57 is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;

signal CLK57: std_logic;

begin
	pll : PLL_57 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK57 );

	process (CLK57)
	variable phase:integer range 0 to 3;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	variable top:integer := 38;
	variable left:integer := 230;
	variable R:std_logic_vector(3 downto 0);
	variable G:std_logic_vector(3 downto 0);
	variable B:std_logic_vector(3 downto 0);
	variable HS:std_logic;
	variable VS:std_logic;
	begin
		if rising_edge(CLK57) then
			R := "0000";
			G := "0000";
			B := "0000";
			HS := '0';
			VS := '0';
			if y<3 then
				VS := '1';
			end if;
			if x<67 or (y<3 and x<912-67) then
				HS := '1';
			end if;
			if ((y=top or y=top+200-1) and x>=left and x<left+592)
			or ((x=left or x=left+1 or x=left+592-1 or x=left+592-2) and y>=top and y<top+200)
			then
				R := "1111";
				G := "1111";
				B := "1111";
			elsif x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+128 then
				R := std_logic_vector(to_unsigned(((x-(left+40))/4) mod 16, 4));
				G := std_logic_vector(to_unsigned(((y-(top+20))/4) mod 16, 4));
				B(3 downto 3)  := std_logic_vector(to_unsigned((y-(top+20))/64, 1));
				B(2 downto 0)  := std_logic_vector(to_unsigned((x-(left+40))/64, 3));
			elsif x>=left+40 and x<left+40+512 and y>=top+160 and y<top+190 then
				B(3 downto 0) := std_logic_vector(to_unsigned((x-(left+40))/32, 4));
			end if;
			
			if phase=3 then
				D <= VS &  HS & B(2) & G(2) & B(1) &  G(1) & R(0) & "0";
			else
				D <= B(3) & G(3) & R(3) & R(2) & R(1) & B(0) & G(0) & "0";			
			end if;
			
			if phase<3 then
				phase:=phase+1;
			else
				phase:=0;
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
		end if;
		
		if falling_edge(CLK57) then
			if phase=0 then
				CP <= "0100";
			elsif phase=3 then
				CP <= "0010";
			else
				CP <= "0000";
			end if;
		end if;
	end process;
	
end immediate;
