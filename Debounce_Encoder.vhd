library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Debounce_Encoder is
  port (
    i_Clk : in  std_logic;
    i_Enc : in  std_logic;
    o_Enc : out std_logic
    );
end entity Debounce_Encoder;
 
architecture RTL of Debounce_Encoder is
 
  -- Clock 50 MHz, Contador até 200
  constant c_DEBOUNCE_LIMIT : unsigned(9 downto 0) := to_unsigned(200,10);
 
  signal r_Count : unsigned(9 downto 0) := to_unsigned(0,10);
  signal r_State : std_logic := 'X';
 
begin
   -- Saída do módulo
  o_Enc <= r_State;
  
  p_Debounce : process (i_Clk) is
  begin
    if (i_Clk = '1' and i_Clk'event) then	
		-- Entrada for diferente ao estado e contador menor que limite
      if (i_Enc /= r_State and r_Count < c_DEBOUNCE_LIMIT) then
        r_Count <= r_Count + to_unsigned(1,10);
      -- Chegou ao limite, então muda valor da variável e reseta contador
      elsif (r_Count = c_DEBOUNCE_LIMIT) then
        r_State <= i_Enc;
        r_Count <= to_unsigned(0,10);
      -- Se são iguais, reseta contador
      else
        r_Count <= to_unsigned(0,10);
 
      end if;
    end if;
  end process p_Debounce; 
end architecture RTL;