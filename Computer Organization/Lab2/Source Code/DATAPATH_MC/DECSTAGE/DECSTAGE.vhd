----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:45:10 04/12/2024 
-- Design Name: 
-- Module Name:    DECSTAGE - Behavioral 
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

entity DECSTAGE is
    Port ( Instr : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrEn : in  STD_LOGIC;
           ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_WrData_sel : in  STD_LOGIC;
           Rf_B_sel : in  STD_LOGIC;
           CloudControl : in  STD_LOGIC_VECTOR(1 downto 0);
           Clk : in  STD_LOGIC;
			  Rst : in  STD_LOGIC;
           Immed : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
end DECSTAGE;

architecture Behavioral of DECSTAGE is


--Register File RF
component RegisterFile
	Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
          Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
          Awr : in  STD_LOGIC_VECTOR (4 downto 0);
          Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
          Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
          Din : in  STD_LOGIC_VECTOR (31 downto 0);
          WrEn : in  STD_LOGIC;
          Clk : in  STD_LOGIC;
			 Rst : in STD_LOGIC);
end component;

--Cloud
component Cloud
	Port ( input : in  STD_LOGIC_VECTOR (15 downto 0);
          output : out  STD_LOGIC_VECTOR (31 downto 0);
          control : in  STD_LOGIC_VECTOR (1 downto 0));
end component;

--MUX 5bit
component Mux5Bit
	Port ( in0 : in  STD_LOGIC_VECTOR (4 downto 0);
          in1 : in  STD_LOGIC_VECTOR (4 downto 0);
          output : out  STD_LOGIC_VECTOR (4 downto 0);
          sel : in  STD_LOGIC);
end component;

--MUX 32bit
component Mux32Bit
	Port ( in0 : in  STD_LOGIC_VECTOR (31 downto 0);
          in1 : in  STD_LOGIC_VECTOR (31 downto 0);
          output : out  STD_LOGIC_VECTOR (31 downto 0);
          sel : in  STD_LOGIC);
end component;

signal Mux5: STD_LOGIC_VECTOR (4 downto 0);
signal Mux32: STD_LOGIC_VECTOR (31 downto 0);


begin

--Register File
rg: RegisterFile port map(
	Ard1 => Instr(25 downto 21),
   Ard2 => Mux5, 
   Awr => Instr(20 downto 16),
   Dout1 => RF_A,
   Dout2 => RF_B,
   Din => Mux32, 
   WrEn => RF_WrEn,
   Clk  => Clk,
	Rst => Rst);
	
--Mux 5 bit
mux_5: Mux5Bit port map(
	in0 => Instr(15 downto 11),
   in1 => Instr(20 downto 16),
   output => Mux5,
   sel => Rf_B_sel);

--Mux 32 bit
mux_32: Mux32Bit port map(
	in0 => ALU_out,
   in1 => MEM_out,
   output => Mux32,
   sel =>  RF_WrData_sel);

--Cloud
cld: Cloud port map(
	input => Instr(15 downto 0),
	output => Immed,
	control => CloudControl);


end Behavioral;

