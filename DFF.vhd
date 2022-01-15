Library IEEE;
USE IEEE.Std_logic_1164.all;

entity DFlipFLop is 
   port(
      clk :in std_logic; 
	   reset: in std_logic;  
      D :in  std_logic; 
	   Q : out std_logic  
   );
end DFlipFLop;
architecture Behavioral of DFlipFLop is  
begin  
  process(clk,reset)
    begin 
     if(reset='1') then 
         Q <= '0';
     elsif(rising_edge(clk)) then
       Q <= D; 
     end if;      
  end process;  
end Behavioral; 