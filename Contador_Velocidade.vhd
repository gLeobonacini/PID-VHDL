library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Contador_Velocidade is
  port (
	 i_Clk : in  std_logic;
    i_Mov : in  std_logic;
    i_Dir : in  std_logic;
	 o_Flag: out std_logic;
    o_Vel : out signed(31 downto 0)
    );
end entity Contador_Velocidade;
 
architecture RTL of Contador_Velocidade is
 
  -- Clock 50 MHz, Contador até 5000000 (100ms)
  constant c_VELOCIDADE_LIMIT : unsigned(31 downto 0) := to_unsigned(5000000,32);
 
  signal v_Count  : unsigned(31 downto 0) := to_unsigned(0,32);
  signal vel		: signed(31 downto 0) := to_signed(0,32);
 
begin
  
  p_Contador : process (i_Clk) is
  begin
  if (i_Clk = '1' and i_Clk'event) then
		v_Count <= v_Count + to_unsigned(1,32);
		-- Verifica se está em movimento
      if (i_Mov = '1') then
			-- Incremento se a direção for 1
			if (i_Dir = '1' and v_count < c_VELOCIDADE_LIMIT) then				
				Vel <= Vel + to_signed(1,32);
			-- Decremento se a direção for 0
			elsif (i_Dir = '0' and v_count < c_VELOCIDADE_LIMIT) then
				Vel <= Vel + to_signed(-1,32);
			end if;
		end if;
		if (v_count >= c_VELOCIDADE_LIMIT) then
			o_Vel <= vel;
			o_Flag <= '1';
			v_Count <= to_unsigned(0,32);
			vel <= to_signed(0,32);
		else
			o_Flag <= '0';
		end if;
	end if;
	
	end process p_Contador; 
end architecture RTL;