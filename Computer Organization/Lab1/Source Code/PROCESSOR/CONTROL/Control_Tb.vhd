--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:54:39 04/24/2024
-- Design Name:   
-- Module Name:   /home/ise/Lab1/Control_Tb.vhd
-- Project Name:  Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CONTROL
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
 
ENTITY Control_Tb IS
END Control_Tb;
 
ARCHITECTURE behavior OF Control_Tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CONTROL
    PORT(
         Instr : IN  std_logic_vector(31 downto 0);
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         PC_sel : OUT  std_logic;
         PC_Ld_En : OUT  std_logic;
         RF_WrData_sel : OUT  std_logic;
         RF_Wr_En : OUT  std_logic;
         RF_B_sel : OUT  std_logic;
         CloudControl : OUT  std_logic_vector(1 downto 0);
         ALU_zero : IN  std_logic;
         ALU_Bin_sel : OUT  std_logic;
         ALU_Func : OUT  std_logic_vector(3 downto 0);
         ByteOp : OUT  std_logic;
         MEM_WrEn : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Instr : std_logic_vector(31 downto 0) := (others => '0');
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal ALU_zero : std_logic := '0';

 	--Outputs
   signal PC_sel : std_logic;
   signal PC_Ld_En : std_logic;
   signal RF_WrData_sel : std_logic;
   signal RF_Wr_En : std_logic;
   signal RF_B_sel : std_logic;
   signal CloudControl : std_logic_vector(1 downto 0);
   signal ALU_Bin_sel : std_logic;
   signal ALU_Func : std_logic_vector(3 downto 0);
   signal ByteOp : std_logic;
   signal MEM_WrEn : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CONTROL PORT MAP (
          Instr => Instr,
          Clk => Clk,
          Reset => Reset,
          PC_sel => PC_sel,
          PC_Ld_En => PC_Ld_En,
          RF_WrData_sel => RF_WrData_sel,
          RF_Wr_En => RF_Wr_En,
          RF_B_sel => RF_B_sel,
          CloudControl => CloudControl,
          ALU_zero => ALU_zero,
          ALU_Bin_sel => ALU_Bin_sel,
          ALU_Func => ALU_Func,
          ByteOp => ByteOp,
          MEM_WrEn => MEM_WrEn
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
      
		Reset <= '0';
      wait for 100 ns;	
		
		--=================================================
		--R-Type
		-- 6-bits  5-bits  5-bits  5-bits   5-bits      6-bits
		--[Opcode]  [Rs]   [Rd]    [rt]     [not-used]  [Func]
		--Same Op code, different func
		
		--add
		Instr<=B"100000_00000_00001_00111_00000_110000";
		wait for 50 ns;
		--sub
		Instr<=B"100000_00001_00011_00111_00000_110001";
		wait for 50 ns;
		--and
		Instr<=B"100000_00001_00011_00111_00000_110010";
		wait for 50 ns;
		--or
		Instr<=B"100000_00001_00011_00111_00000_110011";
		wait for 50 ns;
		--not
		Instr<=B"100000_00001_00011_00111_00000_110100";
		wait for 50 ns;
		--arithemtic shift right by 1
		Instr<=B"100000_00001_00011_00111_00000_111000";
		wait for 50 ns;
		--logic shift right by 1
		Instr<=B"100000_00001_00011_00111_00000_111001";
		wait for 50 ns;
		--logic shift left by 1
		Instr<=B"100000_00001_00011_00111_00000_111010";
		wait for 50 ns;
		--rol
		Instr<=B"100000_00001_00011_00111_00000_111100";
		wait for 50 ns;
		--ror
		Instr<=B"100000_00001_00011_00111_00000_111101";
		wait for 50 ns;
		--================
		
		--=================================================
		--I-Type
		-- 6-bits  5-bits  5-bits  16-bits
		--[Opcode]  [Rs]    [rd]   [Immed]
		
		--li
		Instr<=B"111000_00000_00011_00111_00000_000000";
		wait for 50 ns;
		--lui
		Instr<=B"111001_00000_00011_00111_00000_000000";
		wait for 50 ns;
		--addi
		Instr<=B"110000_00001_00011_00111_00000_000000";
		wait for 50 ns;
		--andi
		Instr<=B"110010_00001_00011_00111_00000_000000";
		wait for 50 ns;
      --ori
		Instr<=B"110011_00001_00011_00111_00000_000000";
		wait for 50 ns;
		--b
		Instr<=B"111111_00001_00011_00111_00000_000000";
		wait for 50 ns;
		--beq+alu_zero=1-> it will brunch
		Instr<=B"010000_00001_00011_00111_00000_000000";
		ALU_zero<='1';
		wait for 50 ns;
		--beq+alu_zero=0-> it will NOT brunch
		Instr<=B"010000_00001_00011_00111_00000_000000";
		ALU_zero<='0';
		wait for 50 ns;
		--bne+alu_zero=0->it will brunch
		Instr<=B"010001_00001_00011_00111_00000_000000";
		ALU_zero<='0';
		wait for 50 ns;
		--bne+alu_zero=1-> it will NOT brunch
		Instr<=B"010001_00001_00011_00111_00000_000000";
		ALU_zero<='1';
		wait for 50 ns;
		--lb
		Instr<=B"000011_00001_00011_00111_00000_000000";
		wait for 50 ns;
		--lw
		Instr<=B"001111_00001_00011_00111_00000_000000";
		wait for 50 ns;
		--sw
		Instr<=B"011111_00001_00011_00111_00000_000000";
		wait for 50 ns;


      wait;
   end process;

END;
