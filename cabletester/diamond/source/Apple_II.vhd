library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity Apple_II is	
	port (
	    CLK25     : in std_logic;
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of Apple_II is

component PLL_28 is
    port (
        CLKI:  in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic);
end component;
 
signal CLK28: std_logic;
 
begin
	pll : PLL_28 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK28);

	process (CLK28)
	begin
		CP <= "000" & (not CLK28); 
	end process;

	process (CLK28)

	constant top:integer := 38;
	constant left:integer := 250;
	variable phase:integer range 0 to 1 :=0;
	variable x:integer range 0 to 1023 := 0;
	variable y:integer range 0 to 511 := 0;
	variable CS:std_logic;
	variable GR:std_logic;
	variable LUM:std_logic;
	variable CS_DELAYED:std_logic;
	begin
		if rising_edge(CLK28) then
            CS := '1';
			GR := '0';
			LUM := '0';
			if x<70 or (y<3 and x<912-70) then
				CS := '0';
			end if;
			if y>=top+192/2 then
				GR := '1';
			end if;
			if x>=left and x<left+560 and y>=top and y<top+192 then
				if x>=left+1 and x<left+560-1 and y>=top+1 and y<top+192-1 then
					if x>=left+50 and x<left+560-50 and y>=top+20 and y<top+192-20 then
						if ((x+y)/4) mod 2 = 1 then
							LUM := '1';
						end if;
					end if;
				else
					LUM := '1';
				end if;
			end if;
			
			D <= "0" & LUM & "000" & CS_DELAYED & "0" & GR; 
			CS_DELAYED := CS;
			
			if phase<1 then
				phase:=phase+1;
			else
				phase := 0;
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
		
	end process;
	
end immediate;
