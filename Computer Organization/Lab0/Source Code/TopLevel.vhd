----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:17:05 04/02/2024 
-- Design Name: 
-- Module Name:    TopLevel - Behavioral 
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

entity TopLevel is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           TopAddrWr : in  STD_LOGIC_VECTOR (4 downto 0);
           TopAddrRd : in  STD_LOGIC_VECTOR (4 downto 0);
           TopWr : in  STD_LOGIC;
           TopRd : in  STD_LOGIC;
           NumberIN : in  STD_LOGIC_VECTOR (15 downto 0);
           NumberOUT : out  STD_LOGIC_VECTOR (15 downto 0);
           TopValid : out  STD_LOGIC;
			  TopWrEn : out STD_LOGIC
			  );
			  
end TopLevel;

architecture Behavioral of TopLevel is

component MyMemory is 
Port (
			CLK : in  STD_LOGIC;
         a : in  STD_LOGIC_VECTOR (4 downto 0);
			d : in  STD_LOGIC_VECTOR (15 downto 0);
			dpra : in  STD_LOGIC_VECTOR (4 downto 0);
			dpo : out STD_LOGIC_VECTOR (15 downto 0);
			--spo : out STD_LOGIC_VECTOR (15 downto 0);
			we : in STD_LOGIC
			);
end component;

component FSM is 
Port (	  
			  CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           AddrWr : in  STD_LOGIC_VECTOR (4 downto 0);
           AddrRd : in  STD_LOGIC_VECTOR (4 downto 0);
			  AddrRdOut : out STD_LOGIC_VECTOR (4 downto 0);
			  AddrWrOut : out STD_LOGIC_VECTOR (4 downto 0);
           Wr : in  STD_LOGIC;
           Rd : in  STD_LOGIC;
           Valid : out  STD_LOGIC;
			  WrEnable : out STD_LOGIC
			);
end component;

signal tempAddrRd : STD_LOGIC_VECTOR (4 downto 0);
signal tempAddrWr : STD_LOGIC_VECTOR (4 downto 0);
signal tempWrEnable : STD_LOGIC;


begin

memory_component : MyMemory
port map (
				CLK => CLK,
				a => tempAddrWr,
				d => NumberIN,
				dpra => tempAddrRd,
				dpo => NumberOUT,
				we => tempWrEnable
			);
TopWrEn <= tempWrEnable;

fsm_component : FSM
port map (
				CLK => CLK,
				RST => RST,
				AddrWr => TopAddrWr,
				AddrRd => TopAddrRd,
				AddrRdOut => tempAddrRd,
				AddrWrOut => tempAddrWr,
				Wr => TopWr,
				Rd => TopRd,
				Valid => TopValid,
				WrEnable => tempWrEnable
			);


end Behavioral;
