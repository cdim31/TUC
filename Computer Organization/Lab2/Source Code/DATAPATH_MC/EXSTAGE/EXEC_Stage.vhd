----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:27:59 04/12/2024 
-- Design Name: 
-- Module Name:    EXEC_Stage - Behavioral 
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

entity EXEC_Stage is
    Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_sel : in  STD_LOGIC;
           ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
			  ALU_zero : out  STD_LOGIC;
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0));
end EXEC_Stage;

architecture Behavioral of EXEC_Stage is

--ALU
component ALU
	Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
          B : in  STD_LOGIC_VECTOR (31 downto 0);
          Op : in  STD_LOGIC_VECTOR (3 downto 0);
          Output : out  STD_LOGIC_VECTOR (31 downto 0);
          Zero : out  STD_LOGIC;
          Cout : out  STD_LOGIC;
          Ovf : out  STD_LOGIC);
end component;

--MUX 32 bit
component ExecMux
	Port ( in0 : in  STD_LOGIC_VECTOR (31 downto 0);
          in1 : in  STD_LOGIC_VECTOR (31 downto 0);
          output : out  STD_LOGIC_VECTOR (31 downto 0);
          sel : in  STD_LOGIC);
end component;

signal muxToALU : STD_LOGIC_VECTOR (31 downto 0);

begin

--ALU
alu_mod: ALU port map(
	A => RF_A,
	B => muxToALU,
	Op => ALU_func,
	Output => ALU_out,
	Zero => ALU_zero,
	Cout => open,
	Ovf => open);

--MUX 32 bit
mux_mod: ExecMux port map(
	in0 => RF_B,
	in1 => Immed,
	output => muxToALU,
	sel => ALU_Bin_sel);
	
end Behavioral;

