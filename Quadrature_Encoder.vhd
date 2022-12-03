library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Quadrature_Encoder is
  port (
    i_Clk	: in  std_logic;
    i_A 	 	: in  std_logic;
    i_B 	 	: in  std_logic;
	 o_Mov   : out std_logic;
    o_Dir 	: out std_logic	 
    );
end entity Quadrature_Encoder;
 
architecture RTL of Quadrature_Encoder is 
  signal Q1 : std_logic := '0';
  signal Q2 : std_logic := '0';
  signal Q3 : std_logic := '0';
  signal Q4 : std_logic := '0';
begin

  O_Mov <= not(not(Q1 xor Q2) and not(Q3 xor Q4));
  o_Dir <= Q2 xor Q3;

  p_FF_D1 : process (i_Clk) is
  begin
    if (i_Clk = '0' and i_Clk'event) then	
		Q1 <= i_A;
		Q2 <= Q1;
    end if;
  end process p_FF_D1; 
  
  p_FF_D2 : process (i_Clk) is
  begin
    if (i_Clk = '0' and i_Clk'event) then	
		Q3 <= i_B;
		Q4 <= Q3;
    end if;
  end process p_FF_D2;
  
end architecture RTL;