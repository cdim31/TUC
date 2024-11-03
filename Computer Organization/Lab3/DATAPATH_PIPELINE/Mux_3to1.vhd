----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:24:55 04/12/2024 
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

entity Mux_3to1 is
    Port ( in0 : in  STD_LOGIC_VECTOR (31 downto 0);
           in1 : in  STD_LOGIC_VECTOR (31 downto 0);
			  in2 : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0)
			 );
end Mux_3to1;

architecture Behavioral of Mux_3to1 is

begin
process(in0, in1, in2, sel)
		begin
		if (sel = "00") then
			output <= in0;
		elsif (sel = "01") then
			output <= in1;
		else
			output <= in2;
		end if;
end process;

end Behavioral;