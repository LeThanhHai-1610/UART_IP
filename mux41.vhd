library ieee;
use ieee.std_logic_1164.all;

entity mux41 is
port(
	dataout 		     : out  std_logic;
	sel              : in std_logic_vector(1 downto 0);
	in1,in2,in3,in4  : in std_logic
);
end entity;
architecture rtl of mux41 is

begin
-- body --
process(sel,in1,in2,in3,in4)
begin
case(sel) is
when "00" => dataout <= in1;
when "01" => dataout <= in2;
when "10" => dataout <= in3;
when "11" => dataout <= in4;
when others =>dataout <= in1;
end case;
end process;
end rtl;