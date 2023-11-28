
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Frequencies.all;

entity ClockGenerator is
	port (
	    -- reference oscillator input
		REFCLK          : in std_logic;
		-- selected output frequency
		frequency       : in t_Frequency;
		-- generated clock
		CLK             : out std_logic
	);	
end entity;
 
architecture immediate of ClockGenerator is

-- 80Mhz -> 15.763 Mhz
component PLL_15_763     
    port (
        CLKI: in  std_logic; 
        PLLCLK: in  std_logic; 
        PLLRST: in  std_logic; 
        PLLSTB: in  std_logic; 
        PLLWE: in  std_logic; 
        PLLDATI: in  std_logic_vector(7 downto 0); 
        PLLADDR: in  std_logic_vector(4 downto 0); 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic; 
        PLLDATO: out  std_logic_vector(7 downto 0); 
        PLLACK: out  std_logic
	);
end component;

-- wishbone interface
component EFB_FOR_PLL     port (
	    wb_clk_i: in  std_logic; 
        wb_rst_i: in  std_logic; 
        wb_cyc_i: in  std_logic; 
        wb_stb_i: in  std_logic; 
        wb_we_i: in  std_logic; 
        wb_adr_i: in  std_logic_vector(7 downto 0); 
        wb_dat_i: in  std_logic_vector(7 downto 0); 
        wb_dat_o: out  std_logic_vector(7 downto 0); 
        wb_ack_o: out  std_logic; 
        pll0_bus_i: in  std_logic_vector(8 downto 0); 
        pll0_bus_o: out  std_logic_vector(16 downto 0)
	);
end component;

signal PLL_bus_i: std_logic_vector(8 downto 0);
signal PLL_bus_o: std_logic_vector(16 downto 0);
signal WB_clk : std_logic; 
signal WB_cyc : std_logic; 
signal WB_we : std_logic;
signal WB_adr : std_logic_vector(7 downto 0); 
signal WB_dat_i : std_logic_vector(7 downto 0); 
signal WB_ack : std_logic; 

begin
	my_pll : PLL_15_763 PORT MAP ( 
		CLKI => REFCLK,
		CLKOP => open, 
		CLKOS => CLK,
		PLLCLK => PLL_bus_o(16),
		PLLRST => PLL_bus_o(15),
		PLLSTB => PLL_bus_o(14),
		PLLWE => PLL_bus_o(13),
		PLLADDR => PLL_bus_o(12 downto 8),
		PLLDATI => PLL_bus_o(7 downto 0),
		PLLDATO => PLL_bus_i(8 downto 1),
		PLLACK => PLL_bus_i(0)		
	);
	my_efb : EFB_FOR_PLL PORT MAP (
        wb_clk_i => WB_clk, 
        wb_rst_i => '0', 
        wb_cyc_i => WB_cyc, 
        wb_stb_i => '1', 
        wb_we_i => WB_we, 
        wb_adr_i => WB_adr, 
        wb_dat_i => WB_dat_i, 
        wb_dat_o => open, 
        wb_ack_o => WB_ack,
        pll0_bus_i => PLL_bus_i,
        pll0_bus_o => PLL_bus_o	
	);

	-- divide reference clock down to a safe wishbone clock 
	process (REFCLK)
	variable counter:integer range 0 to 7 := 0;
	begin
		if rising_edge(REFCLK) then
			if counter<4 then 
				WB_clk <= '0';
			else
				WB_clk <= '1';
			end if;
			if counter=7 then
				counter:=0;
			else
				counter:=counter+1;
			end if;
		end if;
	end process;

	-- monitor the frequency input setting and adjust PLL accordingly
	process (WB_clk)
	variable startup : integer range 0 to 100000 := 100000;
	variable didinit : boolean := false;
	variable freq_set : t_Frequency := MHZ_15_763;
	variable freq_now : t_Frequency := MHZ_15_763;
	variable reconfiguring : integer range 0 to 3 := 0;
	variable diva: integer range 0 to 127;
	variable divb: integer range 0 to 127;
	begin
		if rising_edge(WB_clk) then
			if startup/=0 then
				WB_cyc <= '0';
				startup := startup-1;
			elsif reconfiguring=0 then
				if freq_set /= freq_now or not didinit then
					case freq_set is 
					when MHZ_15_763 => diva:=41; divb:=26; 
					when MHZ_16_363 => diva:=54; divb:=33; 
					when MHZ_21_281 => diva:=66; divb:=31;
					when MHZ_21_477 => diva:=58; divb:=27;
					when MHZ_8_867  => diva:=47; divb:=53;
					when MHZ_8_181  => diva:=45; divb:=55;
					when MHZ_14_187 => diva:=61; divb:=43;
					when MHZ_14_318 => diva:=63; divb:=44;
					when others     => diva:=41; divb:=26;
					end case;
					WB_cyc <= '1';            -- start a cycle
					WB_we <= '1';             -- write
					WB_adr <= "00000110";     -- register 6: MC1_DIVA 
					WB_dat_i <= std_logic_vector(to_unsigned(diva-1, 8));
					reconfiguring := 1;
					freq_now := freq_set;
					didinit := true;
				else
					WB_cyc <= '0';
				end if;
			elsif reconfiguring=1 then
				if WB_ack='1' then      -- wait for ack and then end cycle
					WB_cyc <= '0';
					reconfiguring := 2;
				end if;
			elsif reconfiguring=2 then
				WB_cyc <= '1';            -- start a cycle
				WB_we <= '1';             -- write
				WB_adr <= "00000111";     -- register 7: MC1_DIVB 
				WB_dat_i <= std_logic_vector(to_unsigned(divb-1, 8));
				reconfiguring := 3;
			elsif reconfiguring=3 then
				if WB_ack='1' then      -- wait for ack and then end cycle
					WB_cyc <= '0';
					reconfiguring := 0;
				end if;
			end if;
			
			freq_set := frequency;
		end if;
	end process;

end immediate;
