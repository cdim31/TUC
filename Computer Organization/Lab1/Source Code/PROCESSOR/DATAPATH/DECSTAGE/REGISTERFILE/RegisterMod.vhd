----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:01:54 04/09/2024 
-- Design Name: 
-- Module Name:    Register - Behavioral 
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

entity RegisterMod is
    Port ( Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0);
           WE : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end RegisterMod;

architecture Behavioral of RegisterMod is
signal dataout : STD_LOGIC_VECTOR (31 downto 0);

begin
	process(CLK,RST,WE)
	
	begin
		if rising_edge(CLK) then
			if(RST = '1') then
				dataout <= x"00000000";
			else
				if (WE = '1') then
					dataout <= Data;
				else
					dataout <= dataout;
					
				end if;
			end if;
		end if;
	end process;
			
Dout <= dataout;

end Behavioral;

