library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity Unidade_Controle is

generic (
	 P		: real 		:= 0.0;
	 I		: real 		:= 0.0;
    D		: real 		:= 0.0;
	 dt 	: real	 	:= 0.0
    );

  port (
	 i_Clk				: in  std_logic;
	 i_Flag_Conv_I_F	: in  std_logic;
    i_Conv_I_F	 		: in  signed(31 downto 0);
	 i_Flag_Sum_Sub 	: in  std_logic;
    i_Sum_Sub 			: in  signed(31 downto 0);
	 i_Flag_Mult 		: in  std_logic;
    i_Mult 				: in  signed(31 downto 0);
	 i_Flag_Div 		: in  std_logic;
    i_Div		 		: in  signed(31 downto 0);
	 i_Flag_Conv_F_I	: in  std_logic;
    i_Conv_F_I	 		: in  signed(31 downto 0);
	 i_Flag				: in  std_logic;
	 i_Error_At			: in  signed(31 downto 0);
	 i_Error_Ant		: in  signed(31 downto 0);
	 o_Flag_Conv_I_F	: out std_logic;
	 o_Conv_I_F			: out signed(31 downto 0);
	 o_Flag_Sum_Sub	: out std_logic;
	 o_Sum_Sub			: out std_logic;
	 o_Sum_A		 		: out signed(31 downto 0);
	 o_Sum_B		 		: out signed(31 downto 0);
	 o_Flag_Mult		: out std_logic;
	 o_Mult_A		 	: out signed(31 downto 0);
	 o_Mult_B			: out signed(31 downto 0);
	 o_Flag_Div			: out std_logic;
	 o_Div_A		 		: out signed(31 downto 0);
	 o_Div_B				: out signed(31 downto 0);
	 o_Flag_Conv_F_I	: out std_logic;
	 o_Conv_F_I			: out signed(31 downto 0);
	 o_Flag_PWM			: out std_logic;
    o_PWM				: out signed(31 downto 0)
    );
end entity Unidade_Controle;
 
architecture RTL of Unidade_Controle is
	
	function Conv_Real_Float (Dado : real) return std_logic_vector is
		
		variable frac	: real;
		variable prod	: real;
		variable buff	: std_logic_vector(22 downto 0);
		variable sinal	: std_logic;
		variable exp	: integer;
	
	begin
	
		if (Dado /= 0.0) then
			if (Dado >= 0.0) then
				sinal := '0';
			else
				sinal := '1';
			end if;
			exp := 0;
			frac := abs(Dado);
			
			expsum : for i in 0 to 127 loop
				if (frac >= 1.0) then
					frac := frac/2.0;
					exp := exp + 1;
				end if;
			end loop expsum;
			
			expsub : for i in 0 to 127 loop
				if (frac < 0.5) then
					frac := frac*2.0;
					exp := exp - 1;
				end if;
			end loop expsub;
			
			exp := exp + 126;
			frac := frac*2.0;
			frac := frac - 1.0;
			
			convert : for i in 22 downto 0 loop
				prod := frac*2.0;
				if (prod >= 1.0) then
					buff(i) := '1';
					frac := prod - 1.0;
				else
					buff(i) := '0';
					frac := prod;
				end if;
			end loop convert;
			return sinal & std_logic_vector(to_Unsigned(exp,8)) & buff;
		else
			return std_logic_vector(to_Signed(0,32));
		end if;
		
	end function;
	
	constant PF_P 		: signed(31 downto 0) := signed(Conv_Real_Float(P));
	constant PF_I 		: signed(31 downto 0) := signed(Conv_Real_Float(I));
	constant PF_D 		: signed(31 downto 0) := signed(Conv_Real_Float(D));
	constant PF_dt 	: signed(31 downto 0) := signed(Conv_Real_Float(dt));
	constant PF_2		: signed(31 downto 0) := signed(conv_Real_Float(2.0));

