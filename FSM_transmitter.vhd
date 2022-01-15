library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM_transmitter is 
port
(
	start_sig    : in std_logic;							 -- tell transmitter to start sending data
	baud_clk     : in std_logic;							 -- set the baud rate
	reset        : in std_logic;
	--ok           : in std_logic;							 -- receive to know finishing transmit
	--shift_done   : in std_logic;							 -- receive to know 8-bit data is shifted 
	shift_enb    : out std_logic;							 -- allow shift_register works
	busy			 : out std_logic;							 -- notify Transmitter is working (is transmitting)
	done         : out std_logic;							 -- notify Transmitter finishes the whole transmition)
	sel          : out std_logic_vector(1 downto 0)  -- control Mux 4-1
);
end entity;

architecture rtl of FSM_transmitter is
-- declare the states of FSM using enumerated type
type FSM_state is (idle,start,shift,parity,stop);
-- declare signals of FSM
signal current_state, next_state: FSM_state;
-- use Gray code to encode
attribute encode: string;
attribute encode of FSM_state: type is "gray";
signal w_count : std_logic_vector(3 downto 0);
signal w_busy, w_shift_finish, w_done, w_pre_stop  : std_logic;

begin
--body
w_shift_finish <= '1' when (w_count = "0111") else '0';
--w_pre_stop     <= '1' when (w_count = "1000") else '0';
busy           <= w_busy;
done           <= w_done;
update_next_state: process (current_state,w_busy,start_sig,w_shift_finish)
begin
  case current_state is
    when idle =>
	   if start_sig = '0' then	
		  next_state <= idle ;
		else next_state <= start ;
		end if;
	 when start =>
		  next_state <= shift ;
	 when shift =>
	   if w_shift_finish = '0' then	
		  next_state <= shift ;
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

update_output: process (current_state,w_busy,start_sig,w_shift_finish)
begin
  if (reset = '1') then
    shift_enb <= '0';
	 w_count <=  (others => '0');
	 w_done <= '0';
	 w_busy <= '0';
	 sel <= "11"     ;   -- stop
  elsif rising_edge(baud_clk) then
   case current_state is
    when idle =>
	   w_count <=  (others => '0');
	   shift_enb <= '0';
		w_done <= '0';
	   sel <= "11"     ; -- stop
	 when start =>
	   w_busy <= '1';
	   shift_enb <= '0';
		w_done <= '0';
	   sel <= "00"     ; -- start 
	 when shift =>
	   w_busy <= '1';
	   w_count <=  w_count + 1;
	   shift_enb <= '1';
		w_done <= '0';
	   sel <= "01"     ; -- shift 
	 when parity =>
	   w_busy <= '1';
	   shift_enb <= '0';
		--w_count <=  w_count + 1;
		w_done <= '0';
	   sel <= "10"     ; -- parity
	 when stop =>
	   w_busy <= '0';
	   shift_enb <= '0';
		w_done <= '1';
	   sel <= "11"     ; -- stop 
	end case;	
  end if;
end process;
end rtl;