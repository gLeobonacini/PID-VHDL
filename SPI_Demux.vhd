library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity SPI_Demux is
  port (
	 i_Clk				: in  std_logic;
    i_Flag_Controle	: in  std_logic;
	 i_Add				: in  signed(7 downto 0);
    i_Flag_Dados 		: in  std_logic;
	 i_Data				: in  signed(31 downto 0);
    i_Index				: in  std_logic;
	 o_Flag_vel_1		: out std_logic;
	 o_Flag_vel_2		: out std_logic;
	 o_Flag_ser			: out std_logic;
    o_Data				: out signed(31 downto 0)	 
    );
end entity SPI_Demux;
 
architecture RTL of SPI_Demux is 
begin
    
  p_Demux_Add : process (i_Clk) is
  
  	variable vel_1 : std_logic := '0';
	variable vel_2 : std_logic := '0';
	variable ser 	: std_logic := '0';
	
  begin
   
	if (i_Clk = '1' and i_Clk'event) then
	
		-- Endereço pronto
		if (i_Flag_Controle = '1') then
			if (i_Add = to_signed(1,8)) then
				vel_1 := '1';
				vel_2 := '0';
				ser := '0';
			elsif (i_Add = to_signed(2,8)) then
				vel_1 := '0';
				vel_2 := '1';
				ser := '0';
			elsif (i_Add = to_signed(3,8)) then
				vel_1 := '0';
				vel_2 := '0';
				ser := '1';
			end if;

		-- Dado pronto
		elsif (i_Flag_Dados = '1') then
			o_Flag_vel_1 <= vel_1;
			o_Flag_vel_2 <= vel_2;
			o_Flag_ser <= ser;
			if (i_Index = '1') then
				o_Data <= i_Data;
			end if;
		
		else
			o_Flag_vel_1 <= '0';
			o_Flag_vel_2 <= '0';
			o_Flag_ser <= '0';
		end if;
	
	end if;
	
  end process p_Demux_Add;

end architecture RTL;