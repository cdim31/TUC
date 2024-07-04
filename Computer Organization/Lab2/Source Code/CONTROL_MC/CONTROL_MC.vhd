----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:00:18 04/24/2024 
-- Design Name: 
-- Module Name:    CONTROL_MC - Behavioral 
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

entity CONTROL_MC is
    Port (
			  CLK : in STD_LOGIC;
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
			  -- Write Enable 
			  Instr_Reg_WrEn : out STD_LOGIC;
			  Immed_Reg_WrEn : out STD_LOGIC;
			  RF_A_Reg_WrEn : out STD_LOGIC;
			  RF_B_Reg_WrEn : out STD_LOGIC;
			  ALU_Reg_WrEn : out STD_LOGIC;
			  MEM_Reg_WrEn : out STD_LOGIC);
end CONTROL_MC;

architecture Behavioral of CONTROL_MC is

type state_type is (if_state, dec_state, exec_state, mem_rd_state, wr_proc_state, initial_state_bne, initial_state_beq);

signal OpCode, Func : STD_LOGIC_VECTOR (5 downto 0);
signal state : state_type;
begin
process 
	begin
	wait until clk'EVENT and clk='1';
	if (RST = '1') then
			state <= if_state;
	else
		case state is
			when initial_state_bne =>
				--PC_sel <= '0';
				PC_LdEn <= '0';
				RF_WrEn <= '0';
				RF_WrData_sel <= '0';
				RF_B_sel <= '0';
				CloudControl <= "00";
				ALU_func <= "1111";
				ALU_Bin_sel <= '0';
				MEM_WrEn  <= '0';
				ByteOp <= '0';
				MEM_Reg_WrEn <= '0';
				
				if ALU_zero = '0' then
					PC_sel <= '1';
				else
					PC_sel <= '0';
				end if;
				state <= if_state;
				
			when initial_state_beq =>
				--PC_sel <= '0';
				PC_LdEn <= '0';
				RF_WrEn <= '0';
				RF_WrData_sel <= '0';
				RF_B_sel <= '0';
				CloudControl <= "00";
				ALU_func <= "1111";
				ALU_Bin_sel <= '0';
				MEM_WrEn  <= '0';
				ByteOp <= '0';
				MEM_Reg_WrEn <= '0';
				
				if ALU_zero = '1' then
					PC_sel <= '1';
				else
					PC_sel <= '0';
				end if;
				state <= if_state;
				
			when if_state =>
				PC_sel <= '0';
				PC_LdEn <= '0';
				RF_WrEn <= '0';
				RF_WrData_sel <= '0';
				RF_B_sel <= '0';
				CloudControl <= "00";
				ALU_func <= "1111";
				ALU_Bin_sel <= '0';
				MEM_WrEn  <= '0';
				ByteOp <= '0';
				MEM_Reg_WrEn <= '0';
				state <= dec_state;
			when dec_state =>
				case Instr(31 downto 26) is 
					-- R-type
					when "100000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- li
					when "111000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					--lui
					when "111001" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "10";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- addi
					when "110000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- andi
					when "110010" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- ori
					when "110011" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- b
					when "111111" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '1';
						RF_B_sel <= '1';
						CloudControl <= "11";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- beq
					when "010000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "11";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					--bne
					when "010001" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "11";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- lb
					when "000011" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '1';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- lw
					when "001111" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '1';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					-- sw
					when "011111" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '1';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '1';
						ByteOp <= '0';
					when others =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
					end case;
					state <= exec_state;
			when exec_state =>
				case Instr(31 downto 26) is 
					-- R-type
					when "100000" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= Instr(3 downto 0);
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					-- li
					when "111000" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					--lui
					when "111001" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "10";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					-- addi
					when "110000" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					-- andi
					when "110010" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					-- ori
					when "110011" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= wr_proc_state;
					-- b
					when "111111" =>
						PC_sel <= '1';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "11";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= initial_state_bne;
					-- beq
					when "010000" =>
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "11";
						ALU_func <= "0001";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= initial_state_beq;
						
						
					--bne
					when "010001" =>
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "11";
						ALU_func <= "0001";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						
						state <= initial_state_bne;
						
					-- lb
					when "000011" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '1';
						MEM_Reg_WrEn <= '1';
						state <= mem_rd_state;
					-- lw
					when "001111" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						MEM_Reg_WrEn <= '1';
						state <= mem_rd_state;
					-- sw
					when "011111" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "0000";
						ALU_Bin_sel <= '1';
						MEM_WrEn  <= '1';
						ByteOp <= '0';
						state <= mem_rd_state;
					when others =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= "0000";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					end case;
			when mem_rd_state =>
				case Instr (31 downto 26) is
					-- lb
					when "000011" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						MEM_Reg_WrEn <= '0';
						state <= wr_proc_state;
					-- lw
					when "001111" =>
						PC_sel <= '0';
						PC_LdEn <= '1';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						MEM_Reg_WrEn <= '0';
						state <= wr_proc_state;
					-- sw
					when "011111" =>
						PC_sel <= '1';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					when others =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					end case;
			when wr_proc_state =>
				case Instr(31 downto 26) is
					-- R-type
					when "100000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= Instr(3 downto 0);
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					-- li
					when "111000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					--lui
					when "111001" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "10";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					-- addi
					when "110000" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					-- andi
					when "110010" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					-- ori
					when "110011" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
				-- lb
				when "000011" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '1';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						MEM_Reg_WrEn <= '0';
						state <= if_state;
					-- lw
					when "001111" =>
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '1';
						RF_WrData_sel <= '1';
						RF_B_sel <= '0';
						CloudControl <= "01";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						MEM_Reg_WrEn <= '0';
						state <= if_state;
					when others => 
						PC_sel <= '0';
						PC_LdEn <= '0';
						RF_WrEn <= '0';
						RF_WrData_sel <= '0';
						RF_B_sel <= '0';
						CloudControl <= "00";
						ALU_func <= "1111";
						ALU_Bin_sel <= '0';
						MEM_WrEn  <= '0';
						ByteOp <= '0';
						state <= if_state;
					end case;
			when others =>
				PC_sel <= '0';
				PC_LdEn <= '0';
				RF_WrEn <= '0';
				RF_WrData_sel <= '0';
				RF_B_sel <= '0';
				CloudControl <= "00";
				ALU_func <= "1111";
				ALU_Bin_sel <= '0';
				MEM_WrEn  <= '0';
				ByteOp <= '0';
				state <= if_state;
			end case;
	end if;
end process;
end Behavioral;
