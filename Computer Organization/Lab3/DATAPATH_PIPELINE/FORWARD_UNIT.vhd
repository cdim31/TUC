----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:07:01 06/16/2024 
-- Design Name: 
-- Module Name:    FORWARD_UNIT - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FORWARD_UNIT is
    Port ( Rs : in  STD_LOGIC_VECTOR (4 downto 0);
           Rt_Rd : in  STD_LOGIC_VECTOR (4 downto 0);
           Rd_exec_mem : in  STD_LOGIC_VECTOR (4 downto 0);
           Rd_mem_wb : in  STD_LOGIC_VECTOR (4 downto 0);
           WrEn_exec_mem : in  STD_LOGIC;
           WrEn_mem_wb : in  STD_LOGIC;
           forwardA : out  STD_LOGIC_VECTOR (1 downto 0);
           forwardB : out  STD_LOGIC_VECTOR (1 downto 0));
end FORWARD_UNIT;

architecture Behavioral of FORWARD_UNIT is

signal forwardA_sig : STD_LOGIC_VECTOR (1 downto 0);
signal forwardB_sig : STD_LOGIC_VECTOR (1 downto 0);

begin
process(Rs, Rt_Rd, Rd_exec_mem, Rd_mem_wb, WrEn_exec_mem, WrEn_mem_wb)
	begin
		-- Forward A
		if (WrEn_exec_mem = '1' and Rd_exec_mem /= "00000" and Rd_exec_mem = Rs) then
			forwardA_sig <= "10";
		elsif (WrEn_mem_wb = '1' and Rd_mem_wb /= "00000" and Rd_mem_wb = Rs) then
			forwardA_sig <= "01";
		else
			forwardA_sig <= "00";
		end if;
		
		-- Forward B
		if (WrEn_exec_mem = '1' and Rd_exec_mem /= "00000" and Rd_exec_mem = Rt_Rd) then
			forwardB_sig <= "10";
		elsif (WrEn_mem_wb = '1' and Rd_mem_wb /= "00000" and Rd_mem_wb = Rt_Rd) then
			forwardB_sig <= "01";
		else
			forwardB_sig <= "00";
		end if;
end process;
forwardA <= forwardA_sig;
forwardB <= forwardB_sig;
end Behavioral;

