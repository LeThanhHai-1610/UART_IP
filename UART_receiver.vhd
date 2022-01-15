library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_receiver is
port
(
	--clk           : in std_logic;
	baud_clk      : in std_logic;
	reset         : in std_logic;
	Rx            : in std_logic;
	busy          : in std_logic;
	data_trans    : out std_logic_vector(7 downto 0);	
	error         : buffer std_logic;
	done_temp     : out std_logic;
   done			  : buffer std_logic
);
end entity;

architecture rtl of UART_receiver is
signal w_rise,w_fall,w_Wr_en,w_reg_Wr_en,w_start,w_even_parity_bit,w_done,w_error : std_logic;
signal w_data_trans    : std_logic_vector(8 downto 0);
signal ww_data_trans    : std_logic_vector(8 downto 0);
type mem is array (0 to 7) of std_logic_vector(7 downto 0);
signal ww_done,ww_error : std_logic_vector(7 downto 0);
signal mem2: mem;

component parity_generator is
port
(
  tx_data : in std_logic_vector(7 downto 0);
  even_parity_bit : out std_logic
);
end component;

component SIPO is
port
(
  Serin, Clk, Wr_en : IN STD_LOGIC;
  Q : OUT STD_LOGIC_VECTOR (8 downto 0)
);
end component;

component FSM_receiver is
port
(
	start_sig    : in std_logic;							 -- tell receiver to start receiving sending data
	baud_clk     : in std_logic;							 -- set the baud rate
	reset        : in std_logic;
   Wr_en			 : out std_logic;							 -- allow Write to SIPO
	reg_Wr_en	 : out std_logic;
	done         : out std_logic							 -- notify Receiver finishes the whole reception)
);
end component;

--component RisingEdgeDetector is
--  port
--  (    
--   clk      : in std_logic;
--   d        : in std_logic;
--   rise_edge: out std_logic	
--  );
--end component;
--
--component FallingEdgeDetector is
--  port
--  (    
--   clk      : in std_logic;
--   d        : in std_logic;
--   fall_edge: out std_logic	
--  );
--end component;

begin
  --Fall:  FallingEdgeDetector port map (clk,Rx,w_rise);
  --Rise:  RisingEdgeDetector  port map (clk,busy,w_fall);
  FSM:   FSM_receiver        port map (not Rx,baud_clk,reset,w_Wr_en,w_reg_Wr_en,w_done);
  SIPO1: SIPO   				  port map (Rx,baud_clk,w_Wr_en,w_data_trans);
  --
  
process(baud_clk,reset)
begin
    if rising_edge (baud_clk) and (w_reg_Wr_en = '1') then
        ww_data_trans <= w_data_trans(8 downto 0);
		  --error <= w_data_trans(8) xor w_even_parity_bit ;
    end if;
end process;
 data_trans <= ww_data_trans(7 downto 0);
 parity: parity_generator   port map (ww_data_trans(7 downto 0),w_even_parity_bit);
 w_error <= ww_data_trans(8) xor w_even_parity_bit ;

process(baud_clk,reset)
begin
    if (reset = '1') then mem2 <= (others => "00000000");
    elsif rising_edge (baud_clk) then
		mem2(0) <= "0000000" & w_done;
		mem2(1) <= "0000000" & w_error;
    end if;
end process;

process(baud_clk,reset)
begin
    if rising_edge (baud_clk) then
		ww_done <= mem2(0) ;
		ww_error <= mem2(1);
    end if;
end process;
done <=  w_done;
done_temp <= ww_done(0);
error <= ww_error(0);
end rtl;
