----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:39:18 03/23/2024 
-- Design Name: 
-- Module Name:    lab0 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           AddrWr : in  STD_LOGIC_VECTOR (4 downto 0);
           AddrRd : in  STD_LOGIC_VECTOR (4 downto 0);
			  AddrRdOut : out STD_LOGIC_VECTOR (4 downto 0);
			  AddrWrOut : out STD_LOGIC_VECTOR (4 downto 0);
           Wr : in  STD_LOGIC;
           Rd : in  STD_LOGIC;
			  --NumberIN : in  STD_LOGIC_VECTOR (15 downto 0);
           --NumberOUT : out  STD_LOGIC_VECTOR (15 downto 0);
           Valid : out  STD_LOGIC;
			  WrEnable : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
type state is(Initial, Writing, Reading, RdWr);
signal Moore_state : state;




begin
process (CLK,RST)
	begin
	if (RST = '1') then 
		Moore_state <= Initial;
	elsif falling_edge(CLK) then
		case Moore_state is
			when Initial =>
			
				if Wr = '1' and Rd = '0' then
							Moore_state <= Writing;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '0' and Rd = '1' then			
							Moore_state <= Reading;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '1' and Rd = '1' then
							Moore_state <= RdWr;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				else
							Moore_state <= Initial;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				end if;
			
			when Writing =>
	
			
				if Wr = '1' and Rd = '0' then
							Moore_state <= Writing;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '0' and Rd = '1' then			
							Moore_state <= Reading;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '1' and Rd = '1' then
							Moore_state <= RdWr;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				else
							Moore_state <= Initial;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				end if;
			
			when Reading =>
			
				
				if Wr = '1' and Rd = '0' then
							Moore_state <= Writing;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '0' and Rd = '1' then			
							Moore_state <= Reading;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '1' and Rd = '1' then
							Moore_state <= RdWr;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				else
							Moore_state <= Initial;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				end if;
				
			when RdWr =>
		
			
				if Wr = '1' and Rd = '0' then
							Moore_state <= Writing;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '0' and Rd = '1' then			
							Moore_state <= Reading;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				elsif Wr = '1' and Rd = '1' then
							Moore_state <= RdWr;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				else
							Moore_state <= Initial;
							AddrRdOut <= AddrRd;
							AddrWrOut <= AddrWr;
				end if;
		end case;
		
	end if;
	
end process;


Valid <= '1' when Moore_state = Reading or Moore_state = RdWr else '0';
WrEnable <= '1' when Moore_state = Writing or Moore_state = RdWr else '0';
end Behavioral;
				