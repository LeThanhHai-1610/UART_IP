LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SIPO IS
--GENERIC (n: NATURAL := 8);
PORT 
(
  Serin, Clk, Wr_en : IN STD_LOGIC;
  Q : OUT STD_LOGIC_VECTOR (8 downto 0)
);
END SIPO;

ARCHITECTURE shiftreg OF SIPO IS
SIGNAL reg : STD_LOGIC_VECTOR(8 downto 0);

BEGIN
PROCESS (Clk)
BEGIN
IF rising_edge(Clk) and (Wr_en = '1') THEN
  reg <= Serin & reg(8 downto 1);
END IF;
END PROCESS;
Q <= reg;
END shiftreg;