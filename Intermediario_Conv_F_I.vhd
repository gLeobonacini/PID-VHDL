library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Intermediario_Conv_F_I is

  port (
	 i_Clk		: in  std_logic;
	 i_Flag 		: in  std_logic;
    i_A		 	: in  signed(31 downto 0);
	 o_Flag		: out std_logic;
	 o_A			: out signed(31 downto 0);
	 o_Clk		: out std_logic;
	 o_Clear		: out std_logic
    );
end entity Intermediario_Conv_F_I;

architecture RTL of Intermediario_Conv_F_I is
signal 	aux : std_logic := '0';
signal count : unsigned(3 downto 0) := to_Unsigned(0,4);
begin
  
  o_A 	<= i_A;
  o_Clk	<= i_Clk and aux;
  
  p_Intermediario_Conv_F_I : process (i_Clk) is
  
  variable inicio		: std_logic	:= '0';
  
  begin
	
	if (i_Clk = '0' and i_Clk'event) then
		if (i_Flag = '1') then
			inicio := '1';
			aux <= '1';
			o_Clear <= '1';
			count <= to_Unsigned(0,4);
		else
			o_Clear <= '0';
			if(inicio = '1') then
				count <= count + to_Unsigned(1,4);
				if (count = to_Unsigned(6,4)) then	
					o_Flag <= '1';
					aux <= '0';
				elsif (count > to_Unsigned(6,4)) then
					o_Flag <= '0';
					count <= to_Unsigned(0,4);
					inicio := '0';
				end if;
			end if;
		end if;
	end if;
  
  end process p_Intermediario_Conv_F_I;
  
end architecture RTL;