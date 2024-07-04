----------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date:    16:36:30 04/08/2024
-- Design Name:
-- Module Name:    ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL; -- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_SIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           Op : in  STD_LOGIC_VECTOR (3 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0);
           Zero : out  STD_LOGIC;
           Cout : out  STD_LOGIC;
           Ovf : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

	--The OutputTemp that stores Overflowed
	signal OutputTemp : STD_LOGIC_VECTOR (31 downto 0);
	signal OutExended : STD_LOGIC_VECTOR (32 downto 0):= (others => '0');

begin
	
		--Arithmetic and Logical Operations Process
process(A,B,Op)
begin

	case Op is

	when "0000" =>
		OutputTemp <= A+B;
		
	when "0001" =>
		OutputTemp <= A-B;
		
	when "0010" =>
		OutputTemp <= A and B;
		
	when "0011" =>
		OutputTemp <= A or B;
		
	when "0100" =>
		OutputTemp <= not A;
		
	when "1000" =>
		OutputTemp <= std_logic_vector(shift_right(signed(A), 1));
		
	when "1001" =>
		OutputTemp <= A(30 DOWNTO 0) & '0';
		
	when "1010" =>
		OutputTemp <= '0' & A(31 DOWNTO 1);
		
	when "1100" =>
		OutputTemp <= std_logic_vector(signed(A) rol 1);
		
	when "1101" =>
		OutputTemp <= std_logic_vector(signed(A) ror 1);
		
	when others =>

	end case;

end process;

--Status Flags Process
process(A,B,Op,OutputTemp)
begin

	if to_integer(unsigned(OutputTemp)) = 0 then
		Zero <= '1';
	else
		Zero <= '0';
	end if;

	--Overflow can occur in Addition or in Subtraction
	case Op is

	when "0000" =>
		if ((A(31) = B(31)) and (A(31) /=  OutputTemp(31))) then --MSB must be the same
			Ovf <= '1';
		else
			Ovf <= '0';
		end if;

		-- Carry out
		OutExended <= ((A(31) & A) + (B(31) & B));
		Cout <= OutExended(32);
		

	when "0001" =>
		if ((A(31) /= B(31)) and (A(31) /=  OutputTemp(31))) then --In Case of MSB of a,b not equal, then overflow we have when Out MSB ~= A MSB
			Ovf <= '1';
		else
			Ovf <= '0';
		end if;

		-- Carry out
		OutExended <= (A(31) & A) - (B(31) & B);
		Cout <= OutExended(32);

		when others =>
			Ovf <= '0';
			Cout <= '0';

	end case;

end process;

Output <= OutputTemp;

end Behavioral;