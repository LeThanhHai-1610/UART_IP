library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_transmitter is 
port
(
	data_trans    : in std_logic_vector(7 downto 0);
	start_control : in std_logic;
	baud_clk      : in std_logic;
	reset, error  : in std_logic;
	Tx            : out std_logic;
	busy          : out std_logic;
   done			  : out std_logic
);
end entity;

architecture rtl of UART_transmitter is
signal w_shift_enb, w_databit, w_even_parity_bit : std_logic;
signal w_sel: std_logic_vector(1 downto 0);

component parity_generator is
port
(
  tx_data : in std_logic_vector(7 downto 0);
  even_parity_bit : out std_logic
);
end component;

component shift_register is
port
(
   clk  		 : in std_logic;	
	reset     : in std_logic;	
	shift_enb : in std_logic;
	datain    : in std_logic_vector(7 downto 0);
	dataout   : out std_logic
);
end component;

component FSM_transmitter is
port
(
   start_sig    : in std_logic;							 -- tell transmitter to start sending data
	baud_clk     : in std_logic;							 -- set the baud rate
	reset        : in std_logic;
	shift_enb    : out std_logic;							 -- allow shift_register works
	busy			 : out std_logic;							 -- notify Transmitter is working (is transmitting)
	done         : out std_logic;							 -- notify Transmitter finishes the whole transmition)
	sel          : out std_logic_vector(1 downto 0)  -- control Mux 4-1
);
end component;

component mux41 is
port
(
   dataout 		     : out  std_logic;
	sel              : in std_logic_vector(1 downto 0);
	in1,in2,in3,in4  : in std_logic
);
end component;

begin
  FSM:    FSM_transmitter  port map (start_control,baud_clk,reset,w_shift_enb,busy,done,w_sel);
  PISO:   shift_register   port map (baud_clk,reset,w_shift_enb,data_trans,w_databit);
  parity: parity_generator port map (data_trans,w_even_parity_bit);
  Mux:    mux41   			port map (Tx,w_sel,'0',w_databit,w_even_parity_bit,'1');
end rtl;
