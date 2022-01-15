library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.xor_reduce;

entity parity_generator is 
port
(
	tx_data : in std_logic_vector(7 downto 0);
	even_parity_bit : out std_logic
);
end entity;

architecture rtl of parity_generator is

begin
	 even_parity_bit <= xor_reduce(tx_data);
end rtl;