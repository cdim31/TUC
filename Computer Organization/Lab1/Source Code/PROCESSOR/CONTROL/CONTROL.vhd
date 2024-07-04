----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:11:15 04/24/2024 
-- Design Name: 
-- Module Name:    CONTROL - Behavioral 
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

entity CONTROL is
    Port ( --Instruction input
			  Instr : in  STD_LOGIC_VECTOR (31 downto 0);
	 
			  Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  
			  --IF Stage
           PC_sel : out  STD_LOGIC;
           PC_Ld_En : out  STD_LOGIC;
			  
			  --DEC Stage
           RF_WrData_sel : out  STD_LOGIC;
           RF_Wr_En : out  STD_LOGIC;
           RF_B_sel : out  STD_LOGIC;
           CloudControl : out  STD_LOGIC_VECTOR (1 downto 0);
			  
			  --EXEC Stage
           ALU_zero : in  STD_LOGIC;
           ALU_Bin_sel : out  STD_LOGIC;
           ALU_Func : out  STD_LOGIC_VECTOR (3 downto 0);
			  
			  --MEM Stage
           ByteOp : out  STD_LOGIC;
           MEM_WrEn : out  STD_LOGIC);
           
end CONTROL;

architecture Behavioral of CONTROL is

signal OpCode, func: STD_LOGIC_VECTOR(5 downto 0);

begin
	
	OpCode <= Instr(31 downto 26);
	func <= Instr(5 downto 0);

process(OpCode, func, ALU_zero, Reset)

