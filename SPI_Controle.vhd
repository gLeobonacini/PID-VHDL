library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity SPI_Controle is
  port (
	 i_Clk	: in  std_logic;
    i_SClk	: in  std_logic;
    i_Mosi  : in  std_logic;
    i_Ss 	: in  std_logic;
	 o_Add   : out signed(7 downto 0);
    o_Flag 	: out std_logic	 
    );
end entity SPI_Controle;
 
architecture RTL of SPI_Controle is 
  signal data : signed(7 downto 0) 	:= to_signed(0,8);
  signal flag : std_logic				:= '0';
begin

  O_Add <= data;
  o_Flag <= flag;

  p_Leitura : process (i_Clk) is
  
  variable count 		: integer := 0;
  variable ins_Ant 	: std_logic := '0';
  variable ins_Atu 	: std_logic := '0';
  
  begin
    if (i_Clk = '0' and i_Clk'event) then
		if (i_Ss = '0' and flag = '0') then
			ins_Ant := ins_Atu;
			ins_Atu := i_SClk;
			
			if (ins_Ant = '0' and ins_Atu = '1') then
				data(count) <= i_Mosi;
				if (count >= 7) then
					count := 0;
					flag <= '1';
				else
					count := count + 1;
				end if;
			end if;
		elsif (flag = '1') then
			flag <= '0';
		end if;
	end if;
  end process p_Leitura; 
  
end architecture RTL;