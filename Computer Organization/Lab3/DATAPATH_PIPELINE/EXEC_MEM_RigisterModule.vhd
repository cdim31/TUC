----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:25 06/10/2024 
-- Design Name: 
-- Module Name:    EXEC_MEM_RegisterModule - Behavioral 
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

entity EXEC_MEM_RegisterModule is
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
end EXEC_MEM_RegisterModule;

architecture Behavioral of EXEC_MEM_RegisterModule is
component RegisterModule_5bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           we : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

component RegisterModule is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           we : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0)
			  );
end component;

component RegisterModule_2bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (1 downto 0);
           we : in  STD_LOGIC);
end component;
begin

ALU_Register : RegisterModule
			port map(
							CLK => CLK,
							RST => RST,
							we => '1',
							Data => MEM_Addr_in,
							Dout => MEM_Addr_out
						);

RF_B_Register : RegisterModule
			port map(
							CLK => CLK,
							RST => RST,
							we => '1',
							Data => Data_in,
							Dout => Data_out
						);
						
WB_Addr_Register : RegisterModule_5bit
			port map(
							CLK => CLK,
							RST => RST,
							we => '1',
							Data => Instr_Addr_in,
							Dout => Instr_Addr_out
						);
		
Rd_Rt_Register : RegisterModule_5bit
			port map(
							CLK => CLK,
							RST => RST,
							we => '1',
							Data => rd_rt_in,
							Dout => rd_rt_out
						);		
MEM_control_Register : RegisterModule_2bit
		port map(
						CLK => CLK,
						RST => RST,
						we => '1',
						Data => MEM_in,
						Dout => MEM_out
					);
					
WB_control_Register : RegisterModule_2bit
		port map(
						CLK => CLK,
						RST => RST,
						we => '1',
						Data => MEM_WB_in,
						Dout => MEM_WB_out
					);
end Behavioral;

