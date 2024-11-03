----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:57:00 06/10/2024 
-- Design Name: 
-- Module Name:    IF_DEC_RegisterModule - Behavioral 
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

entity IF_DEC_RegisterModule is
    Port ( Instr_in : in  STD_LOGIC_VECTOR (31 downto 0);
           Instr_out : out  STD_LOGIC_VECTOR (31 downto 0);
           Immed_in : in  STD_LOGIC_VECTOR (31 downto 0);
			  Immed_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  we : in  STD_LOGIC;
			  RST : in  STD_LOGIC;
			  CLK : in  STD_LOGIC);
end IF_DEC_RegisterModule;

architecture Behavioral of IF_DEC_RegisterModule is

component RegisterModule
	 Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0);
           we : in  STD_LOGIC);
end component;
 
signal instr_in_sig : STD_LOGIC_VECTOR (31 downto 0);
begin

Instr_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => Instr_in,
						Dout => Instr_out,
						we => we
					);
		
Immed_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => Immed_in,
						Dout => Immed_out,
						we => we
					);
	
end Behavioral;

