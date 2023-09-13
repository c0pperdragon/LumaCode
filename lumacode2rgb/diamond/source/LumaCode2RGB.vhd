library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity LumaCode2RGB is	
	port (
	    CLK100     : in std_logic;
		DIFFIN0     : in std_logic;
		PIXCLK     : out std_logic
	);	

	ATTRIBUTE IO_TYPES : string;
	ATTRIBUTE IO_TYPES OF DIFFIN0: SIGNAL IS "LVDS,-";

end entity;


architecture immediate of LumaCode2RGB is

begin

	process (CLK100)
	constant max:integer := 2**15-1;
	constant w:integer := 504 * 2;  -- samples for C64 PAL
	
	variable csync:std_logic_vector(2 downto 0);
	variable x:integer range 0 to max;
	variable total:integer range 0 to max;  -- number of half clocks in previous line
	variable accu:integer range 0 to max;   -- running sum for the "bresenheim" algorithm
	variable oclk:std_logic := '0';         -- output clock (is toggled at every overflow of the sum)
	begin
		if rising_edge(CLK100) then
			if csync="100" and x>8000 then   -- on falling csync 
				total := x+2;
				x := 0;
				accu := total/2;
				oclk := '0';
			else
				-- perform bresenheim
				accu := accu+4*w;
				if accu>=total then
					accu := accu-total;
					oclk := not oclk;
				end if;
				-- count number of half-clocks
				if x<max-2 then
					x := x+2;  
				end if;
			end if;	
			-- sample sync signal
			csync := csync(1 downto 0) & DIFFIN0;			
		end if;
		
		PIXCLK <= oclk;
	end process;
	
end immediate;
