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

component PLL_48 is
    port (
        CLKI:  in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic;
        CLKOS2: out  std_logic);
end component;

signal CLK48: std_logic;
signal CLK48_late: std_logic;


begin
	pll : PLL_48 PORT MAP ( CLKI => CLK25, CLKOP => open, CLKOS => CLK48, CLKOS2 => CLK48_late );

	process (CLK48, CLK48_late)
	type letter is array(0 to 9) of std_logic_vector(7 downto 0);
	constant letter_R:letter := (
	    "00000000",
		"11111100",
		"11000110",
		"11000110",
		"11111100",
		"11001100",
		"11000110",
		"11000011",
	    "00000000",
	    "00000000"
	);
	constant letter_G:letter := (
	    "00000000",
		"00111100",
		"01100110",
		"11000000",
		"11001111",
		"11000011",
		"01111110",
	    "00000000",
	    "00000000",
		"00000000"
	);
	constant letter_B:letter := (
	    "00000000",
		"11111100",
		"11000011",
		"11000011",
		"11111100",
		"11000011",
		"11000011",
		"11111100",
	    "00000000",
	    "00000000"
	);

	constant top:integer := 5;
	constant left:integer := 90;
	variable phase:integer range 0 to 3;
	variable x:integer range 0 to 1023;
	variable y:integer range 0 to 511;
	variable R:std_logic_vector(1 downto 0);
	variable G:std_logic_vector(1 downto 0);
	variable B:std_logic_vector(1 downto 0);
	variable HS:std_logic;
	variable VS:std_logic;
	variable CS:std_logic;
	variable CP_next:std_logic_vector(3 downto 0);
	begin 
		if rising_edge(CLK48) then
			R := "00";
			G := "00";
			B := "00";
			HS := '1';
			VS := '0';
			CS := '1';
			if y<3 then
				VS := '1';
			end if;
			if x<65 then
				HS := '0';
			end if;
			if x<65 or (y<3 and x<744-65) then
				CS := '0';
			end if;
			if ((y=top or y=top+350-1) and x>=left and x<left+640)
			or ((x=left or x=left+640-1) and y>=top and y<top+350)
			then
				R := "11";
				G := "11";
				B := "11";
			elsif x>=left+40 and x<left+40+512 and y>=top+20 and y<top+20+256 then
				R := std_logic_vector(to_unsigned(((x-(left+40))/64) mod 4, 2));
				B := std_logic_vector(to_unsigned(((y-(top+20))/32) mod 4, 2));
				G(0 downto 0) := std_logic_vector(to_unsigned((x-(left+40))/256, 1));
				G(1 downto 1) := std_logic_vector(to_unsigned((y-(top+20))/128, 1));
			elsif x>=left+40 and x<left+40+512 and y>=top+310 and y<top+320 then
				R(1 downto 0) := std_logic_vector(to_unsigned((x-(left+40))/128, 2));
				if x<left+40+16 and letter_R(y-(top+310))(7-(x-(left+40))/2)='1' then
					R := "11";
				end if;
			elsif x>=left+40 and x<left+40+512 and y>=top+320 and y<top+330 then
				G(1 downto 0) := std_logic_vector(to_unsigned((x-(left+40))/128, 2));
				if x<left+40+16 and letter_G(y-(top+320))(7-(x-(left+40))/2)='1' then
					G := "11";
				end if;
			elsif x>=left+40 and x<left+40+512 and y>=top+330 and y<top+340 then
				B(1 downto 0) := std_logic_vector(to_unsigned((x-(left+40))/128, 2));
				if x<left+40+16 and letter_B(y-(top+330))(7-(x-(left+40))/2)='1' then
					B := "11";
				end if;
			end if;
			
			if phase=0 then 
				-- EGA output
				D <= B(1) & G(1) & R(1) & R(0) & (not VS) & (not HS) & B(0) & G(0);	
				CP_next := "0001";
			elsif phase=1 then
			    -- 8-pin din, atari st
				D <= CS & G(1) & HS & B(1) & (R(0) or R(1) or G(0) or G(1) or B(0) or B(1)) & R(1) & VS & (R(0) or G(0) or B(0));
				CP_next := "0100";
            else		
                -- 6-pin din 			
				D <= "0" & CS & "0" &  B(1) & "0" & G(1) & R(1) & "0";
				CP_next := "1000";
			end if;
			
			if phase<2 then
				phase:=phase+1;
			else
				phase:=0;
				if x<744-1 then
					x:=x+1;
				else
					x:=0;
					if y<365-1 then
						y:=y+1;
					else
						y:=0;
					end if;
				end if;
			end if;
		end if;
		
		if rising_edge(CLK48_late) then			
			CP <= CP_next; 
		end if;
	end process;
	
end immediate;
