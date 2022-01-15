library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

entity UART_IP is
port
(
	clk        	      : in    	std_logic;
	CS						: in    	std_logic;
	WR_en					: in    	std_logic;
	data  				: in		std_logic_vector(7 downto 0);
	reset        		: in    	std_logic;
	addr 					: in     std_logic_vector(2 downto 0);
	Tx            		: out std_logic;
	busy          		: out std_logic;
	baud_clk				: buffer std_logic;
   done,done_temp		: buffer std_logic	
);

end entity;

architecture rtl of UART_IP is

type mem is array (0 to 7) of std_logic_vector(7 downto 0);
signal mem1, mem2: mem;
signal w_start1,w_q1,w_baud_select1,ww_done: std_logic_vector(7 downto 0);
signal w_start, w_start0, w_baud_clk,w_done : std_logic;
signal w_baud_select: std_logic_vector(1 downto 0);

component UART_transmitter is
  port
  (    
   data_trans    : in std_logic_vector(7 downto 0);
	start_control : in std_logic;
	baud_clk      : in std_logic;
	reset         : in std_logic;
	Tx            : out std_logic;
	busy          : out std_logic;
   done			  : out std_logic
  );
end component;

component baud_generator is
  port
  (    
   clk,reset: in std_logic;
   baud_select: in std_logic_vector(1 downto 0);
   baud_clk: out std_logic
  );
end component;

begin

process(clk,reset)
begin
    if (reset = '1') then mem1 <= (others => "00000000");
    elsif rising_edge (clk) and (WR_en = '1') and (CS = '1') then
        mem1 (to_integer(unsigned(addr))) <= data;
		  --mem1(3) <= "0000000" & done;
    end if;
w_start1 <= mem1(2);
w_start <= w_start1(0);
    if rising_edge (clk) and (w_start1(0) = '1') then
        w_q1 <= mem1(0);
    end if;
end process;
w_baud_select1 <= mem1(1);
w_baud_select <= w_baud_select1(1 downto 0);
  
clock: baud_generator port map (clk,reset,w_baud_select,w_baud_clk);
Transmitter: UART_transmitter port map (w_q1,w_start,w_baud_clk,reset,Tx,busy,w_done);

baud_clk <= w_baud_clk;

process(baud_clk,reset)
begin
    if (reset = '1') then mem2 <= (others => "00000000");
    elsif rising_edge (baud_clk) then
		mem2(0) <= "0000000" & w_done;
    end if;
end process;

process(baud_clk,reset)
begin
    if rising_edge (baud_clk) then
		ww_done <= mem2(0) ;
    end if;
end process;
done <=  w_done;
done_temp <= ww_done(0);


end rtl;

