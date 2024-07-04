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

entity PROCESSOR is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC);
end PROCESSOR;

architecture Behavioral of PROCESSOR is

component CONTROL
	 Port ( --Instruction input
			  Instr : in  STD_LOGIC_VECTOR (31 downto 0);
	 
			  Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  
			  --IF Stage
           PC_sel : out  STD_LOGIC;
           PC_Ld_En : out  STD_LOGIC;
			  
			  --DEC Stage
           RF_WrData_sel : out  STD_LOGIC;
           RF_Wr_En : out  STD_LOGIC;
           RF_B_sel : out  STD_LOGIC;
           CloudControl : out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  --EXEC Stage
           ALU_zero : in  STD_LOGIC;
           ALU_Bin_sel : out  STD_LOGIC;
           ALU_Func : out  STD_LOGIC_VECTOR (3 downto 0);
			  
			  --MEM Stage
           ByteOp : out  STD_LOGIC;
           MEM_WrEn : out  STD_LOGIC);
end component;

component DATAPATH
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
end component;

--SIGNALS 
signal PC_sel_sig,PC_LdEn_sig : std_logic; 
signal RF_WrData_sel_sig,RF_B_sel_sig,RF_Wr_En_sig : std_logic;
signal CloudControl_sig : std_logic_vector(1 downto 0);
signal ALU_Bin_sel_sig : std_logic;
signal ALU_func_sig : std_logic_vector(3 downto 0);
signal ByteOp_sig,MEM_WrEn_sig : std_logic;

signal ALU_zero_sig: std_logic;

signal Instr_sig : std_logic_vector(31 downto 0);

begin

cpath: CONTROL port map(
			 Instr => Instr_sig,
			 Clk => Clk,
          Reset => Reset,
          PC_sel => PC_sel_sig,
          PC_Ld_En => PC_LdEn_sig,
          RF_WrData_seL => RF_WrData_sel_sig,
          RF_Wr_En => RF_Wr_En_sig,
          RF_B_sel => RF_B_sel_sig,
          CloudControl => CloudControl_sig,
          ALU_zero => ALU_zero_sig,
          ALU_Bin_sel => ALU_Bin_sel_sig,
          ALU_Func => ALU_func_sig,
          ByteOp => ByteOp_sig,
          MEM_WrEn => MEM_WrEn_sig);

	
dpath: DATAPATH port map(
			PC_sel => PC_sel_sig,
         Reset => Reset,
         PC_Ld_En => PC_LdEn_sig,
         Clk => Clk, 
         RF_B_sel => RF_B_sel_sig,
         RF_WrData_sel => RF_WrData_sel_sig,
         CloudControl => CloudControl_sig,
         RF_Wr_En => RF_Wr_En_sig, 
         ALU_Bin_sel => ALU_Bin_sel_sig,
         ALU_Func => ALU_func_sig,
         MEM_WrEn => MEM_WrEn_sig,
			ByteOp => ByteOp_sig,
			ALU_zero => ALU_zero_sig, 
			Instr => Instr_sig);
	

end Behavioral;

