--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:45:43 04/09/2024
-- Design Name:   
-- Module Name:   /home/ise/Lab1/MUX_32_Tb.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MUX_32
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY MUX_32_Tb IS
END MUX_32_Tb;
 
ARCHITECTURE behavior OF MUX_32_Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MUX_32
    PORT(
         in0 : IN  std_logic_vector(31 downto 0);
         in1 : IN  std_logic_vector(31 downto 0);
         in2 : IN  std_logic_vector(31 downto 0);
         in3 : IN  std_logic_vector(31 downto 0);
         in4 : IN  std_logic_vector(31 downto 0);
         in5 : IN  std_logic_vector(31 downto 0);
         in6 : IN  std_logic_vector(31 downto 0);
         in7 : IN  std_logic_vector(31 downto 0);
         in8 : IN  std_logic_vector(31 downto 0);
         in9 : IN  std_logic_vector(31 downto 0);
         in10 : IN  std_logic_vector(31 downto 0);
         in11 : IN  std_logic_vector(31 downto 0);
         in12 : IN  std_logic_vector(31 downto 0);
         in13 : IN  std_logic_vector(31 downto 0);
         in14 : IN  std_logic_vector(31 downto 0);
         in15 : IN  std_logic_vector(31 downto 0);
         in16 : IN  std_logic_vector(31 downto 0);
         in17 : IN  std_logic_vector(31 downto 0);
         in18 : IN  std_logic_vector(31 downto 0);
         in19 : IN  std_logic_vector(31 downto 0);
         in20 : IN  std_logic_vector(31 downto 0);
         in21 : IN  std_logic_vector(31 downto 0);
         in22 : IN  std_logic_vector(31 downto 0);
         in23 : IN  std_logic_vector(31 downto 0);
         in24 : IN  std_logic_vector(31 downto 0);
         in25 : IN  std_logic_vector(31 downto 0);
         in26 : IN  std_logic_vector(31 downto 0);
         in27 : IN  std_logic_vector(31 downto 0);
         in28 : IN  std_logic_vector(31 downto 0);
         in29 : IN  std_logic_vector(31 downto 0);
         in30 : IN  std_logic_vector(31 downto 0);
         in31 : IN  std_logic_vector(31 downto 0);
         Ard : IN  std_logic_vector(4 downto 0);
         Output : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal in0 : std_logic_vector(31 downto 0) := (others => '0');
   signal in1 : std_logic_vector(31 downto 0) := (others => '0');
   signal in2 : std_logic_vector(31 downto 0) := (others => '0');
   signal in3 : std_logic_vector(31 downto 0) := (others => '0');
   signal in4 : std_logic_vector(31 downto 0) := (others => '0');
   signal in5 : std_logic_vector(31 downto 0) := (others => '0');
   signal in6 : std_logic_vector(31 downto 0) := (others => '0');
   signal in7 : std_logic_vector(31 downto 0) := (others => '0');
   signal in8 : std_logic_vector(31 downto 0) := (others => '0');
   signal in9 : std_logic_vector(31 downto 0) := (others => '0');
   signal in10 : std_logic_vector(31 downto 0) := (others => '0');
   signal in11 : std_logic_vector(31 downto 0) := (others => '0');
   signal in12 : std_logic_vector(31 downto 0) := (others => '0');
   signal in13 : std_logic_vector(31 downto 0) := (others => '0');
   signal in14 : std_logic_vector(31 downto 0) := (others => '0');
   signal in15 : std_logic_vector(31 downto 0) := (others => '0');
   signal in16 : std_logic_vector(31 downto 0) := (others => '0');
   signal in17 : std_logic_vector(31 downto 0) := (others => '0');
   signal in18 : std_logic_vector(31 downto 0) := (others => '0');
   signal in19 : std_logic_vector(31 downto 0) := (others => '0');
   signal in20 : std_logic_vector(31 downto 0) := (others => '0');
   signal in21 : std_logic_vector(31 downto 0) := (others => '0');
   signal in22 : std_logic_vector(31 downto 0) := (others => '0');
   signal in23 : std_logic_vector(31 downto 0) := (others => '0');
   signal in24 : std_logic_vector(31 downto 0) := (others => '0');
   signal in25 : std_logic_vector(31 downto 0) := (others => '0');
   signal in26 : std_logic_vector(31 downto 0) := (others => '0');
   signal in27 : std_logic_vector(31 downto 0) := (others => '0');
   signal in28 : std_logic_vector(31 downto 0) := (others => '0');
   signal in29 : std_logic_vector(31 downto 0) := (others => '0');
   signal in30 : std_logic_vector(31 downto 0) := (others => '0');
   signal in31 : std_logic_vector(31 downto 0) := (others => '0');
   signal Ard : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal Output : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MUX_32 PORT MAP (
          in0 => in0,
          in1 => in1,
          in2 => in2,
          in3 => in3,
          in4 => in4,
          in5 => in5,
          in6 => in6,
          in7 => in7,
          in8 => in8,
          in9 => in9,
          in10 => in10,
          in11 => in11,
          in12 => in12,
          in13 => in13,
          in14 => in14,
          in15 => in15,
          in16 => in16,
          in17 => in17,
          in18 => in18,
          in19 => in19,
          in20 => in20,
          in21 => in21,
          in22 => in22,
          in23 => in23,
          in24 => in24,
          in25 => in25,
          in26 => in26,
          in27 => in27,
          in28 => in28,
          in29 => in29,
          in30 => in30,
          in31 => in31,
          Ard => Ard,
          Output => Output
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		
		in2 <= x"00ff0000";
		in1 <= x"ffffffff";
		Ard <= "00010";
		wait for 100 ns;
		
		Ard <= "00001";
		wait for 100 ns;

	
      -- insert stimulus here 

      wait;
   end process;

END;
