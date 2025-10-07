library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity Amiga is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of Amiga is

component PLL_21 is
    port (
        CLKI:  in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;
 
signal CLK21: std_logic;
 
begin
	pll : PLL_21 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK21);

	process (CLK21)
	begin
		CP <= "000" & (not CLK21); 
	end process;

	process (CLK21)

	constant top:integer := 20;
	constant left:integer := 26;
	variable phase:integer range 0 to 1 := 0;
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 511 := 0;
	variable R:std_logic_vector(3 downto 0);
	variable G:std_logic_vector(3 downto 0);
	variable B:std_logic_vector(3 downto 0);
	variable HS:std_logic;
	variable VS:std_logic;
	variable px:integer range 0 to 63;
	variable py:integer range 0 to 63;
	begin
		if rising_edge(CLK21) then
			R := "0000";
			G := "0000";
			B := "1010";
			VS := '0';
			HS := '1';
			if y<3 and x<681-50 then
				VS := '1';
			elsif x<50 then
				HS := '0';
			end if;
			if x>=left and x<left+640 and y>=top and y<top+256 then
				R := "1111";
				G := "1111";
				B := "1111";
				if x>=left+1 and x<left+640-1 and y>=top+1 and y<top+256-1 then
					R := "0000";
					G := "0000";
					B := "0000";
				end if;
				if x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+192 then
					px := (x-left-40)/8;
					py := (y-top-20)/3;
					R := std_logic_vector(to_unsigned(px mod 16, 4));
					B := std_logic_vector(to_unsigned(py mod 16, 4));
					G := std_logic_vector(to_unsigned(py/16, 2)) & std_logic_vector(to_unsigned(px/16, 2));
				end if;
			end if;
			
			if phase=0 then
				D <= B(3) & G(3) & R(3) & R(2) & HS & VS & B(2) & G(2);	
			else
				D <= B(1) & G(1) & R(1) & R(0) & HS & VS & B(0) & G(0);	
			end if;
			
			if phase<1 then
				phase:=phase+1;
			else
				phase:=0;
				if x<681-1 then
					x:=x+1;
				else
					x:=0;
					if y<312-1 then
						y:=y+1;
					else
						y:=0;
					end if;
				end if;
			end if;
		end if;
		
	end process;
	
end immediate;
