library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity baud_generator is
port ( 
  clk,reset: in std_logic;
  baud_select: in std_logic_vector(1 downto 0);
  baud_clk: out std_logic
);
end baud_generator;

architecture bhv of baud_generator is
signal count: integer:=1;
signal tmp1 : std_logic := '0';
signal clk_counter: integer;
begin

baud_selector: process (baud_select)
begin
 case baud_select is       --        baud rates
 when "00"                       => clk_counter <= 434; -- 115.200 -> 50000000/115200 = 434
 when "01"                       => clk_counter <= 868; -- 57.600
 when "10"                       => clk_counter <= 1302; -- 38.400
 when "11"                       => clk_counter <= 5;    -- test
 when others                     => clk_counter <= 868; -- 57.600
 end case;
 end process baud_selector;
 
process(clk,reset)
begin
  if(reset = '1') then
    count <= 1;
    tmp1 <= '0';
  elsif(clk'event and clk='1') then
    count <= count+1;
	 if (count = clk_counter) then
      tmp1 <= NOT tmp1;
      count <= 1;
    end if;
  end if;
baud_clk <= tmp1;
end process;
end bhv;