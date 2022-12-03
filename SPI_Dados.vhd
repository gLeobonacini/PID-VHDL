library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity SPI_Dados is
  port (
    i_Clk		: in  std_logic;
    i_SClk		: in  std_logic;
    i_Mosi  	: in  std_logic;
    i_Ss 		: in  std_logic;
	 o_Data		: out signed(31 downto 0);
	 o_Index 	: out std_logic;
    o_Flag 		: out std_logic	 
    );
end entity SPI_Dados;
 
architecture RTL of SPI_Dados is 
  signal data : signed(39 downto 0) := to_signed(39,40);
  signal flag : std_logic := '0';
begin

  O_Data <= data(31 downto 0);
  o_Index <= '1' WHEN (data(31 downto 24) xor data(23 downto 16) xor data(15 downto 8) xor data(7 downto 0)) = data(39 downto 32) ELSE '0';
  o_Flag <= flag;

  p_Leitura : process (i_Clk) is
  
  variable count 		: integer 	:= 39;
  variable ins_Ant 	: std_logic := '0';
  variable ins_Atu 	: std_logic := '0';
  
  begin
	if (i_Clk = '0' and i_Clk'event) then
		if (i_Ss = '0' and flag = '0') then
			ins_Ant := ins_Atu;
			ins_Atu := i_SClk;
			
			if (ins_Ant = '0' and ins_Atu = '1') then
				data(count) <= i_Mosi;
				if (count <= 0) then
					count := 39;
					flag <= '1';
				else
					count := count - 1;
				end if;
			end if;
		elsif (flag = '1') then
			flag <= '0';
		end if;	
	end if;
	
  end process p_Leitura; 
end architecture RTL;