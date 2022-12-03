library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Modulador_Servo is
  port (
    i_Clk 		: in  std_logic;
	 i_Flag		: in  std_logic;
    i_servo 	: in  signed (31 downto 0);
    o_modulada : out std_logic
    );
end entity Modulador_Servo;
 
architecture RTL of Modulador_Servo is
 
  -- Clock 50 MHz, Contador até 1000000
  constant CICLO_SERVO : signed(31 downto 0) := to_signed(10,32);
  signal DUTY_ALTO : signed(31 downto 0) := to_signed(0,32);
  signal r_State : std_logic := '0';
 
begin
   -- Saída do módulo
  o_modulada <= r_State;
  
  p_Modular : process (i_Clk) is
  variable r_Count 		: signed(31 downto 0) 	:= to_signed(0,32);
  begin
    if (i_Clk = '1' and i_Clk'event) then
		if (i_Flag = '1') then
			DUTY_ALTO <= i_servo;
			r_Count := to_signed(0,32);
		else
			r_Count := r_Count + to_signed(1,32);
			-- Verifica se chegou no máximo do valor em alto
			if (r_Count < DUTY_ALTO) then
				r_State <= '1';
			-- Restante do ciclo no valor baixo
			elsif (r_Count < CICLO_SERVO) then
				r_State <= '0';
			-- Reseta contador para o novo ciclo
			else
				r_Count := to_signed(0,32);
			end if;
		end if;
    end if;
  end process p_Modular; 
end architecture RTL;