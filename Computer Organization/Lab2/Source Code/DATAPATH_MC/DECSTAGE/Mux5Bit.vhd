----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:57 04/12/2024 
-- Design Name: 
-- Module Name:    Mux5Bit - Behavioral 
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

entity Mux5Bit is
    Port ( in0 : in  STD_LOGIC_VECTOR (4 downto 0);
           in1 : in  STD_LOGIC_VECTOR (4 downto 0);
           output : out  STD_LOGIC_VECTOR (4 downto 0);
           sel : in  STD_LOGIC);
end Mux5Bit;

architecture Behavioral of Mux5Bit is

begin
	
	process(sel,in0,in1)
	begin
	
		if(sel = '0') then
			output <= in0;
		else
			output <= in1;
			
		end if;
		
	end process;

end Behavioral;

