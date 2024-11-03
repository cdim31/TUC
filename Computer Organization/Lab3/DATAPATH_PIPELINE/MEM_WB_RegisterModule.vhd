----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:02:14 06/10/2024 
-- Design Name: 
-- Module Name:    MEM_WB_RegisterModule - Behavioral 
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

entity MEM_WB_RegisterModule is
    Port ( Data_in : in  STD_LOGIC_VECTOR (31 downto 0);
           Data_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  Addr_in : in  STD_LOGIC_VECTOR (4 downto 0);
           Addr_out : out  STD_LOGIC_VECTOR (4 downto 0);
			  MEM_in : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_out : out  STD_LOGIC_VECTOR (31 downto 0);
			  WB_in : in STD_LOGIC_VECTOR (1 downto 0);
			  WB_out : out STD_LOGIC_VECTOR (1 downto 0);
			  rd_rt_in : in  STD_LOGIC_VECTOR (4 downto 0);
           rd_rt_out : out  STD_LOGIC_VECTOR (4 downto 0);
           we : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC);
end MEM_WB_RegisterModule;

architecture Behavioral of MEM_WB_RegisterModule is

component RegisterModule is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           we : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0)
			  );
end component;

component RegisterModule_5bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           we : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout : out  STD_LOGIC_VECTOR (4 downto 0)
			  );
end component;

component RegisterModule_2bit is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           we : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (1 downto 0);
           Dout : out  STD_LOGIC_VECTOR (1 downto 0)
			  );
end component;
begin

ALU_reg: RegisterModule
	port map (	CLK => CLK,
					RST => RST,
					we => '1',
					Data => Data_in,
					Dout => Data_out
				);
				
memAdr: RegisterModule_5bit
	port map (	CLK => CLK,
					RST => RST,
					we => '1',
					Data => rd_rt_in,
					Dout => rd_rt_out
				);
	
Rd_Rt_register: RegisterModule_5bit
	port map (	CLK => CLK,
					RST => RST,
					we => '1',
					Data => Addr_in,
					Dout => Addr_out
				);
mem_reg: RegisterModule
	port map (	CLK => CLK,
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
						Data => WB_in,
						Dout => WB_out
					);
end Behavioral;

