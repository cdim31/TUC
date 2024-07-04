----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:05:41 04/10/2024 
-- Design Name: 
-- Module Name:    PC_Register - Behavioral 
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

entity PC_Register is
    Port ( Clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
           WrEn : in  STD_LOGIC;
           Input : in  STD_LOGIC_VECTOR (31 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0));
end PC_Register;

architecture Behavioral of PC_Register is
signal out_sig : STD_LOGIC_VECTOR (31 downto 0);

begin
	process(Clk,Rst,WrEn)
	
	begin
		if rising_edge(Clk) then
			if(Rst = '1') then
				out_sig <= x"00000000";
			else
				if (WrEn = '1') then
					out_sig <= Input;
				else
					out_sig <= out_sig;
					
				end if;
			end if;
		end if;
	end process;
			
Output <= out_sig;


end Behavioral;

