----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:05:32 04/24/2024 
-- Design Name: 
-- Module Name:    PROCESSOR - Behavioral 
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

entity PROCESSOR_MC is
    Port ( Clk : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end PROCESSOR_MC;

architecture Behavioral of PROCESSOR_MC is

component CONTROL_MC
	 Port ( --Instruction input
			  Instr : in  STD_LOGIC_VECTOR (31 downto 0);
	 
			  Clk : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  
			  --IF Stage
           PC_sel : out  STD_LOGIC;
           PC_LdEn : out  STD_LOGIC;
			  
			  --DEC Stage
           RF_WrData_sel : out  STD_LOGIC;
           RF_WrEn : out  STD_LOGIC;
           RF_B_sel : out  STD_LOGIC;
           CloudControl : out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  --EXEC Stage
           ALU_zero : in  STD_LOGIC;
           ALU_Bin_sel : out  STD_LOGIC;
           ALU_Func : out  STD_LOGIC_VECTOR (3 downto 0);
			  
			  --MEM Stage
           ByteOp : out  STD_LOGIC;
           MEM_WrEn : out  STD_LOGIC;
			  
			  --Write Enable for Registers
			  Instr_Reg_WrEn : out  STD_LOGIC;
			  Immed_Reg_WrEn : out  STD_LOGIC;
			  RF_A_Reg_WrEn : out  STD_LOGIC;
			  RF_B_Reg_WrEn : out  STD_LOGIC;
			  ALU_Reg_WrEn : out  STD_LOGIC;
			  MEM_Reg_WrEn : out  STD_LOGIC);
end component;

component DATAPATH_MC
	Port ( PC_sel : in  STD_LOGIC;
          RST : in  STD_LOGIC;
          PC_LdEn : in  STD_LOGIC;
          Clk : in  STD_LOGIC;
          RF_B_sel : in  STD_LOGIC;
          RF_WrData_sel : in  STD_LOGIC;
          CloudControl : in  STD_LOGIC_VECTOR (1 downto 0);
          RF_WrEn : in  STD_LOGIC;
          ALU_Bin_sel : in  STD_LOGIC;
          ALU_Func : in  STD_LOGIC_VECTOR(3 downto 0);
          MEM_WrEn : in  STD_LOGIC;
			 ByteOp : in  STD_LOGIC;
			 ALU_zero : out  STD_LOGIC;
			 Instr: out  STD_LOGIC_VECTOR(31 downto 0);
			 
			 --Write Enable for Registers
			  Instr_Reg_WrEn : in  STD_LOGIC;
			  Immed_Reg_WrEn : in  STD_LOGIC;
			  RF_A_Reg_WrEn : in  STD_LOGIC;
			  RF_B_Reg_WrEn : in  STD_LOGIC;
			  ALU_Reg_WrEn : in  STD_LOGIC;
			  MEM_Reg_WrEn : in  STD_LOGIC);
end component;

--SIGNALS 
signal PC_sel_sig,PC_LdEn_sig : std_logic; 
signal RF_WrData_sel_sig,RF_B_sel_sig,RF_WrEn_sig : std_logic;
signal CloudControl_sig : std_logic_vector(1 downto 0);
signal ALU_Bin_sel_sig : std_logic;
signal ALU_func_sig : std_logic_vector(3 downto 0);
signal ByteOp_sig,MEM_WrEn_sig : std_logic;

signal ALU_zero_sig: std_logic;

signal Instr_sig : std_logic_vector(31 downto 0);

signal ir_sig,imr_sig,rfa_sig,rfb_sig,alur_sig,memr_sig : std_logic;

begin

cpath_mc: CONTROL_MC port map(
			 Instr => Instr_sig,
			 Clk => Clk,
          RST => RST,
          PC_sel => PC_sel_sig,
          PC_LdEn => PC_LdEn_sig,
          RF_WrData_seL => RF_WrData_sel_sig,
          RF_WrEn => RF_WrEn_sig,
          RF_B_sel => RF_B_sel_sig,
          CloudControl => CloudControl_sig,
          ALU_zero => ALU_zero_sig,
          ALU_Bin_sel => ALU_Bin_sel_sig,
          ALU_Func => ALU_func_sig,
          ByteOp => ByteOp_sig,
          MEM_WrEn => MEM_WrEn_sig,
			 
			 Instr_Reg_WrEn => ir_sig,
			 Immed_Reg_WrEn => imr_sig,
			 RF_A_Reg_WrEn => rfa_sig,
			 RF_B_Reg_WrEn => rfb_sig,
			 ALU_Reg_WrEn => alur_sig,
			 MEM_Reg_WrEn => memr_sig);

	
dpath_mc: DATAPATH_MC port map(
			PC_sel => PC_sel_sig,
         RST => RST,
         PC_LdEn => PC_LdEn_sig,
         Clk => Clk, 
         RF_B_sel => RF_B_sel_sig,
         RF_WrData_sel => RF_WrData_sel_sig,
         CloudControl => CloudControl_sig,
         RF_WrEn => RF_WrEn_sig, 
         ALU_Bin_sel => ALU_Bin_sel_sig,
         ALU_Func => ALU_func_sig,
         MEM_WrEn => MEM_WrEn_sig,
			ByteOp => ByteOp_sig,
			ALU_zero => ALU_zero_sig, 
			Instr => Instr_sig,
			
			Instr_Reg_WrEn => ir_sig,
			Immed_Reg_WrEn => imr_sig,
			RF_A_Reg_WrEn => rfa_sig,
			RF_B_Reg_WrEn => rfb_sig,
			ALU_Reg_WrEn => alur_sig,
			MEM_Reg_WrEn => memr_sig);
	

end Behavioral;

