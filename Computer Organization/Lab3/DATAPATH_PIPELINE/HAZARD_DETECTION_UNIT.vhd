----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:38:30 06/19/2024 
-- Design Name: 
-- Module Name:    HAZARD_DETECTION_UNIT - Behavioral 
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

entity HAZARD_DETECTION_UNIT is
    Port ( Rs : in  STD_LOGIC_VECTOR (4 downto 0);
           Rt : in  STD_LOGIC_VECTOR (4 downto 0);
           Rt_DEC_EXEC : in  STD_LOGIC_VECTOR (4 downto 0);
           MEM_WrEn : in  STD_LOGIC;
           control_out : out  STD_LOGIC;
           PC_LdEn_hu : out  STD_LOGIC;
           WrEn_IF_DEC : out  STD_LOGIC);
end HAZARD_DETECTION_UNIT;

architecture Behavioral of HAZARD_DETECTION_UNIT is

begin
process(Rs, Rt, Rt_DEC_EXEC, MEM_WrEn)
begin
	if (MEM_WrEn = '1' and (Rs = Rt_DEC_EXEC or Rt = Rt_DEC_EXEC)) then
		control_out <= '1';
		PC_LdEn_hu <= '0';
		WrEn_IF_DEC <= '0';
	else
		control_out <= '0';
		PC_LdEn_hu <= '1';
		WrEn_IF_DEC <= '1';
	end if;
end process;

end Behavioral;

