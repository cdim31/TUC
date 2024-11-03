----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:00:18 04/24/2024 
-- Design Name: 
-- Module Name:    CONTROL_PIPELINE - Behavioral 
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

entity CONTROL_PIPELINE is
    Port (
           RST : in  STD_LOGIC;
			  Instr : in  STD_LOGIC_VECTOR (31 downto 0);
			  ALU_zero : in  STD_LOGIC;
           PC_sel : out  STD_LOGIC;
           PC_LdEn : out  STD_LOGIC;
           RF_B_sel : out  STD_LOGIC;
           RF_WrData_sel : out  STD_LOGIC;
           CloudControl : out  STD_LOGIC_VECTOR (1 downto 0);
           ALU_func : out  STD_LOGIC_VECTOR (3 downto 0);
           ALU_Bin_sel : out  STD_LOGIC;
           MEM_WrEn : out  STD_LOGIC;
           ByteOp : out  STD_LOGIC;
           RF_WrEn : out  STD_LOGIC;
			  Instr_Reg_WrEn : out STD_LOGIC);
end CONTROL_PIPELINE;

architecture Behavioral of CONTROL_PIPELINE is

signal OpCode, Func : STD_LOGIC_VECTOR (5 downto 0);

begin
OpCode <= Instr (31 downto 26);
Func <= Instr (5 downto 0);
process(RST, ALU_zero, OpCode, Func)
	begin
		if (RST = '1') then
			PC_sel <= '0';
			PC_LdEn <= '0';
			RF_B_sel <= '0';
			RF_WrData_sel <= '0';
			CloudControl <= "00";
			ALU_func <= "0000";
			ALU_Bin_sel <= '0';
			MEM_WrEn <= '0';
			ByteOp <= '0';
			RF_WrEn <= '0';
			Instr_Reg_WrEn <= '0';
		else
			Instr_Reg_WrEn <= '1';
			case OpCode is
				when "100000" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '0';
					RF_WrData_sel <= '0';
					CloudControl <= "00";
					--
					ALU_Bin_sel <= '0';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
					case Func is
						when "110000" =>
							ALU_func <= "0000";
						when "110001" =>
							ALU_func <= "0001";
						when "110010" =>
							ALU_func <= "0010";
						when "110100" =>
							ALU_func <= "0100";
						when "110011" =>
							ALU_func <= "0011";
						when "111000" =>
							ALU_func <= "1000";
						when "111001" =>
							ALU_func <= "1001";
						when "111010" =>
							ALU_func <= "1010";
						when "111100" =>
							ALU_func <= "1100";
						when "111101" =>
							ALU_func <= "1101";
						when others =>
							ALU_func <= "0000";
					end case;
				-- li : RF[rd] <- SignExtend(Imm)
				when "111000" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "01";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- lui : RF[rd] <- Imm << 16(ZeroFill)
				when "111001" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "10";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- addi : RF[rd] <- RF[rs] + SignExtend(Imm)
				when "110000" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "01";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- andi : RF[rd] <- RF[rs] & ZeroFill(Imm)
				when "110010" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "00";
					ALU_func <= "0010";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- ori : RF[rd] <- RF[rs] | ZeroFill(Imm) 
				when "110011" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "00";
					ALU_func <= "0011";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- B : PC <- PC + 4 + (SignExtend(Imm) << 2)
				when "111111" =>
					PC_sel <= '1';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "11";
					ALU_func <= "0000";
					ALU_Bin_sel <= '0';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '0';
				-- beq : if (RF[rs] == RF[rd]) [PC <- PC + 4 + (SignExtend(Imm) << 2)] else [PC <- PC + 4]

				when "010000" =>
					--
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "11";
					ALU_func <= "0001";
					ALU_Bin_sel <= '0';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '0';
					if (ALU_zero = '1') then
						PC_sel <= '1';
					else
						PC_sel <= '0';
					end if;
				-- bne : if (RF[rs] != RF[rd]) [PC <- PC + 4 + (SignExtend(Imm) << 2)] else [PC <- PC + 4]
				when "010001" =>
					--
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '0';
					CloudControl <= "11";
					ALU_func <= "0001";
					ALU_Bin_sel <= '0';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '0';
					if (ALU_zero = '0') then
						PC_sel <= '1';
					else
						PC_sel <= '0';
					end if;
				-- lb : RF[rd] <- ZeroFill(31 downto 8) & MEM[RF[rs] + SignExtend(Imm)](7 downto 0) 

				when "000011" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '1';
					CloudControl <= "01";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '1';
					RF_WrEn <= '1';
				-- sb : MEM[RF[rs] + SignExtend(Imm)] <- ZeroFill(31 downto 8) &RF[rd](7 downto 0)
				when "000111" =>
				-- lw : RF[rd] <- MEM[RF[rs] + SignExtend(Imm)] 

				when "001111" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '1';
					CloudControl <= "01";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '1';
				-- sw : MEM[RF[rs] + SignExtend(Imm)] <- RF[rd] 
				when "011111" =>
					PC_sel <= '0';
					PC_LdEn <= '1';
					RF_B_sel <= '1';
					RF_WrData_sel <= '1';
					CloudControl <= "01";
					ALU_func <= "0000";
					ALU_Bin_sel <= '1';
					MEM_WrEn <= '1';
					ByteOp <= '0';
					RF_WrEn <= '0';
				when others =>
					PC_sel <= '0';
					PC_LdEn <= '0';
					RF_B_sel <= '0';
					RF_WrData_sel <= '0';
					CloudControl <= "00";
					ALU_func <= "0000";
					ALU_Bin_sel <= '0';
					MEM_WrEn <= '0';
					ByteOp <= '0';
					RF_WrEn <= '0';
			end case;
		end if;
end process;
end Behavioral;

