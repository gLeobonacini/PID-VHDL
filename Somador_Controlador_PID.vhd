library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Somador_Controlador_PID is
  port (
		i_Clk				: in  std_logic;
		i_Flag_Motor_1	: in  std_logic;
		i_Vel_Motor_1	: in  signed(31 downto 0);
		i_Flag_Motor_2	: in  std_logic;
		i_Vel_Motor_2	: in  signed(31 downto 0);
		i_Flag_SP_1		: in  std_logic;
		i_Flag_SP_2		: in  std_logic;
		i_SetPoint		: in  signed(31 downto 0);
		o_Flag_1			: out std_logic;
		o_Error_At_1	: inout signed(31 downto 0);
		o_Error_Ant_1	: out signed(31 downto 0);
		o_Flag_2			: out std_logic;
		o_Error_At_2	: inout signed(31 downto 0);
		o_Error_Ant_2	: out signed(31 downto 0)		
    );
end entity Somador_Controlador_PID;
 
architecture RTL of Somador_Controlador_PID is
	signal SetPoint_1	: signed(31 downto 0) := to_signed(0,32);
	signal SetPoint_2	: signed(31 downto 0) := to_signed(0,32);
	signal Erro1		: signed(31 downto 0) := to_signed(0,32);
	signal Erro2	 	: signed(31 downto 0) := to_signed(0,32);
begin
    
  p_Somador_Controlador_PID : process (i_Clk) is
  variable flag1 : std_logic := '0';
  variable flag2 : std_logic := '0';
  begin
  
   o_Flag_1 <= flag1;
	o_Flag_2 <= flag2;
	
	if (i_Clk = '0' and i_Clk'event) then
	
		if (i_Flag_Motor_1 = '1') then
			o_Error_Ant_1 <= o_Error_At_1;
			o_Error_At_1 <= SetPoint_1 - i_Vel_Motor_1;
			flag1 := '1';
		end if;
		
		if (i_Flag_Motor_2 = '1') then
			o_Error_Ant_2 <= o_Error_At_2;
			o_Error_At_2 <= SetPoint_2 - i_Vel_Motor_2;
			flag2 := '1';
		end if;
		
		if (i_Flag_SP_1 = '1') then
			SetPoint_1 <= i_SetPoint;
		end if;
		
		if (i_Flag_SP_2 = '1') then
			SetPoint_2 <= i_SetPoint;
		end if;
		
		if (flag1 = '1') then
			flag1 := '0';
		end if;
		
		if (flag2 = '1') then
			flag2 := '0';
		end if;
	
	end if;
	
  end process p_Somador_Controlador_PID;

end architecture RTL;