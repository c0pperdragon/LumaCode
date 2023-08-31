library ieee;
library machxo2;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use machxo2.all;

entity LEDAnimation is	
	port (
		D         : out std_logic_vector(7 downto 0);
		CP        : out std_logic_vector(3 downto 0)
	);	
end entity;


architecture immediate of LEDAnimation is

COMPONENT OSCH
	GENERIC (NOM_FREQ: string);
	PORT (
		STDBY:IN std_logic;
		OSC:OUT std_logic;
		SEDSTDBY:OUT std_logic
	);
END COMPONENT;

signal CLK : std_logic;

begin
	-- instantiate internal oscillator
	OSCInst0: OSCH
	GENERIC MAP( NOM_FREQ => "88.67" )
	PORT MAP ( STDBY=> '0', OSC => CLK, SEDSTDBY => open );

	-- generate output led animation
	process (CLK)
	
	variable phase: integer range 0 to 7 := 0;
	variable led: std_logic_vector(31 downto 0);
	variable delay: integer range 0 to 32000000 := 0;
	variable anim: integer range 0 to 31 := 0;
	
	begin
		if rising_edge(CLK) then
			case phase is
			when 0 => CP <= "0000"; D <= led(7 downto 0);
			when 1 => CP <= "0001"; 
			when 2 => CP <= "0000"; D <= led(15 downto 8);
			when 3 => CP <= "0010"; 
			when 4 => CP <= "0000"; D <= led(16)&led(17)&led(18)&led(19)&led(20)&led(21)&led(22)&led(23);
			when 5 => CP <= "0100"; 
			when 6 => CP <= "0000"; D <= led(24)&led(25)&led(26)&led(27)&led(28)&led(29)&led(30)&led(31);
			when 7 => CP <= "1000"; 
			end case;
			phase := (phase+1) mod 8;
			
			for L in 0 to 31 loop
				if (anim<24 and L>=anim and L<anim+8)
				or (anim>=24 and (L>=anim or L<anim-24))
				then 
					led(L) := '1'; 
				else
					led(L) := '0';
				end if;
			end loop;
			if delay>0 then
				delay:=delay-1;
			else
				delay:=30000000;
				anim := (anim+1) mod 32;
			end if;	
		end if;
	end process;
	
end immediate;
