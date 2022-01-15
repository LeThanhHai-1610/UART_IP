library ieee;
use ieee.std_logic_1164.all;
entity shift_register is -- 8 parallel in, serial out
port
(
   clk  		 : in std_logic;	
	reset     : in std_logic;	
	shift_enb : in std_logic;
	datain    : in std_logic_vector(7 downto 0);
	dataout   : out std_logic
);
end entity;

architecture rtl of shift_register is
component DFlipFLop is
  port
  (    
    clk :in std_logic; 
	 reset: in std_logic;  
    D :in  std_logic; 
	 Q : out std_logic
  );
end component;
signal Q0,Q1,Q2,Q3,Q4,Q5,Q6: std_logic;

begin
  DFlipFLop1: DFlipFLop port map (clk,reset,datain(7) and not(shift_enb),Q0);
  DFlipFLop2: DFlipFLop port map (clk,reset,(Q0 and (shift_enb)) or (datain(6) and not(shift_enb)),Q1);
  DFlipFLop3: DFlipFLop port map (clk,reset,(Q1 and (shift_enb)) or (datain(5) and not(shift_enb)),Q2);
  DFlipFLop4: DFlipFLop port map (clk,reset,(Q2 and (shift_enb)) or (datain(4) and not(shift_enb)),Q3); 
  DFlipFLop5: DFlipFLop port map (clk,reset,(Q3 and (shift_enb)) or (datain(3) and not(shift_enb)),Q4);
  DFlipFLop6: DFlipFLop port map (clk,reset,(Q4 and (shift_enb)) or (datain(2) and not(shift_enb)),Q5);
  DFlipFLop7: DFlipFLop port map (clk,reset,(Q5 and (shift_enb)) or (datain(1) and not(shift_enb)),Q6);
  DFlipFLop8: DFlipFLop port map (clk,reset,(Q6 and (shift_enb)) or (datain(0) and not(shift_enb)),dataout);
end rtl;