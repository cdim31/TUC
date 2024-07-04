--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:52:25 04/02/2024
-- Design Name:   
-- Module Name:   /home/ise/lab0/test_bench.vhd
-- Project Name:  lab0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TopLevel
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
 
ENTITY test_bench IS
END test_bench;
 
ARCHITECTURE behavior OF test_bench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TopLevel
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         TopAddrWr : IN  std_logic_vector(4 downto 0);
         TopAddrRd : IN  std_logic_vector(4 downto 0);
         TopWr : IN  std_logic;
         TopRd : IN  std_logic;
         NumberIN : IN  std_logic_vector(15 downto 0);
         NumberOUT : OUT  std_logic_vector(15 downto 0);
         TopValid : OUT  std_logic;
			TopWrEn : out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal TopAddrWr : std_logic_vector(4 downto 0) := (others => '0');
   signal TopAddrRd : std_logic_vector(4 downto 0) := (others => '0');
   signal TopWr : std_logic := '0';
   signal TopRd : std_logic := '0';
   signal NumberIN : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal NumberOUT : std_logic_vector(15 downto 0);
   signal TopValid : std_logic;
	signal TopWrEn : std_logic;
	

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TopLevel PORT MAP (
          CLK => CLK,
          RST => RST,
          TopAddrWr => TopAddrWr,
          TopAddrRd => TopAddrRd,
          TopWr => TopWr,
          TopRd => TopRd,
          NumberIN => NumberIN,
          NumberOUT => NumberOUT,
          TopValid => TopValid,
			 TopWrEn => TOpWrEn
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
	
		-- Case Initial State 1.1
      TopAddrWr <= "00000";
      TopAddrRd <= "00000";
      TopWr <= '1';
      NumberIN <= "1010101010101010"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
      wait for 100 ns;
		
		-- Case Initial State 1.2
		TopAddrWr <= "00000";
      TopAddrRd <= "00001";
      TopRd <= '1';
      wait for 10 ns;
      TopRd <= '0'; -- De-assert read
      wait for 100 ns;
	
		-- Case Initial State 1.3
		TopAddrWr <= "00000";
      TopAddrRd <= "00000";
		TopRd <= '1';
		TopWr <= '1';
		NumberIN <= "0000000000000000"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
		TopRd <= '0'; -- De-assert read
		
		wait for 100 ns;	
	
		-- Case Reading State 2.1
		TopRd <= '1';
		wait for 10 ns;
		
      TopAddrWr <= "00001";
      TopAddrRd <= "00000";
      TopWr <= '1';
		TopRd <= '0';
      NumberIN <= "1010101010101010"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
      wait for 100 ns;
		
		-- Case Reading State 2.2
		TopAddrWr <= "00000";
      TopAddrRd <= "00001";
      TopRd <= '1';
      wait for 10 ns;
      TopRd <= '0'; -- De-assert read
      wait for 100 ns;
	
		-- Case REading State 2.3
		TopAddrWr <= "00000";
      TopAddrRd <= "00000";
		TopRd <= '1';
		TopWr <= '1';
		NumberIN <= "0000000000000000"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
		TopRd <= '0'; -- De-assert read
      wait for 100 ns;
		
		-- Case Writing State 3.1
		TopWr <= '1';
		wait for 10 ns;
		
      TopAddrWr <= "00001";
      TopAddrRd <= "00000";
		TopRd <= '0';
      NumberIN <= "1010101010101010"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
      wait for 100 ns;
		
		-- Case Writing State 3.2
		TopAddrWr <= "00000";
      TopAddrRd <= "00001";
      TopRd <= '1';
      wait for 10 ns;
      TopRd <= '0'; -- De-assert read
      wait for 100 ns;
	
		-- Case Writing State 3.3
		TopAddrWr <= "00000";
      TopAddrRd <= "00000";
		TopRd <= '1';
		TopWr <= '1';
		NumberIN <= "0000000000000000"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
		TopRd <= '0'; -- De-assert read
      wait for 100 ns;
		
		-- Case Read/Write State 4.1
		TopWr <= '1';
		TopRd <= '1';
		wait for 10 ns;
		
      TopAddrWr <= "00001";
      TopAddrRd <= "00000";
		TopRd <= '0';
      NumberIN <= "1010101010101010"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
      wait for 100 ns;
		
		-- Case Read/Write State 4.2
		TopAddrWr <= "00000";
      TopAddrRd <= "00001";
      TopRd <= '1';
      wait for 10 ns;
      TopRd <= '0'; -- De-assert read
      wait for 100 ns;
	
		-- Case REad/Write State 4.3
		TopAddrWr <= "00000";
      TopAddrRd <= "00000";
		TopRd <= '1';
		TopWr <= '1';
		NumberIN <= "0000000000000000"; -- Sample input data
      wait for 10 ns;
      TopWr <= '0'; -- De-assert write
		TopRd <= '0'; -- De-assert read
      wait for 10 ns;

      -- insert stimulus here 

      wait;
   end process;

END;