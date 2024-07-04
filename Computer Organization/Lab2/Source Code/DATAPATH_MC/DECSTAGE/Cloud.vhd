----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:28:00 04/12/2024 
-- Design Name: 
-- Module Name:    Cloud - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Cloud is
    Port ( input : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0);
           control : in  STD_LOGIC_VECTOR (1 downto 0));
end Cloud;

architecture Behavioral of Cloud is

begin
	process(input,control)
	begin
	
		case control is
		
		-- Zero fill
		when "00" =>
			output <= (31 downto 16 => '0') & input; 
		-- Sign Extend
		when "01" =>
			output <= (31 downto 16 => input(15)) & input; 
		-- Zero Fill & Shift
		when "10" =>
			output <= input & (31 downto 16 => '0'); 
		-- Sign Extend and shift 2
		when others =>
		output <= std_logic_vector(shift_left(unsigned(resize(signed(input), 32)), 2));
		
		end case;
end process;

end Behavioral;

