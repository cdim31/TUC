----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:26:59 04/23/2024 
-- Design Name: 
-- Module Name:    DATAPATH_MC - Behavioral 
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

entity DATAPATH_MC is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           PC_sel : in  STD_LOGIC;
           PC_LdEn : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           RF_WrData_sel : in  STD_LOGIC;
           CloudControl : in  STD_LOGIC_VECTOR (1 downto 0);
           RF_WrEn : in  STD_LOGIC;
           ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
           ALU_Bin_sel : in  STD_LOGIC;
           MEM_WrEn : in  STD_LOGIC;
			  ByteOp : in STD_LOGIC;
			  ALU_zero : out STD_LOGIC;
			  Instr : out STD_LOGIC_VECTOR (31 downto 0);
			  -- Write Enables for the new Registers
			  Instr_Reg_WrEn : in STD_LOGIC;
			  Immed_Reg_WrEn : in STD_LOGIC;
			  RF_A_Reg_WrEn : in STD_LOGIC;
			  RF_B_Reg_WrEn : in STD_LOGIC;
			  ALU_Reg_WrEn : in STD_LOGIC;
			  MEM_Reg_WrEn : in STD_LOGIC);
			  
end DATAPATH_MC;

architecture Behavioral of DATAPATH_MC is

-- new component
component RegisterMod
		port(
				CLK : in STD_LOGIC;
				RST : in STD_LOGIC;
				Data : in  STD_LOGIC_VECTOR (31 downto 0);
				Dout : out  STD_LOGIC_VECTOR (31 downto 0);
				we : in  STD_LOGIC);
end component;

component IF_Stage
		port(
				PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
				PC_sel : in  STD_LOGIC;
				PC_LdEn : in  STD_LOGIC;
				Reset : in  STD_LOGIC;
				CLK : in  STD_LOGIC;
				Instr : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component DECSTAGE
		port(  
				Instr : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_WrEn : in  STD_LOGIC;
				ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
				MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_WrData_sel : in  STD_LOGIC;
				RF_B_sel : in  STD_LOGIC;
				CloudControl : in STD_LOGIC_VECTOR (1 downto 0);
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				Immed : out  STD_LOGIC_VECTOR (31 downto 0);
				RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
				RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component EXEC_Stage
		port(
				RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
				Immed : in  STD_LOGIC_VECTOR (31 downto 0);
				ALU_Bin_sel : in  STD_LOGIC;
				ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
				ALU_out : out  STD_LOGIC_VECTOR (31 downto 0);
				ALU_zero : out STD_LOGIC);
end component;
 
component MEM_STAGE
		port(
				a : in STD_LOGIC_VECTOR (9 downto 0);
				d : in STD_LOGIC_VECTOR (31 downto 0);
				we : in STD_LOGIC;
				clk : in STD_LOGIC;
				spo : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component LS_Stage
		port(
				input : in STD_LOGIC_VECTOR (31 downto 0);
				control : in STD_LOGIC;
				output : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal immed_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal rf_a_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal rf_b_signal_in : STD_LOGIC_VECTOR (31 downto 0);
signal mem_ls_signal : STD_LOGIC_VECTOR (31 downto 0);
-- new signals
signal immed_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal rf_a_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal rf_b_signal_out : STD_LOGIC_VECTOR (31 downto 0);

begin

Instr_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => instr_signal_in,
						Dout => instr_signal_out,
						we => '1'
						);
		
Immed_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => immed_signal_in,
						Dout => immed_signal_out,
						we => '1'
					);
	
RF_A_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => rf_a_signal_in,
						Dout => rf_a_signal_out,
						we => '1'
					);
	
RF_B_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => rf_b_signal_in,
						Dout => rf_b_signal_out,
						we => '1'
					);
		
ALU_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => alu_out_signal_in,
						Dout => alu_out_signal_out,
						we => '1'
					);
		
MEM_Register : RegisterMod
		port map(
						CLK => CLK,
						RST => RST,
						Data => mem_ls_signal,
						Dout => mem_out_signal_out,
						we => MEM_Reg_WrEn
					);
		
InstructionFetch : IF_Stage
		port map(
						PC_Immed => immed_signal_out,
						PC_sel => PC_sel,
						PC_LdEn => PC_LdEn,
						Reset => RST,
						CLK => CLK,
						Instr => instr_signal_in
					);
					
Decode : DECSTAGE
		port map(
						Instr => instr_signal_out,
						RF_WrEn => RF_WrEn,
						ALU_out => alu_out_signal_out,
						MEM_out => mem_out_signal_out,
						RF_WrData_sel => RF_WrData_sel,
						RF_B_sel => RF_B_sel,
						CloudControl => CloudControl,
						CLK => CLK,
						RST => RST,
						Immed => immed_signal_in,
						RF_A => rf_a_signal_in,
						RF_B => rf_b_signal_in
					);
					
Execution : EXEC_Stage
		port map(
						RF_A => rf_a_signal_out,
						RF_B => rf_b_signal_out,
						Immed => immed_signal_out,
						ALU_Bin_sel => ALU_Bin_sel,
						ALU_func => ALU_func,
						ALU_out => alu_out_signal_in,
						ALU_zero => ALU_zero
					);
			
Memory : MEM_STAGE
		port map(
						a => alu_out_signal_out (11 downto 2),
						d => rf_b_signal_out,
						we => MEM_WrEn,
						clk => CLK,
						spo => mem_out_signal_in
					);

LoadStoreModule : LS_Stage
		port map(
						input => mem_out_signal_in,
						control => ByteOp,
						output => mem_ls_signal
					);
Instr <= instr_signal_out;
end Behavioral;


