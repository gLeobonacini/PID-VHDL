library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Modulador_PWM is
  port (
    i_Clk 		: in  std_logic;
	 i_Flag		: in  std_logic;
    i_pwm	 	: in  signed (31 downto 0);
    o_dir 		: out std_logic;
	 o_modulada : out std_logic
    );
end entity Modulador_PWM;
 
architecture RTL of Modulador_PWM is
 
  -- Clock 50 MHz, Contador até 500000 (1kHz)
  constant CICLO_SERVO 	: unsigned(31 downto 0)	:= to_unsigned(50000,32);
  signal DUTY_ALTO 		: unsigned(31 downto 0) := to_unsigned(0,32);
 
begin
  
  p_Modular_PWM : process (i_Clk) is
  
  variable r_Count 		: unsigned(31 downto 0) 	:= to_unsigned(0,32);
  
  begin
    if (i_Clk = '1' and i_Clk'event) then
		if (i_Flag = '1') then
			DUTY_ALTO <= unsigned(i_pwm);
			r_Count := to_unsigned(0,32);
			if(i_pwm < 0) then
				o_dir <= '0';			
			else
				o_dir <= '1';
			end if;		
			
		else
			r_Count := r_Count + to_unsigned(1,32);
			-- Verifica se chegou no máximo do valor em alto
			if (r_Count < DUTY_ALTO) then
				o_modulada <= '1';
			-- Restante do ciclo no valor baixo
			elsif (r_Count < CICLO_SERVO) then
				o_modulada <= '0';
			-- Reseta contador para o novo ciclo
			else
				r_Count := to_unsigned(0,32);
			end if;
		end if;
    end if;
  end process p_Modular_PWM; 
end architecture RTL;