----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:54:39 06/10/2024 
-- Design Name: 
-- Module Name:    DEC_EXEC_Registermodule - Behavioral 
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

entity DEC_EXEC_Registermodule is
    Port ( RF_A_in : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B_in : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed_in : in  STD_LOGIC_VECTOR (31 downto 0);
			  Instr_Addr_in : in STD_LOGIC_VECTOR (31 downto 0);
			  Instr_Addr_out : out STD_LOGIC_VECTOR (31 downto 0);
           RF_A_out : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B_out : out  STD_LOGIC_VECTOR (31 downto 0);
           Immed_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  EXEC_in : in STD_LOGIC_VECTOR (4 downto 0);
			  EXEC_MEM_in : in STD_LOGIC_VECTOR (1 downto 0);
			  EXEC_MEM_WB_in : in STD_LOGIC_VECTOR (1 downto 0);
			  EXEC_out : out STD_LOGIC_VECTOR (4 downto 0);
			  EXEC_MEM_out : out STD_LOGIC_VECTOR (1 downto 0);
			  EXEC_MEM_WB_out : out STD_LOGIC_VECTOR (1 downto 0);
			  MuxOutput_in : in STD_LOGIC_VECTOR (4 downto 0);
			  MuxOutput_out : out STD_LOGIC_VECTOR (4 downto 0);
			  RF_B_sel_in : in STD_LOGIC;
			  RF_B_sel_out : out STD_LOGIC;
			  
           we : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end DEC_EXEC_Registermodule;

architecture Behavioral of DEC_EXEC_Registermodule is
component RegisterModule
	 Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0);
           we : in  STD_LOGIC);
end component;

component RegisterModule_5bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout : out  STD_LOGIC_VECTOR (4 downto 0);
           we : in  STD_LOGIC);
end component;

component RegisterModule_2bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (1 downto 0);
           we : in  STD_LOGIC);
end component;

component Register1Bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC;
           Dout : out  STD_LOGIC;
           we : in  STD_LOGIC);
end component;

begin

Rf_b_reg : Register1Bit 
		port map(
					CLK => CLK,
					RST => RST,
					Data =>  RF_B_sel_in,
					Dout =>  RF_B_sel_out,
					we => '1'
				);
					


Immed_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => Immed_in,
						Dout => Immed_out,
						we => we
					);
RF_A_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => RF_A_in,
						Dout => RF_A_out,
						we => we
					);
RF_B_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => RF_B_in,
						Dout => RF_B_out,
						we => we
					);
WB_Addr_Register : RegisterModule
		port map(
						CLK => CLK,
						RST => RST,
						Data => Instr_Addr_in,
						Dout => Instr_Addr_out,
						we => we
					);
					
Exec_control_Register : RegisterModule_5bit
		port map(
						CLK => CLK,
						RST => RST,
						we => we,
						Data => EXEC_in,
						Dout => EXEC_out
					);
	
MuxResult_Register : RegisterModule_5bit
		port map(
						CLK => CLK,
						RST => RST,
						we => we,
						Data => MuxOutput_in,
						Dout => MuxOutput_out
					);
					
MEM_control_Register : RegisterModule_2bit
		port map(
						CLK => CLK,
						RST => RST,
						we => we,
						Data => EXEC_MEM_in,
						Dout => EXEC_MEM_out
					);
					
WB_control_Register : RegisterModule_2bit
		port map(
						CLK => CLK,
						RST => RST,
						we => we,
						Data => EXEC_MEM_WB_in,
						Dout => EXEC_MEM_WB_out
					);
end Behavioral;

