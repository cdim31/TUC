----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:34:09 04/09/2024 
-- Design Name: 
-- Module Name:    MUX_32 - Behavioral 
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

entity MUX_32 is
    Port ( in0 : in  STD_LOGIC_VECTOR (31 downto 0);
           in1 : in  STD_LOGIC_VECTOR (31 downto 0);
           in2 : in  STD_LOGIC_VECTOR (31 downto 0);
           in3 : in  STD_LOGIC_VECTOR (31 downto 0);
           in4 : in  STD_LOGIC_VECTOR (31 downto 0);
           in5 : in  STD_LOGIC_VECTOR (31 downto 0);
           in6 : in  STD_LOGIC_VECTOR (31 downto 0);
           in7 : in  STD_LOGIC_VECTOR (31 downto 0);
           in8 : in  STD_LOGIC_VECTOR (31 downto 0);
           in9 : in  STD_LOGIC_VECTOR (31 downto 0);
           in10 : in  STD_LOGIC_VECTOR (31 downto 0);
           in11 : in  STD_LOGIC_VECTOR (31 downto 0);
           in12 : in  STD_LOGIC_VECTOR (31 downto 0);
           in13 : in  STD_LOGIC_VECTOR (31 downto 0);
           in14 : in  STD_LOGIC_VECTOR (31 downto 0);
           in15 : in  STD_LOGIC_VECTOR (31 downto 0);
           in16 : in  STD_LOGIC_VECTOR (31 downto 0);
           in17 : in  STD_LOGIC_VECTOR (31 downto 0);
           in18 : in  STD_LOGIC_VECTOR (31 downto 0);
           in19 : in  STD_LOGIC_VECTOR (31 downto 0);
           in20 : in  STD_LOGIC_VECTOR (31 downto 0);
           in21 : in  STD_LOGIC_VECTOR (31 downto 0);
           in22 : in  STD_LOGIC_VECTOR (31 downto 0);
           in23 : in  STD_LOGIC_VECTOR (31 downto 0);
           in24 : in  STD_LOGIC_VECTOR (31 downto 0);
           in25 : in  STD_LOGIC_VECTOR (31 downto 0);
           in26 : in  STD_LOGIC_VECTOR (31 downto 0);
           in27 : in  STD_LOGIC_VECTOR (31 downto 0);
           in28 : in  STD_LOGIC_VECTOR (31 downto 0);
           in29 : in  STD_LOGIC_VECTOR (31 downto 0);
           in30 : in  STD_LOGIC_VECTOR (31 downto 0);
           in31 : in  STD_LOGIC_VECTOR (31 downto 0);
           Ard : in  STD_LOGIC_VECTOR (4 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0));
end MUX_32;

architecture Behavioral of MUX_32 is

begin
	process(Ard,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11, in12, in13,
					in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,
											in24,in25,in26,in27,in28,in29,in30,in31)
		begin
		
		if (Ard="00000") then
			Output <= in0; --R0
			
		elsif (Ard="00001") then
			Output <= in1; --R1
			
		elsif (Ard="00010") then
			Output <= in2; --R2
			
		elsif (Ard="00011") then
			Output <= in3; --R3
			
		elsif (Ard="00100") then
			Output <= in4; --R4
			
		elsif (Ard="00101") then
			Output <= in5; --R5
			
		elsif (Ard="00110") then
			Output <= in6; --R6
			
		elsif (Ard="00111") then
			Output <= in7; --R7
			
		elsif (Ard="01000") then
			Output <= in8; --R8
			
		elsif (Ard="01001") then
			Output <= in9; --R9
			
		elsif (Ard="01010") then
			Output <= in10; --R10	
			
		elsif (Ard="01011") then
			Output <= in11; --R11
			
		elsif (Ard="01100") then
			Output <= in12; --R12
			
		elsif (Ard="01101") then
			Output <= in13; --R13
			
		elsif (Ard="01110") then
			Output <= in14; --R14
			
		elsif (Ard="01111") then
			Output <= in15; --R15
			
		elsif (Ard="10000") then
			Output <= in16; --R16
			
		elsif (Ard="10001") then
			Output <= in17; --R17
			
		elsif (Ard="10010") then
			Output <= in18; --R18
			
		elsif (Ard="10011") then
			Output <= in19; --R19
			
		elsif (Ard="10100") then
			Output <= in20; --R20
			
		elsif (Ard="10101") then
			Output <= in21; --R21
			
		elsif (Ard="10110") then
			Output <= in22; --R22
			
		elsif (Ard="10111") then
			Output <= in23; --R23
			
		elsif (Ard="11000") then
			Output <= in24; --R24
			
		elsif (Ard="11001") then
			Output <= in25; --R25
			
		elsif (Ard="11010") then
			Output <= in26; --R26
			
		elsif (Ard="11011") then
			Output <= in27; --R27
			
		elsif (Ard="11100") then
			Output <= in28; --R28
			
		elsif (Ard="11101") then
			Output <= in29; --R29
			
		elsif (Ard="11110") then
			Output <= in30; --R30
			
		else
			Output <= in31; --R31 
			
		end if;
		
	end process;
		

end Behavioral;

