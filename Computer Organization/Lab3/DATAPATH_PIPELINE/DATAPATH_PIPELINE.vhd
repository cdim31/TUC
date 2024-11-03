----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:26:59 04/23/2024 
-- Design Name: 
-- Module Name:    DATAPATH_PIPELINE - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATAPATH_PIPELINE is
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
			  Instr_Reg_WrEn : in STD_LOGIC
--			  Immed_Reg_WrEn : in STD_LOGIC;
--			  RF_A_Reg_WrEn : in STD_LOGIC;
--			  RF_B_Reg_WrEn : in STD_LOGIC;
--			  ALU_Reg_WrEn : in STD_LOGIC;
--			  MEM_Reg_WrEn : in STD_LOGIC
			);
			  
end DATAPATH_PIPELINE;

architecture Behavioral of DATAPATH_PIPELINE is

-- new component
component FORWARD_UNIT
		port( 
				Rs : in  STD_LOGIC_VECTOR (4 downto 0);
				Rt_Rd : in  STD_LOGIC_VECTOR (4 downto 0);
				Rd_exec_mem : in  STD_LOGIC_VECTOR (4 downto 0);
				Rd_mem_wb : in  STD_LOGIC_VECTOR (4 downto 0);
				WrEn_exec_mem : in  STD_LOGIC;
				WrEn_mem_wb : in  STD_LOGIC;
				forwardA : out  STD_LOGIC_VECTOR (1 downto 0);
				forwardB : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component HAZARD_DETECTION_UNIT is
    Port ( Rs : in  STD_LOGIC_VECTOR (4 downto 0);
           Rt : in  STD_LOGIC_VECTOR (4 downto 0);
           Rt_DEC_EXEC : in  STD_LOGIC_VECTOR (4 downto 0);
           MEM_WrEn : in  STD_LOGIC;
           control_out : out  STD_LOGIC;
           PC_LdEn_hu : out  STD_LOGIC;
           WrEn_IF_DEC : out  STD_LOGIC);
end component;

component MUX1BIT
	 Port ( in0 : in  STD_LOGIC;
           in1 : in  STD_LOGIC;
           sel : in  STD_LOGIC;
           output : out  STD_LOGIC);
end component;

component Mux32Bit
		Port( 
				in0 : in  STD_LOGIC_VECTOR (31 downto 0);
				in1 : in  STD_LOGIC_VECTOR (31 downto 0);
				sel : in  STD_LOGIC;
				output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component Mux5Bit
		Port( 
				in0 : in  STD_LOGIC_VECTOR (4 downto 0);
				in1 : in  STD_LOGIC_VECTOR (4 downto 0);
				sel : in  STD_LOGIC;
				output : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

component Mux2bit is
    Port ( in0 : in  STD_LOGIC_VECTOR (1 downto 0);
           in1 : in  STD_LOGIC_VECTOR (1 downto 0);
           sel : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (1 downto 0));
end component;

component Mux_3to1
		port(
				in0 : in  STD_LOGIC_VECTOR (31 downto 0);
				in1 : in  STD_LOGIC_VECTOR (31 downto 0);
				in2 : in  STD_LOGIC_VECTOR (31 downto 0);
				output : out  STD_LOGIC_VECTOR (31 downto 0);
				sel : in  STD_LOGIC_VECTOR (1 downto 0));
end component;

component IF_DEC_RegisterModule
		port(
				CLK : in STD_LOGIC;
				RST : in STD_LOGIC;
				Instr_in : in  STD_LOGIC_VECTOR (31 downto 0);
				Instr_out : out STD_LOGIC_VECTOR (31 downto 0);
				Immed_in : in  STD_LOGIC_VECTOR (31 downto 0);
				Immed_out : out STD_LOGIC_VECTOR (31 downto 0);
				we : in  STD_LOGIC);
end component;

component DEC_EXEC_Registermodule is
		port ( RF_A_in : in  STD_LOGIC_VECTOR (31 downto 0);
				 RF_B_in : in  STD_LOGIC_VECTOR (31 downto 0);
				 Immed_in : in  STD_LOGIC_VECTOR (31 downto 0);
				 RF_A_out : out  STD_LOGIC_VECTOR (31 downto 0);
				 RF_B_out : out  STD_LOGIC_VECTOR (31 downto 0);
				 Immed_out : out  STD_LOGIC_VECTOR (31 downto 0);
				 EXEC_in : in STD_LOGIC_VECTOR (4 downto 0);
				 EXEC_MEM_in : in STD_LOGIC_VECTOR (1 downto 0);
				 EXEC_MEM_WB_in : in STD_LOGIC_VECTOR (1 downto 0);
			    EXEC_out : out STD_LOGIC_VECTOR (4 downto 0);
			    EXEC_MEM_out : out STD_LOGIC_VECTOR (1 downto 0);
			    EXEC_MEM_WB_out : out STD_LOGIC_VECTOR (1 downto 0);
				 Instr_Addr_in : in STD_LOGIC_VECTOR (31 downto 0);
				 Instr_Addr_out : out STD_LOGIC_VECTOR (31 downto 0);
				 MuxOutput_in : in STD_LOGIC_VECTOR (4 downto 0);
				 MuxOutput_out : out STD_LOGIC_VECTOR (4 downto 0);
				 RF_B_sel_in : in STD_LOGIC;
				 RF_B_sel_out : out STD_LOGIC;
				 
				 we : in  STD_LOGIC;
				 CLK : in  STD_LOGIC;
				 RST : in  STD_LOGIC);
end component;

component EXEC_MEM_RegisterModule is
    Port ( Data_in : in  STD_LOGIC_VECTOR (31 downto 0); -- RF_B
           Data_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  Instr_Addr_in : in STD_LOGIC_VECTOR (4 downto 0);
			  Instr_Addr_out : out STD_LOGIC_VECTOR (4 downto 0);
           MEM_Addr_in : in STD_LOGIC_VECTOR (31 downto 0); --ALU out
			  MEM_Addr_out : out STD_LOGIC_VECTOR (31 downto 0);
			  MEM_in : in STD_LOGIC_VECTOR (1 downto 0);
			  MEM_WB_in : in STD_LOGIC_VECTOR (1 downto 0);
			  MEM_out : out STD_LOGIC_VECTOR (1 downto 0);
			  MEM_WB_out : out STD_LOGIC_VECTOR (1 downto 0);
			  rd_rt_in : in STD_LOGIC_VECTOR (4 downto 0);
			  rd_rt_out : out STD_LOGIC_VECTOR (4 downto 0);
			  we : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC);
end component;


component MEM_WB_RegisterModule is
    Port ( Data_in : in  STD_LOGIC_VECTOR (31 downto 0);
           Data_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  Addr_in : in  STD_LOGIC_VECTOR (4 downto 0);
           Addr_out : out  STD_LOGIC_VECTOR (4 downto 0);
			  MEM_in : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  WB_in : in STD_LOGIC_VECTOR (1 downto 0);
			  WB_out : out STD_LOGIC_VECTOR (1 downto 0);
			  rd_rt_in : in STD_LOGIC_VECTOR (4 downto 0);
			  rd_rt_out : out STD_LOGIC_VECTOR (4 downto 0);
           we : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC);
end component;

component IFSTAGE
		port(
				PC_Immed : in  STD_LOGIC_VECTOR (31 downto 0);
				PC_sel : in  STD_LOGIC;
				PC_LdEn : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				CLK : in  STD_LOGIC;
				Instr : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component DECSTAGE_PIPELINE
		port(  
				Instr : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_En : in  STD_LOGIC;
				ALU_out : in  STD_LOGIC_VECTOR (31 downto 0);
				MEM_out : in  STD_LOGIC_VECTOR (31 downto 0);
				Data_in : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_WrData_sel : in  STD_LOGIC;
				RF_B_sel : in  STD_LOGIC;
				CloudControl : in STD_LOGIC_VECTOR (1 downto 0);
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC;
				WriteBack : in STD_LOGIC_VECTOR (4 downto 0);
				MuxOutput : out STD_LOGIC_VECTOR (4 downto 0);
				Immed : out  STD_LOGIC_VECTOR (31 downto 0);
				RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
				RF_B : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

component EXSTAGE
		port(
				RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
				RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
				Immed : in  STD_LOGIC_VECTOR (31 downto 0);
				ALU_Bin_sel : in  STD_LOGIC;
				ALU_func : in  STD_LOGIC_VECTOR (3 downto 0);
				ALU_out : out  STD_LOGIC_VECTOR (31 downto 0);
				ALU_zero : out STD_LOGIC);
end component;
 
component MEM
		port(
				a : in STD_LOGIC_VECTOR (9 downto 0);
				d : in STD_LOGIC_VECTOR (31 downto 0);
				we : in STD_LOGIC;
				clk : in STD_LOGIC;
				spo : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component LS_STAGE
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
signal immed_signal_out_reg_exec : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal_out_dec_exec : STD_LOGIC_VECTOR (31 downto 0);
signal instr_signal_out_exec_mem : STD_LOGIC_VECTOR (4 downto 0);
signal instr_signal_out_mem_wb : STD_LOGIC_VECTOR (4 downto 0);
signal alu_out_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal alu_out_signal_out_reg_dec : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal rf_a_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal rf_b_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal rf_b_signal_out_reg_mem : STD_LOGIC_VECTOR (31 downto 0);
-- new new signals
signal exec_out_sig : STD_LOGIC_VECTOR (4 downto 0);
signal exec_mem_out_sig : STD_LOGIC_VECTOR (1 downto 0);
signal exec_mem_wb_out_sig : STD_LOGIC_VECTOR (1 downto 0);
--
signal mem_out_sig : STD_LOGIC_VECTOR (1 downto 0);
signal mem_wb_out_sig : STD_LOGIC_VECTOR (1 downto 0);
--
signal wb_out_sig : STD_LOGIC_VECTOR (1 downto 0);
-- new new new signals
signal exec_in_sig : STD_LOGIC_VECTOR (4 downto 0);
signal exec_mem_in_sig : STD_LOGIC_VECTOR (1 downto 0);
signal exec_mem_wb_in_sig : STD_LOGIC_VECTOR (1 downto 0);
signal mux_exec_in_sig : STD_LOGIC_VECTOR (4 downto 0);
signal mux_exec_mem_in_sig : STD_LOGIC_VECTOR (1 downto 0);
signal mux_exec_mem_wb_in_sig : STD_LOGIC_VECTOR (1 downto 0);
-- forward signals
signal Mux1_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal Mux2_signal_out : STD_LOGIC_VECTOR (31 downto 0);
signal forwardA_signal : STD_LOGIC_VECTOR (1 downto 0);
signal forwardB_signal : STD_LOGIC_VECTOR (1 downto 0);
signal wb_mux_signal : STD_LOGIC_VECTOR (31 downto 0);
signal Mux_dec_ex_out_signal : STD_LOGIC_VECTOR (4 downto 0);
signal Mux_ex_mem_out_signal : STD_LOGIC_VECTOR (4 downto 0);
signal Mux_to_forward : STD_LOGIC_VECTOR (4 downto 0);
--
signal rf_b_sel_out_sig : STD_LOGIC;
signal mux_in_signal : STD_LOGIC_VECTOR (4 downto 0);
signal mux_out_signal : STD_LOGIC_VECTOR (4 downto 0);
signal PC_LdEn_hu_signal : STD_LOGIC;
signal control_out_signal : STD_LOGIC;
signal Instr_Reg_WrEn_signal : STD_LOGIC;
signal LdEn_signal : STD_LOGIC;

signal we_dec_ex_sig : STD_LOGIC;

begin
mux_exec_in_sig <= (ALU_func & ALU_Bin_sel);
mux_exec_mem_in_sig <= (MEM_WrEn & ByteOp);
mux_exec_mem_wb_in_sig <=(RF_WrData_sel & RF_WrEn);

Hazard_Detection_Unit_Module : HAZARD_DETECTION_UNIT
		port map(
						Rs => instr_signal_out(25 downto 21),
					   Rt => instr_signal_out(15 downto 11),
					   Rt_DEC_EXEC => instr_signal_out_dec_exec(15 downto 11),
					   MEM_WrEn => exec_mem_out_sig(1),
					   control_out => control_out_signal,
					   PC_LdEn_hu => PC_LdEn_hu_signal,
					   WrEn_IF_DEC => Instr_Reg_WrEn_signal
					);
--				
--mux1bit_new : MUX1BIT
--		port map ( in0 => '1',
--					  in1 => '0',
--					  sel => control_out_signal,
--					  output => we_dec_ex_sig
--					 );


Mux_hu1 : Mux5Bit
		port map(
						in1 => "00000",
						in0 => mux_exec_in_sig,
						output => exec_in_sig,
						sel => control_out_signal
					);
	
Mux_hu2 : Mux2bit
		port map(
						in1 => "00",
						in0 => mux_exec_mem_in_sig,
						output => exec_mem_in_sig,
						sel => control_out_signal
					);	
					
Mux_hu3 : Mux2bit
		port map(
						in1 => "00",
						in0 => mux_exec_mem_wb_in_sig,
						output => exec_mem_wb_in_sig,
						sel => control_out_signal
					);	
Mux1 : Mux_3to1
		port map(
						in0 => rf_a_signal_out,
						in1 => wb_mux_signal,
						in2 => alu_out_signal_out,
						output => Mux1_signal_out,
						sel => forwardA_signal
					);

Mux2 : Mux_3to1
		port map(
						in0 => rf_b_signal_out,
						in1 => wb_mux_signal,
						in2 => alu_out_signal_out,
						output => Mux2_signal_out,
						sel => forwardB_signal
					);
					
Mux_wb : Mux32Bit
		port map(
						in0 => alu_out_signal_out_reg_dec,
						in1 => mem_out_signal_out,
						sel => wb_out_sig(1),
						output => wb_mux_signal
					);
		
Forward_Unit_Module : FORWARD_UNIT
		port map(
						Rs => instr_signal_out_dec_exec(25 downto 21),
						Rt_Rd => instr_signal_out_dec_exec(15 downto 11),
						Rd_exec_mem => Mux_ex_mem_out_signal,
						Rd_mem_wb => Mux_to_forward,
						WrEn_exec_mem => '1',
						WrEn_mem_wb => '1',
						forwardA => forwardA_signal,
						forwardB => forwardB_signal
					);

IF_DEC_Register : IF_DEC_RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Instr_in => instr_signal_in,
						Instr_out => instr_signal_out,
						Immed_in => immed_signal_out,
						Immed_out => immed_signal_in,
						we => Instr_Reg_WrEn_signal
					);

DEC_EXEC_Register : DEC_EXEC_RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						RF_A_in => rf_a_signal_in,
						RF_B_in => rf_b_signal_in,
						RF_A_out =>	rf_a_signal_out,
						RF_B_out =>	rf_b_signal_out,
						Immed_in => immed_signal_out,
						Immed_out => immed_signal_out_reg_exec,
						EXEC_in => exec_in_sig,
						EXEC_MEM_in => exec_mem_in_sig,
						EXEC_MEM_WB_in => exec_mem_wb_in_sig,
						EXEC_out => exec_out_sig,
						EXEC_MEM_out => exec_mem_out_sig,
						EXEC_MEM_WB_out => exec_mem_wb_out_sig,
						Instr_Addr_in => instr_signal_out,
						Instr_Addr_out => instr_signal_out_dec_exec,
						MuxOutput_in => mux_in_signal,
						MuxOutput_out => mux_out_signal,
						
						RF_B_sel_in => RF_B_sel, 
						RF_B_sel_out => rf_b_sel_out_sig,
						
						we => '1'
					);						

EXEC_MEM_Register : EXEC_MEM_RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						we => '1',
						Data_in => Mux2_signal_out,
						Data_out => rf_b_signal_out_reg_mem,
						Instr_Addr_in => instr_signal_out_dec_exec(20 downto 16),
						Instr_Addr_out => instr_signal_out_exec_mem,
						MEM_in => exec_mem_out_sig,
						MEM_WB_in => exec_mem_wb_out_sig,
						MEM_out => mem_out_sig,
						MEM_WB_out => mem_wb_out_sig,
						MEM_Addr_in => alu_out_signal_in,
						MEM_Addr_out => alu_out_signal_out,
						rd_rt_in => mux_out_signal,
						rd_rt_out => Mux_ex_mem_out_signal
					);

MEM_WB_Register : MEM_WB_RegisterModule					
		port map( 	  
						Data_in => alu_out_signal_out,
						Data_out => alu_out_signal_out_reg_dec, 
						Addr_in => instr_signal_out_exec_mem,
						Addr_out => instr_signal_out_mem_wb,
						MEM_in => mem_ls_signal,
						MEM_out => mem_out_signal_out,
						WB_in => mem_wb_out_sig,
						WB_out => wb_out_sig,
						rd_rt_in => Mux_ex_mem_out_signal,
						rd_rt_out => Mux_to_forward,
						we => '1',
						RST => RST,
						CLK => CLK
					);
LdEn_signal <= (PC_LdEn_hu_signal and PC_LdEn);
InstructionFetch : IFSTAGE
		port map(
						PC_Immed => immed_signal_in,
						PC_sel => PC_sel,
						PC_LdEn => LdEn_signal,
						RST => RST,
						CLK => CLK,
						Instr => instr_signal_in
					);
					
Decode : DECSTAGE_PIPELINE
		port map(
						Instr => instr_signal_out,
						RF_En => wb_out_sig(0),
						ALU_out => alu_out_signal_out_reg_dec,
						MEM_out => mem_out_signal_out,
						RF_WrData_sel => wb_out_sig(1),
						RF_B_sel => RF_B_sel,
						Data_in => wb_mux_signal,
						CloudControl => CloudControl,
						CLK => CLK,
						RST => RST,
						WriteBack => instr_signal_out_mem_wb,
						MuxOutput => mux_in_signal,
						Immed => immed_signal_out,
						RF_A => rf_a_signal_in,
						RF_B => rf_b_signal_in
					);
					
Execution : EXSTAGE
		port map(
						RF_A => Mux1_signal_out,
						RF_B => Mux2_signal_out,
						Immed => immed_signal_out_reg_exec,
						ALU_Bin_sel => exec_out_sig(0),
						ALU_func => exec_out_sig(4 downto 1),
						ALU_out => alu_out_signal_in,
						ALU_zero => ALU_zero
					);
			
Memory : MEM
		port map(
						a => alu_out_signal_out (11 downto 2),
						d => rf_b_signal_out_reg_mem,
						we => mem_out_sig(1),
						clk => CLK,
						spo => mem_out_signal_in
					);

LoadStoreModule : LS_STAGE
		port map(
						input => mem_out_signal_in,
						control => mem_out_sig(0),
						output => mem_ls_signal
					);
Instr <= instr_signal_out;
end Behavioral;



