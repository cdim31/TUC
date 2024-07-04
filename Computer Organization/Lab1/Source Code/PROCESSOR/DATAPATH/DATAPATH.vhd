----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:28:34 04/23/2024 
-- Design Name: 
-- Module Name:    DATAPATH - Behavioral 
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

entity DATAPATH is
    Port ( PC_sel : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           PC_Ld_En : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           RF_WrData_sel : in  STD_LOGIC;
           CloudControl : in  STD_LOGIC_VECTOR (1 downto 0);
           RF_Wr_En : in  STD_LOGIC;
           ALU_Bin_sel : in  STD_LOGIC;
           ALU_Func : in  STD_LOGIC_VECTOR(3 downto 0);
           MEM_WrEn : in  STD_LOGIC;
			  ByteOp : in  STD_LOGIC;
			  ALU_zero : out  STD_LOGIC;
			  Instr: out  STD_LOGIC_VECTOR(31 downto 0));
end DATAPATH;

architecture Behavioral of DATAPATH is

component IF_Stage
	Port ( PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
          PC_sel : in  STD_LOGIC;
          PC_LdEn : in  STD_LOGIC;
          Reset : in  STD_LOGIC;
          clk : in  STD_LOGIC;
          Instr : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component DECSTAGE
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
end component;

component EXEC_Stage
	Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
			 RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
			 Immed : in  STD_LOGIC_VECTOR (31 downto 0);
			 ALU_Bin_sel : in  STD_LOGIC;
			 ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
			 ALU_zero : out  STD_LOGIC;
			 ALU_out : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component MEM_STAGE
	Port( a : in  STD_LOGIC_VECTOR (9 downto 0);
			d : in  STD_LOGIC_VECTOR (31 downto 0);
			we : in  STD_LOGIC;
			clk : in  STD_LOGIC;
			spo : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component LS_Stage
	Port ( input : in  STD_LOGIC_VECTOR (31 downto 0);
          output : out  STD_LOGIC_VECTOR (31 downto 0);
          control : in  STD_LOGIC);
end component;

signal immed_signal : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal : STD_LOGIC_VECTOR (31 downto 0);
signal rf_a_signal : STD_LOGIC_VECTOR (31 downto 0);
signal rf_b_signal : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_signal : STD_LOGIC_VECTOR (31 downto 0);

signal ls_stage_out : STD_LOGIC_VECTOR (31 downto 0);


begin

ifstage: IF_Stage port map(
			PC_Immed => immed_signal,
         PC_sel => PC_sel,
         PC_LdEn => PC_Ld_En,
         Reset => Reset,
         clk => Clk,
         Instr => instr_signal);
			
dec: DECSTAGE port map(
			Instr => instr_signal,
         RF_WrEn => RF_Wr_En,
         ALU_out => alu_out_signal,
         MEM_out => ls_stage_out, 
         RF_WrData_sel => RF_WrData_sel,
         Rf_B_sel => RF_B_sel, 
         CloudControl => CloudControl,
         Clk => Clk,
			Rst => Reset,
         Immed => immed_signal,
         RF_A => rf_a_signal,
         RF_B => rf_b_signal);
	
exec: EXEC_Stage port map(
			RF_A => rf_a_signal,
			RF_B => rf_b_signal,
			Immed => immed_signal,
			ALU_Bin_sel => ALU_Bin_sel,
			ALU_func => ALU_Func,
			ALU_zero => ALU_zero,
			ALU_out => alu_out_signal);
			
mem: MEM_STAGE port map(
			a => alu_out_signal(11 downto 2),
			d => rf_b_signal,
			we => MEM_WrEn,
			clk => Clk,
			spo => mem_out_signal);

lsstage: LS_Stage port map(
			input => mem_out_signal,
			output => ls_stage_out,
			control => ByteOp);

Instr <= instr_signal;

end Behavioral;

