--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:00:36 04/13/2024
-- Design Name:   
-- Module Name:   /home/ise/Lab1/IF_Stage_Tb.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IF_Stage
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
 
ENTITY IF_Stage_Tb IS
END IF_Stage_Tb;
 
ARCHITECTURE behavior OF IF_Stage_Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IF_Stage
    PORT(
         PC_Immed : IN  std_logic_vector(31 downto 0);
         PC_sel : IN  std_logic;
         PC_LdEn : IN  std_logic;
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         Instr : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal PC_Immed : std_logic_vector(31 downto 0) := (others => '0');
   signal PC_sel : std_logic := '0';
   signal PC_LdEn : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Clk : std_logic := '0';

 	--Outputs
   signal Instr : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IF_Stage PORT MAP (
          PC_Immed => PC_Immed,
          PC_sel => PC_sel,
          PC_LdEn => PC_LdEn,
          Reset => Reset,
          Clk => Clk,
          Instr => Instr
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      
		Reset <= '1';
      wait for 100 ns;	
		Reset <= '0';
		
		
		PC_LdEn <= '0'; 							--Enable writting to Register
		PC_sel <= '0'; 							--Input 0 of the MUX (PC+4)
		wait for clk_period*3; 					--Starting from 0 adding 4 in each clock cycle  
		
		PC_LdEn <= '0';							--Disable writting
		wait for clk_period*3; 					--Register output is not changing (PC = 12)
		
		wait for 100ns;
		
		Reset <= '1';
		wait for 100ns;
		Reset <= '0';
		
--		
--		PC_LdEn <= '1';
--		PC_sel <= '1'; -- (+4 + imed)
--		PC_Immed <= x"000f0000";
--		wait for clk_period; -- PC = 12 + 4 + PC_Immed
--		PC_Immed <= x"0000ff00";
--		wait for clk_period; -- PC = prevPC + 4 + PC_Immed
--		PC_LdEn <= '0';
--		wait for clk_period;
--		
--		wait for 100ns;
--		Reset <= '1';
--		

      wait;
   end process;

END;
