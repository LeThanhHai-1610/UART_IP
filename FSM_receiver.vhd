library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM_receiver is 
port
(
	start_sig    : in std_logic;							 -- tell receiver to start receiving sending data
	baud_clk     : in std_logic;							 -- set the baud rate
	reset        : in std_logic;
   Wr_en			 : out std_logic;							 -- allow Write to SIPO
	reg_Wr_en	 : out std_logic;
	done         : out std_logic							 -- notify Receiver finishes the whole reception)
);
end entity;

architecture rtl of FSM_receiver is
-- declare the states of FSM using enumerated type
type FSM_state is (idle,receive,parity,stop);
-- declare signals of FSM
signal current_state, next_state: FSM_state;
-- use Gray code to encode
attribute encode: string;
attribute encode of FSM_state: type is "gray";
signal w_count : std_logic_vector(3 downto 0);
signal w_receive_finish, w_start, w_done, w_Wren : std_logic;

begin
--body
w_receive_finish <= '1' when (w_count = "0111") else '0';
--Wr_en           <= w_Wren;
--done           <= w_done;
update_next_state: process (current_state,start_sig,w_receive_finish)
begin
  case current_state is
    when idle =>
	   if start_sig = '1' then	
		  next_state <= receive; 
		else next_state <= idle;
		end if;
	 --when start =>
		  --next_state <= receive ;
	 when receive =>
	   if w_receive_finish = '0' then	
		  next_state <= receive ;
		else next_state <= parity ;
		end if;
	 when parity =>
	   next_state <= stop ;
	 when stop =>
	   --if w_pre_stop = '1' then	
		  next_state <= idle ;
		--else next_state <= stop ;
		--end if;
  end case;
end process;

update_current_state: process (baud_clk,reset)
begin
  if (reset = '1') then
    current_state <= idle;
  elsif rising_edge(baud_clk) then
    current_state <= next_state;
  end if;
end process;

update_output: process (current_state,start_sig,w_receive_finish)
begin
  if (reset = '1') then
	 w_count <=  (others => '0');
	 done <= '0';
	 Wr_en <= '0';
	 reg_Wr_en <= '0';
  elsif rising_edge(baud_clk) then
   case current_state is
    when idle =>
	   w_count <=  (others => '0');
	   Wr_en <= '1';
		done <= '0';
		reg_Wr_en <= '0';
	 when receive =>
	   w_count <=  w_count + 1;
		done <= '0';
	   Wr_en <= '1'; 
		reg_Wr_en <= '0';
	 when parity =>
		--w_count <=  w_count + 1;
		done <= '0';
	   Wr_en <= '0';
		reg_Wr_en <= '1';
	 when stop =>
		done <= '1';
	   Wr_en <= '0';
		reg_Wr_en <= '0';
	end case;	
  end if;
end process;
end rtl;