----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:48:28 06/19/2024 
-- Design Name: 
-- Module Name:    Mux2bit - Behavioral 
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

entity Mux2bit is
    Port ( in0 : in  STD_LOGIC_VECTOR (1 downto 0);
           in1 : in  STD_LOGIC_VECTOR (1 downto 0);
           sel : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (1 downto 0));
end Mux2bit;

architecture Behavioral of Mux2bit is

begin
process(in0, in1, sel)
		begin
		if (sel = '0') then
			output <= in0;
		else 
			output <= in1;
		end if;
end process;

end Behavioral;

