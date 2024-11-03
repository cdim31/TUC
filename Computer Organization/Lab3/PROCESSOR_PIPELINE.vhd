----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:04:27 04/24/2024 
-- Design Name: 
-- Module Name:    PROCESSOR_PIPELINE - Behavioral 
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

entity PROCESSOR_PIPELINE is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end PROCESSOR_PIPELINE;

architecture Behavioral of PROCESSOR_PIPELINE is

component DATAPATH_PIPELINE 
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
			  Instr_Reg_WrEn : in STD_LOGIC);
end component;

component CONTROL_PIPELINE 
    Port ( 
           RST : in  STD_LOGIC;
			  Instr : in  STD_LOGIC_VECTOR (31 downto 0);
			  ALU_zero : in  STD_LOGIC;
           PC_sel : out  STD_LOGIC;
           PC_LdEn : out  STD_LOGIC;
           RF_B_sel : out  STD_LOGIC;
           RF_WrData_sel : out  STD_LOGIC;
           CloudControl : out  STD_LOGIC_VECTOR (1 downto 0);
           ALU_func : out  STD_LOGIC_VECTOR (3 downto 0);
           ALU_Bin_sel : out  STD_LOGIC;
           MEM_WrEn : out  STD_LOGIC;
           ByteOp : out  STD_LOGIC;
           RF_WrEn : out  STD_LOGIC;
			  Instr_Reg_WrEn : out STD_LOGIC);
end component;

signal Instr_sig : STD_LOGIC_VECTOR (31 downto 0);
signal ALU_zero_sig : STD_LOGIC;
signal PC_sel_sig : STD_LOGIC;
signal PC_LdEn_sig : STD_LOGIC;
signal RF_B_sel_sig : STD_LOGIC;
signal RF_WrData_sel_sig : STD_LOGIC;
signal CloudControl_sig : STD_LOGIC_VECTOR (1 downto 0);
signal ALU_func_sig : STD_LOGIC_VECTOR (3 downto 0);
signal ALU_Bin_sel_sig : STD_LOGIC;
signal MEM_WrEn_sig : STD_LOGIC;
signal ByteOp_sig : STD_LOGIC;
signal RF_WrEn_sig : STD_LOGIC;
signal Instr_Reg_WrEn_sig : STD_LOGIC;

begin

DPATH : DATAPATH_PIPELINE
			port map(
							CLK => CLK,
							RST => RST,
							PC_sel => PC_sel_sig,
							PC_LdEn => PC_LdEn_sig,
							RF_B_sel => RF_B_sel_sig,
							RF_WrData_sel => RF_WrData_sel_sig,
							CloudControl => CloudControl_sig,
							RF_WrEn => RF_WrEn_sig,
							ALU_func => ALU_func_sig,
							ALU_Bin_sel => ALU_Bin_sel_sig,
							MEM_WrEn => MEM_WrEn_sig,
							ByteOp => ByteOp_sig,
							ALU_zero => ALU_zero_sig,
							Instr => Instr_sig,
							Instr_Reg_WrEn => Instr_Reg_WrEn_sig 
						);
	
CPATH : CONTROL_PIPELINE
			port map(
							RST => RST,
							PC_sel => PC_sel_sig,
							PC_LdEn => PC_LdEn_sig,
							RF_B_sel => RF_B_sel_sig,
							RF_WrData_sel => RF_WrData_sel_sig,
							CloudControl => CloudControl_sig,
							RF_WrEn => RF_WrEn_sig,
							ALU_func => ALU_func_sig,
							ALU_Bin_sel => ALU_Bin_sel_sig,
							MEM_WrEn => MEM_WrEn_sig,
							ByteOp => ByteOp_sig,
							ALU_zero => ALU_zero_sig,
							Instr => Instr_sig,
							Instr_Reg_WrEn => Instr_Reg_WrEn_sig 
						);
end Behavioral;