begin

  p_Unidade_Controle : process (i_Clk) is
  
  variable calculo 			: std_logic					:= '0';
  variable i					: integer					:= 0;
  variable Erro_Atual		: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Erro_Anterior	: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Controle_P		: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Controle_I		: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Aux_Controle_I	: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Soma_I				: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Controle_D		: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Aux_Controle_D	: signed(31 downto 0) 	:= to_Signed(0,32);
  variable Controle_PID		: signed(31 downto 0) 	:= to_Signed(0,32);
  
  begin
	
	if (i_Clk = '1' and i_Clk'event) then
		
		if (i_Flag = '1') then
			calculo 			:= '1';
			i					:= 0;
			Erro_Atual 		:= i_Error_At;
			Erro_Anterior 	:= i_Error_Ant;
		else
			if (calculo = '1') then
				if (i = 0) then
					o_Flag_Conv_I_F 	<= '1';
					o_Conv_I_F			<= Erro_Atual;				
					o_Flag_Mult 		<= '1';
					o_Mult_A				<= PF_I;
					o_Mult_B				<= PF_dt;
					o_Flag_Div 			<= '1';
					o_Div_A				<= PF_D;
					o_Div_B				<= PF_dt;				
					Aux_Controle_I 	:= Erro_Anterior + Erro_Atual;
					Controle_D 			:= Erro_Atual - Erro_Anterior;
					Soma_I 				:= Controle_I;
					i := i + 1;
			
				elsif(i = 1) then	
					o_Flag_Conv_I_F 	<= '0';
					o_Flag_Mult 		<= '0';
					o_Flag_Div 			<= '0';
					if (i_Flag_Conv_I_F = '1') then
						Erro_Atual := i_Conv_I_F;
						i := i + 1;
					end if;
				
				elsif(i = 2) then								
					o_Flag_Conv_I_F 	<= '1';
					o_Conv_I_F			<= Controle_D;
					i := i + 1;
			
				elsif(i = 3) then
					o_Flag_Conv_I_F 	<= '0';
					if (i_Flag_Mult = '1') then
						Controle_I := i_Mult;
						i := i + 1;
					end if;
				
				elsif(i = 4) then
					o_Flag_Mult <= '1';
					o_Mult_A		<= PF_P;
					o_Mult_B		<= Erro_Atual;
					i := i + 1;
				
				elsif(i = 5) then
					o_Flag_Mult <= '0';
					if (i_Flag_Div = '1') then
						Controle_D := i_Div;
						i := i + 1;
					end if;	
			
				elsif(i = 6) then
					if (i_Flag_Conv_I_F = '1') then
						Aux_Controle_D := i_Conv_I_F;
						i := i + 1;
					end if;
				
				elsif(i = 7) then
					o_Flag_Conv_I_F 	<= '1';
					o_Conv_I_F			<= Aux_Controle_I;
					i := i + 1;
				
				elsif(i = 8) then
					o_Flag_Conv_I_F 	<= '0';
					o_Flag_Div 			<= '1';
					o_Div_A				<= Controle_I;
					o_Div_B				<= PF_2;
					i := i + 1;
				
				elsif(i = 9) then
					o_Flag_Div 			<= '0';
					if (i_Flag_Conv_I_F = '1') then
						Aux_Controle_I := i_Conv_I_F;
						i := i + 1;
					end if;
				
				elsif(i = 10) then
					if (i_Flag_Mult = '1') then
						Controle_P := i_Mult;
						Controle_PID := Controle_P;
						i := i + 1;
					end if;		
				
				elsif(i = 11) then
					o_Flag_Mult <= '1';
					o_Mult_A		<= Controle_D;
					o_Mult_B		<= Aux_Controle_D;
					i := i + 1;
				
				elsif(i = 12) then
					o_Flag_Mult <= '0';
					if (i_Flag_Div = '1') then
						Controle_I := i_Div;
						i := i + 1;
					end if;
				
				elsif(i = 13) then
					if (i_Flag_Mult = '1') then
						Controle_D := i_Mult;
						o_Flag_Sum_Sub <= '1';
						o_Sum_Sub 		<= '1';
						o_Sum_A 			<= Controle_PID;
						o_Sum_B 			<= Controle_D;
						i := i + 1;
					end if;
				
				elsif(i = 14) then
					o_Flag_Sum_Sub <= '0';
					o_Flag_Mult 	<= '1';
					o_Mult_A			<= Controle_I;
					o_Mult_B			<= Aux_Controle_I;
					i := i + 1;
				
				elsif(i = 15) then
					o_Flag_Mult <= '0';
					if (i_Flag_Sum_Sub = '1') then
						Controle_PID := i_Sum_Sub;
						i := i + 1;
					end if;
				
				elsif(i = 16) then	
					if (i_Flag_Mult = '1') then
						Controle_I := i_Mult;
						o_Flag_Sum_Sub <= '1';
						o_Sum_Sub 		<= '1';
						o_Sum_A 			<= Controle_I;
						o_Sum_B 			<= Soma_I;
						i := i + 1;
					end if;
				
				elsif(i = 17) then
					o_Flag_Sum_Sub <= '0';
					if (i_Flag_Sum_Sub = '1') then
						Controle_I := i_Sum_Sub;
						i := i + 1;
					end if;
				
				elsif(i = 18) then
					o_Flag_Sum_Sub <= '1';
					o_Sum_Sub 		<= '1';
					o_Sum_A 			<= Controle_PID;
					o_Sum_B 			<= Controle_I;
					i := i + 1;
				
				elsif(i = 19) then
					o_Flag_Sum_Sub <= '0';
					if (i_Flag_Sum_Sub = '1') then
						o_Conv_F_I <= i_Sum_Sub;
						o_Flag_Conv_F_I <= '1';
						i := i + 1;			
					end if;
			
				elsif(i = 20) then
					o_Flag_Conv_F_I <= '0';
					if (i_Flag_Conv_F_I = '1') then
						Controle_PID := i_Conv_F_I;
						o_Flag_PWM <= '1';
						o_PWM <= Controle_PID;
						i := i + 1;
					end if;
				
				elsif(i = 21) then
					o_Flag_PWM <= '0';
					calculo := '0';
				end if;
			end if;
		end if;
	end if;
  
  end process p_Unidade_Controle; 
end architecture RTL;