----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:51:29 04/09/2024 
-- Design Name: 
-- Module Name:    Decoder - Behavioral 
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

entity DecoderMod is
    Port ( Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0));
end DecoderMod;

architecture Behavioral of DecoderMod is

begin
	process(Awr)
		begin
		
		if (Awr="00000") then
			Output <= "00000000000000000000000000000001"; --R0
			
		elsif (Awr="00001") then
			Output <= "00000000000000000000000000000010"; --R1
			
		elsif (Awr="00010") then
			Output <= "00000000000000000000000000000100"; --R2
			
		elsif (Awr="00011") then
			Output <= "00000000000000000000000000001000"; --R3
			
		elsif (Awr="00100") then
			Output <= "00000000000000000000000000010000"; --R4
			
		elsif (Awr="00101") then
			Output <= "00000000000000000000000000100000"; --R5
			
		elsif (Awr="00110") then
			Output <= "00000000000000000000000001000000"; --R6
			
		elsif (Awr="00111") then
			Output <= "00000000000000000000000010000000"; --R7
			
		elsif (Awr="01000") then
			Output <= "00000000000000000000000100000000"; --R8
			
		elsif (Awr="01001") then
			Output <= "00000000000000000000001000000000"; --R9
			
		elsif (Awr="01010") then
			Output <= "00000000000000000000010000000000"; --R10	
			
		elsif (Awr="01011") then
			Output <= "00000000000000000000100000000000"; --R11
			
		elsif (Awr="01100") then
			Output <= "00000000000000000001000000000000"; --R12
			
		elsif (Awr="01101") then
			Output <= "00000000000000000010000000000000"; --R13
			
		elsif (Awr="01110") then
			Output <= "00000000000000000100000000000000"; --R14
			
		elsif (Awr="01111") then
			Output <= "00000000000000001000000000000000"; --R15
			
		elsif (Awr="10000") then
			Output <= "00000000000000010000000000000000"; --R16
			
		elsif (Awr="10001") then
			Output <= "00000000000000100000000000000000"; --R17
			
		elsif (Awr="10010") then
			Output <= "00000000000001000000000000000000"; --R18
			
		elsif (Awr="10011") then
			Output <= "00000000000010000000000000000000"; --R19
			
		elsif (Awr="10100") then
			Output <= "00000000000100000000000000000000"; --R20
			
		elsif (Awr="10101") then
			Output <= "00000000001000000000000000000000"; --R21
			
		elsif (Awr="10110") then
			Output <= "00000000010000000000000000000000"; --R22
			
		elsif (Awr="10111") then
			Output <= "00000000100000000000000000000000"; --R23
			
		elsif (Awr="11000") then
			Output <= "00000001000000000000000000000000"; --R24
			
		elsif (Awr="11001") then
			Output <= "00000010000000000000000000000000"; --R25
			
		elsif (Awr="11010") then
			Output <= "00000100000000000000000000000000"; --R26
			
		elsif (Awr="11011") then
			Output <= "00001000000000000000000000000000"; --R27
			
		elsif (Awr="11100") then
			Output <= "00010000000000000000000000000000"; --R28
			
		elsif (Awr="11101") then
			Output <= "00100000000000000000000000000000"; --R29
			
		elsif (Awr="11110") then
			Output <= "01000000000000000000000000000000"; --R30
			
		else
			Output <= "10000000000000000000000000000000"; --R31 
			
		end if;
		
	end process;
			
end Behavioral;

