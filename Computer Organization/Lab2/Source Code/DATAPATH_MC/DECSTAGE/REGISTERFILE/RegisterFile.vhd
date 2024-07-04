----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:38:34 04/09/2024 
-- Design Name: 
-- Module Name:    RegisterFile - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
    Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           Din : in  STD_LOGIC_VECTOR (31 downto 0);
           WrEn : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  Rst : in STD_LOGIC);
end RegisterFile;

architecture Behavioral of RegisterFile is

--Define Components

--Decoder
component DecoderMod
	Port(	Awr : in  STD_LOGIC_VECTOR (4 downto 0);
         Output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

--Register 0
component RegisterMod0
	Port (  Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0);
           WE : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end component;



--Register
component RegisterMod
	Port (  Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0);
           WE : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end component;

--MUX
component MUX_32
	  Port ( in0 : in  STD_LOGIC_VECTOR (31 downto 0);
				in1 : in  STD_LOGIC_VECTOR (31 downto 0);
				in2 : in  STD_LOGIC_VECTOR (31 downto 0);
				in3 : in  STD_LOGIC_VECTOR (31 downto 0);
				in4 : in  STD_LOGIC_VECTOR (31 downto 0);
				in5 : in  STD_LOGIC_VECTOR (31 downto 0);
				in6 : in  STD_LOGIC_VECTOR (31 downto 0);
				in7 : in  STD_LOGIC_VECTOR (31 downto 0);
				in8 : in  STD_LOGIC_VECTOR (31 downto 0);
				in9 : in  STD_LOGIC_VECTOR (31 downto 0);
				in10 : in  STD_LOGIC_VECTOR (31 downto 0);
				in11 : in  STD_LOGIC_VECTOR (31 downto 0);
				in12 : in  STD_LOGIC_VECTOR (31 downto 0);
				in13 : in  STD_LOGIC_VECTOR (31 downto 0);
				in14 : in  STD_LOGIC_VECTOR (31 downto 0);
				in15 : in  STD_LOGIC_VECTOR (31 downto 0);
				in16 : in  STD_LOGIC_VECTOR (31 downto 0);
				in17 : in  STD_LOGIC_VECTOR (31 downto 0);
				in18 : in  STD_LOGIC_VECTOR (31 downto 0);
				in19 : in  STD_LOGIC_VECTOR (31 downto 0);
				in20 : in  STD_LOGIC_VECTOR (31 downto 0);
				in21 : in  STD_LOGIC_VECTOR (31 downto 0);
				in22 : in  STD_LOGIC_VECTOR (31 downto 0);
				in23 : in  STD_LOGIC_VECTOR (31 downto 0);
				in24 : in  STD_LOGIC_VECTOR (31 downto 0);
				in25 : in  STD_LOGIC_VECTOR (31 downto 0);
				in26 : in  STD_LOGIC_VECTOR (31 downto 0);
				in27 : in  STD_LOGIC_VECTOR (31 downto 0);
				in28 : in  STD_LOGIC_VECTOR (31 downto 0);
				in29 : in  STD_LOGIC_VECTOR (31 downto 0);
				in30 : in  STD_LOGIC_VECTOR (31 downto 0);
				in31 : in  STD_LOGIC_VECTOR (31 downto 0);
				Ard : in  STD_LOGIC_VECTOR (4 downto 0);
				Output : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

--Signal Decoder->AND
signal DecOut : STD_LOGIC_VECTOR(31 downto 0);

--Signal AND->Registers
signal AndOut : STD_LOGIC_VECTOR(31 downto 0);

--Signal Registers -> Mux (array of 32bit vectors)
type RegOutType is array (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
signal RegOut: RegOutType;


begin

--Port Maps

--Decoder
decoder: DecoderMod port map(
	Awr => Awr,
   Output => DecOut);

----AND Gates
--AndOut(0) <= (DecOut(0) AND WrEn);  
--AndOut(1) <= (DecOut(1) AND WrEn);
--AndOut(2) <= (DecOut(2) AND WrEn);
--AndOut(3) <= (DecOut(3) AND WrEn);
--AndOut(4) <= (DecOut(4) AND WrEn);
--AndOut(5) <= (DecOut(5) AND WrEn);
--AndOut(6) <= (DecOut(6) AND WrEn);
--AndOut(7) <= (DecOut(7) AND WrEn);
--AndOut(8) <= (DecOut(8) AND WrEn);
--AndOut(9) <= (DecOut(9) AND WrEn);
--AndOut(10) <= (DecOut(10) AND WrEn);
--AndOut(11) <= (DecOut(11) AND WrEn);
--AndOut(12) <= (DecOut(12) AND WrEn);
--AndOut(13) <= (DecOut(13) AND WrEn);
--AndOut(14) <= (DecOut(14) AND WrEn);
--AndOut(15) <= (DecOut(15) AND WrEn);
--AndOut(15) <= (DecOut(15) AND WrEn);
--AndOut(16) <= (DecOut(16) AND WrEn);
--AndOut(17) <= (DecOut(17) AND WrEn);
--AndOut(18) <= (DecOut(18) AND WrEn);
--AndOut(19) <= (DecOut(19) AND WrEn);
--AndOut(20) <= (DecOut(20) AND WrEn);
--AndOut(21) <= (DecOut(21) AND WrEn);
--AndOut(22) <= (DecOut(22) AND WrEn);
--AndOut(23) <= (DecOut(23) AND WrEn);
--AndOut(24) <= (DecOut(24) AND WrEn);
--AndOut(25) <= (DecOut(25) AND WrEn);
--AndOut(26) <= (DecOut(26) AND WrEn);
--AndOut(27) <= (DecOut(27) AND WrEn);
--AndOut(28) <= (DecOut(28) AND WrEn);
--AndOut(29) <= (DecOut(29) AND WrEn);
--AndOut(30) <= (DecOut(30) AND WrEn);
--AndOut(31) <= (DecOut(31) AND WrEn);



WriteEnable: for i in 0 to 31 generate
	AndOut(i) <= (DecOut(i) AND WrEn);
end generate;


--Registers
--Reg 0
Reg: RegisterMod0 port map(
	CLK => Clk,
	RST => Rst,
	WE => AndOut(0),
	Data => Din,
	Dout => RegOut(0));
	

--Regs 1 to 31
Regs: for i in 1 to 31 generate
	Reg: RegisterMod port map(
		CLK => Clk,
		RST => Rst,
		WE => AndOut(i),
		Data => Din,
		Dout => RegOut(i));
end generate Regs;

--Mux1
Mux1: MUX_32 port map(
			in0 => RegOut(0),
         in1 => RegOut(1),
			in2 => RegOut(2),
			in3 => RegOut(3),
			in4 => RegOut(4),
			in5 => RegOut(5),
			in6 => RegOut(6),
			in7 => RegOut(7),
			in8 => RegOut(8),
         in9 => RegOut(9),
         in10 => RegOut(10),
			in11 => RegOut(11),
			in12 => RegOut(12),
			in13 => RegOut(13),
			in14 => RegOut(14),
			in15 => RegOut(15),
			in16 => RegOut(16),
			in17 => RegOut(17),
			in18 => RegOut(18),
			in19 => RegOut(19),
			in20 => RegOut(20),
			in21 => RegOut(21),
			in22 => RegOut(22),
			in23 => RegOut(23),
			in24 => RegOut(24),								
			in25 => RegOut(25),
			in26 => RegOut(26),
			in27 => RegOut(27),
			in28 => RegOut(28),
			in29 => RegOut(29),
			in30 => RegOut(30),
			in31 => RegOut(31),
			Ard => Ard1,
       	Output => Dout1);



--Mux2
Mux2: MUX_32 port map(
			in0 => RegOut(0),
         in1 => RegOut(1),
			in2 => RegOut(2),
			in3 => RegOut(3),
			in4 => RegOut(4),
			in5 => RegOut(5),
			in6 => RegOut(6),
			in7 => RegOut(7),
			in8 => RegOut(8),
         in9 => RegOut(9),
         in10 => RegOut(10),
			in11 => RegOut(11),
			in12 => RegOut(12),
			in13 => RegOut(13),
			in14 => RegOut(14),
			in15 => RegOut(15),
			in16 => RegOut(16),
			in17 => RegOut(17),
			in18 => RegOut(18),
			in19 => RegOut(19),
			in20 => RegOut(20),
			in21 => RegOut(21),
			in22 => RegOut(22),
			in23 => RegOut(23),
			in24 => RegOut(24),								
			in25 => RegOut(25),
			in26 => RegOut(26),
			in27 => RegOut(27),
			in28 => RegOut(28),
			in29 => RegOut(29),
			in30 => RegOut(30),
			in31 => RegOut(31),
			Ard => Ard2,
			Output => Dout2);


end Behavioral;