begin

	if(Reset='1') then
	
		PC_sel <= '0';
      PC_Ld_En <= '0';
      RF_WrData_sel <= '0';
      RF_Wr_En <= '0';
      RF_B_sel <= '0';
      CloudControl <= "00";
      ALU_Bin_sel <= '0';
      ALU_Func <= "0000";
      ByteOp <= '0';
      MEM_WrEn  <= '0';
		
	else
		
		case OpCode is
			
			--R-Type
			when "100000" =>	
			
				--PC+4
				PC_sel <= '0';
				--Write Enable PC register
				PC_Ld_En <= '1';			
				--just for init reasons
				CloudControl<="00";		
				--Select ALU out as source
				RF_WrData_sel<='0'; 	
				--rt as second register
				RF_B_sel<='0'; 			
				-- write result to rd
				RF_Wr_En<='1'; 
				--ALU second output is rt
				ALU_Bin_sel <= '0';
				
				ByteOp<='0';
				MEM_WrEn<='0';
				
				case func is
					
					--Addition
					when "110000" =>
						ALU_Func <= "0000";	
					--Substraction
					when "110001" =>
						ALU_Func <= "0001";
					--Logic AND
					when "110010" =>
						ALU_Func <= "0010";
					--Logic Or
					when "110011" =>
						ALU_Func <= "0011";
					--NOT
					when "110100" =>
						ALU_Func <= "0100";
					--Arithemtic shift right by 1
					when "111000" =>
						ALU_Func <= "1000";
					--Logic shift right by 1
					when "111001" =>
						ALU_Func <= "1001";
					--Logic shift left by 1
					when "111010" =>
						ALU_Func <= "1010";
					--ROL 
					when "111100" =>
						ALU_Func <= "1100";
					--ROR
					when "111101" =>
						ALU_Func <= "1101";
					when others =>
						ALU_Func <= "0000";
					
				end case;
			--I-Type
				
			--Load Immediate(loads the last 16 bits)
			--RF[rd]<-RF[r0]+SignExtend(Imm)
			when "111000" =>
			
				--PC+4
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				--Sign extend
				CloudControl<="01";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1'; 
				-- write result to rd
				RF_Wr_En<='1';
				--ALU second output is Immed
				ALU_Bin_sel<='1';
				
				--Addition with R[0]
				ALU_func<="0000";
				ByteOp<='0';
				MEM_WrEn<='0';
				
			--Load Upper Immed(loads the first 16 bits)
			--RF[rd]<-RF[r0]+(Imm<<16(zero-fill))
			when "111001" =>	
			
				--PC+4 
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1';
				
				-- Zero Fill & Shift
				CloudControl<="10";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1'; 
				-- write result to rd
				RF_Wr_En<='1';
				--ALU second output is Immed
				ALU_Bin_sel<='1';
				--Addition with R[0]
				ALU_func<="0000";
				
				ByteOp<='0';
				MEM_WrEn<='0';
		
			--ADDITION IMMEDIATE
			--RF[rd]<-RF[rs]+SignExtend(Imm)
			when "110000" =>

				--PC+4 
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				--Sign extend
				CloudControl<="01";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1';
				-- write result to rd			
				RF_Wr_En<='1';
				--ALU second output is Immed
				ALU_Bin_sel<='1';
				
				--Addition 
				ALU_func<="0000";
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--AND IMMEDIATE
			--RF[rd]<-RF[rs] & ZeroFill(Imm)
			when "110010" =>
			
				--PC+4 
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				--Sign extend
				CloudControl<="01";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1';
				-- write result to rd			
				RF_Wr_En<='1';
				--ALU second output is Immed
				ALU_Bin_sel<='1';
				
				--AND
				ALU_func<="0010";
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--OR IMMEDIATE
			--RF[rd]<-RF[rs] | ZeroFill(Imm)
			when "110011" =>
				
				--PC+4 
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				--Sign extend
				CloudControl<="01";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1';
				-- write result to rd			
				RF_Wr_En<='1';
				--ALU second output is Immed
				ALU_Bin_sel<='1';
				
				--OR
				ALU_func<="0011";
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--BRUNCH
			when "111111" =>
			
				--PC+4+Immed 
				PC_sel<='1';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				--Sign Extend and shift 2
				CloudControl<="11";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1';
				-- do not write to RF		
				RF_Wr_En<='0';
				
				--Do not count ALU out
				ALU_Bin_sel<='0';
				
				ALU_func<="0000";
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--BRUNCH IF EQUAL
			when "010000" =>
			
				--Sign Extend and shift 2
				CloudControl<="11";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1'; 
				-- do not write to RF	
				RF_Wr_En<='0';
				
				--Do not count ALU out
				ALU_Bin_sel<='0';
				
				--Substraction at ALU out in order to see equality
				ALU_func<="0001";
				
				--if the result of the substraction is 0 then the alu_zero will be 1
				if(ALU_zero='1') then
					PC_sel<='1';
					--else if the result of the substarction is not 0,alu_zero will be 0
				else
					PC_sel<='0';
				end if;
				
				--Write Enable PC register
				PC_Ld_En<='1';
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--BRUNCH IF NOT EQUAL
			when "010001" =>
			
				--Sign Extend and shift 2
				CloudControl<="11";
				--ALU out
				RF_WrData_sel<='0'; 
				--I-type
				RF_B_sel<='1'; 
				-- do not write to RF	
				RF_Wr_En<='0';
				
				--Do not count ALU out
				ALU_Bin_sel<='0';
				
				--Substraction at ALU out in order to see equality
				ALU_func<="0001";
				
				--if the result of the substraction is NOT 0 then the alu_zero will be 1
				if(ALU_zero='0') then
					PC_sel<='1';
					--else if the result of the substarction is not 0,alu_zero will be 0
				else
					PC_sel<='0';
				end if;
				
				--Write Enable PC register
				PC_Ld_En<='1';
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			--LOAD BYTE: load a byte from memeory to the rf
			--RF[rd]<-ZeroFill(31 downto 8) & MEM[RF[rs] +SignExtend(Imm)](7 downto 0)
			when "000011" =>
			
				--PC+4
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				-- Sign Extend
				CloudControl<="01";
				--MEM out
				RF_WrData_sel<='1'; 	
				--I-Type
				RF_B_sel<='1'; 
				-- write result to rd	
				RF_Wr_En<='1';
				
				--Add immed
				ALU_Bin_sel<='1';
				
				ALU_func<="0000";
				
				--for lb
				ByteOp<='1';
				MEM_WrEn<='0';
			
			
			--Load Word
			--RF[rd]<-MEM[RF[rs] + SignExtend(Imm)]
			when "001111" =>
			
				--PC+4
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				-- Sign Extend
				CloudControl<="01";
				--MEM out
				RF_WrData_sel<='1'; 	
				--I-Type
				RF_B_sel<='1'; 
				-- write result to rd	
				RF_Wr_En<='1';
				
				--Add immed
				ALU_Bin_sel<='1';
				
				ALU_func<="0000";
				
				ByteOp<='0';
				MEM_WrEn<='0';
			
			 --STORE WORD : store a word(4 bytes) to the memory from the rf
			 --MEM[RF[rs] + SignExtend(Imm)]<-RF[rd]
			 when "011111" =>
			 
				--PC+4
				PC_sel<='0';
				--Write Enable PC register
				PC_Ld_En<='1'; 
				-- Sign Extend
				CloudControl<="01";
				--MEM out
				RF_WrData_sel<='1'; 	
				--I-Type
				RF_B_sel<='1'; 
				-- do not write to reg
				RF_Wr_En<='0';
				
				--Add immed
				ALU_Bin_sel<='1';
				
				ALU_func<="0000";
				
				ByteOp<='0';
				--Write to memory
				MEM_WrEn<='1';
			
			when others =>	
			
				PC_sel <= '0';
				PC_Ld_En <= '0';
				RF_WrData_sel <= '0';
				RF_Wr_En <= '0';
				RF_B_sel <= '0';
				CloudControl <= "00";
				ALU_Bin_sel <= '0';
				ALU_Func <= "0000";
				ByteOp <= '0';
				MEM_WrEn  <= '0';
				
		end case;
	end if;
		
end process;		

end Behavioral;

