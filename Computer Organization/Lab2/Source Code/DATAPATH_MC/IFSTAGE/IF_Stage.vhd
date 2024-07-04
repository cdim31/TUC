----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:00 04/10/2024 
-- Design Name: 
-- Module Name:    IF_Stage - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IF_stage is
    Port ( PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           PC_sel : in  STD_LOGIC;
           PC_LdEn : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           Instr : out  STD_LOGIC_VECTOR (31 downto 0));
end IF_stage;

architecture Behavioral of IF_stage is

component Mux2
	Port ( input0 : in  STD_LOGIC_VECTOR (31 downto 0);
          input1 : in  STD_LOGIC_VECTOR (31 downto 0);
          sel : in  STD_LOGIC;
          output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Adder
	Port ( in1 : in  STD_LOGIC_VECTOR (31 downto 0);
          in2 : in  STD_LOGIC_VECTOR (31 downto 0);
          output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component PC_Register
	Port ( Clk : in  STD_LOGIC;
          Rst : in  STD_LOGIC;
          WrEn : in  STD_LOGIC;
          Input : in  STD_LOGIC_VECTOR (31 downto 0);
          Output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component IMEM
	Port( a : in  STD_LOGIC_VECTOR (9 downto 0);
			spo : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


signal muxToPC: STD_LOGIC_VECTOR (31 downto 0);
signal muxIn0: STD_LOGIC_VECTOR (31 downto 0);
signal muxIn1: STD_LOGIC_VECTOR (31 downto 0);
signal add4: STD_LOGIC_VECTOR (31 downto 0) := x"00000004";
signal PC_out: STD_LOGIC_VECTOR (31 downto 0);

begin
	
	--MUX
	mux: Mux2 port map(
		input0 => muxIn0,
		input1 => muxIn1,
		sel => PC_sel,
		output => muxToPC);

	--Adder PC + 4
	adder0: Adder port map(
		in1 => PC_out,
		in2=> add4,
		output => muxIn0);
	
	--Adder PC+4+Immed
	adder1: Adder port map(
		in1 => muxIn0,
		in2 => PC_Immed,
		output => muxIn1);

	--Register PC
	pc: PC_Register port map(
		Clk => clk,
      Rst => Reset,
      WrEn =>  PC_LdEn,
      Input => muxToPC,
      Output => PC_out);
	
	--Component memory
	mem: IMEM port map(
		a => PC_out(11 downto 2),
		spo => Instr);

end Behavioral;

