--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   19:04:23 04/08/2024
-- Design Name:  
-- Module Name:   /home/ise/Lab1/ALU_Tb.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:  
-- 
-- VHDL Test Bench Created by ISE for module: ALU
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
 
ENTITY ALU_Tb IS
END ALU_Tb;
 
ARCHITECTURE behavior OF ALU_Tb IS
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         A : IN  std_logic_vector(31 downto 0);
         B : IN  std_logic_vector(31 downto 0);
         Op : IN  std_logic_vector(3 downto 0);
         Output : OUT  std_logic_vector(31 downto 0);
         Zero : OUT  std_logic;
         Cout : OUT  std_logic;
         Ovf : OUT  std_logic
        );
    END COMPONENT;
   

   --Inputs
   signal A : std_logic_vector(31 downto 0) := (others => '0');
   signal B : std_logic_vector(31 downto 0) := (others => '0');
   signal Op : std_logic_vector(3 downto 0) := (others => '0');

  --Outputs
   signal Output : std_logic_vector(31 downto 0);
   signal Zero : std_logic;
   signal Cout : std_logic;
   signal Ovf : std_logic;

 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          A => A,
          B => B,
          Op => Op,
          Output => Output,
          Zero => Zero,
          Cout => Cout,
          Ovf => Ovf
        );

   -- Stimulus process
   stim_proc: process
   begin
     
      wait for 100 ns;

		--Addition
		Op <= "0000";
		A <= x"00000001";
		B <= x"00000002";
		wait for 100 ns;

		--Overflow at Add
		Op <= "0000";
		A <= x"7fffffff";
		B <= x"00000001";
		wait for 100 ns;

		--Overflow & Cout at Add
		Op <= "0000";
		A <= x"80000000";
		B <= x"ffffffff";
		wait for 100 ns;

		--Subtraction
		Op <= "0001";
		A <= x"00000001";
		B <= x"00000001";
		wait for 100 ns;

		-- Overflow at Sub
		Op <= "0001";
		A <= x"7fffffff";
		B <= x"ffffffff";
		wait for 100 ns;

		-- Cout at Sub
		Op <= "0001";
		A <= x"fffffffe";
		B <= x"ffffffff";
		wait for 100 ns;

		--Logic AND
		Op  <= "0010";
		A <= x"00000001";
		B <= x"00000002";
		wait for 100 ns;

		--Logic OR
		Op <= "0011";
		A <= x"00000011";
		B <= x"00000001";
		wait for 100 ns;

		-- Arithmetic right Shift
		Op <= "1000";
		A <= x"00000001";
		B <= x"00000000";
		wait for 100 ns;

		-- Logical right Shift
		Op <= "1001";
		A <= x"00000011";
		B <= x"00000000";
		wait for 100 ns;

		-- Logical Left Shift
		Op <= "1010";
		A <= x"00000001";
		B <= x"00000000";
		wait for 100 ns;

		-- Rotate Left
		Op <= "1100";
		A <= x"01111111";
		B <= x"00000000";
		wait for 100 ns;

		-- Rotate Right
		Op <= "1101";
		A <= x"0000000f";
		B <= x"00000000";
		wait for 100 ns;


      wait;
   end process;

END;