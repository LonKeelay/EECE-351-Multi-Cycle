----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer(s):    Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
-- Project Name:   ARM_SingleCycle Processor
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

entity controller is -- single cycle control decoder
  port(clk, reset:        in  STD_LOGIC;
       Instr:             in  STD_LOGIC_VECTOR(31 downto 12);
       ALUFlags:          in  STD_LOGIC_VECTOR(3 downto 0);
       RegSrc:            out STD_LOGIC_VECTOR(1 downto 0);
       RegWrite:          out STD_LOGIC;
       ImmSrc:            out STD_LOGIC_VECTOR(1 downto 0);
	   IRWrite:		out STD_LOGIC;
	   PCWrite:		out STD_LOGIC;
	   AdrSrc:		out STD_LOGIC;
	   ALUSrc:     out STD_LOGIC;
	   ALUSrcA:		out STD_LOGIC;
	   ALUSrcB:		out STD_LOGIC_VECTOR(1 downto 0);
	   ALUOp:		out STD_LOGIC;
	   ResultSrc:	out STD_LOGIC_VECTOR(1 downto 0);
       ALUControl:        out STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:          out STD_LOGIC;
       MemtoReg:          out STD_LOGIC;
       PCSrc:             out STD_LOGIC);
end;
architecture Behavioral of Controller is

	COMPONENT Decoder
	PORT(
		Op : IN std_logic_vector(1 downto 0);
		Funct : IN std_logic_vector(5 downto 0);
		Rd : IN std_logic_vector(3 downto 0);
		FlagW : OUT std_logic_vector(1 downto 0);
		PCS : OUT std_logic;
		RegW : OUT std_logic;
		MemW : OUT std_logic;
		MemtoReg : OUT std_logic;
		ALUSrc : OUT std_logic;
		ImmSrc : OUT std_logic_vector(1 downto 0);
		RegSrc : OUT std_logic_vector(1 downto 0);
		ALUControl : OUT std_logic_vector(1 downto 0)          
		);
	END COMPONENT;

	COMPONENT Cond_Logic
	PORT(
		clk : std_logic;
		reset : std_logic;
		Cond : IN std_logic_vector(3 downto 0);
		ALUFlags : IN std_logic_vector(3 downto 0);
		FlagW : IN std_logic_vector(1 downto 0);
		PCS : IN std_logic;
		RegW : IN std_logic;
		MemW : IN std_logic;          
		PCSrc : OUT std_logic;
		RegWrite : OUT std_logic;
		MemWrite : OUT std_logic
		);
	END COMPONENT;
	
	signal FlagW : std_logic_vector(1 downto 0);
	signal PCS  : std_logic;
	signal RegW : std_logic;
	signal MemW : std_logic;

	type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
	signal state : state_type := S0;
	signal next_state : state_type;

begin

	-- Instantiate the Decoder Function of the Controller
	i_Decoder: Decoder PORT MAP(
		Op => Instr(27 downto 26),
		Funct => Instr(25 downto 20),
		Rd => Instr(15 downto 12),
		FlagW => FlagW,
		PCS => PCS,
		RegW => RegW,
		MemW => MemW,
		MemtoReg => MemtoReg,
		ALUSrc => ALUSrc,
		ImmSrc => ImmSrc,
		RegSrc => RegSrc,
		ALUControl => ALUControl 
	);

	-- Instantiate the Conditional Logic Function of the Controller
	i_Cond_Logic: Cond_Logic PORT MAP(
		clk => clk,
		reset => reset,
		Cond => Instr(31 downto 28),
		ALUFlags => ALUFlags,
		FlagW => FlagW,
		PCS => PCS,
		RegW => RegW,
		MemW => MemW,
		PCSrc => PCSrc,
		RegWrite => RegWrite,
		MemWrite => MemWrite 
	);

	process(clk, reset)
	begin
		if rising_edge(clk) then
		    if reset = '1' then
		          state <= S0;
		    else
		          state <= next_state;
			end if;
		end if;
	end process;
	
	process(state, Instr)
	begin
		IRWrite <= '0';
		PCWrite <= '0';
		RegWrite <= '0';
		MemWrite <= '0';
		case state is
			when S0 =>
				next_state <= S1;
				AdrSrc <= '0';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= '0';
				ResultSrc <= "10";
				IRWrite <= '1';
				PCWrite <= '1';

			when S1 =>
				-- Op = Instr(27 downto 26)
				-- Funct5 = Instr(25)
				case Instr(27 downto 26) is
					when "01" =>
						next_state <= S2;
					when "00" =>
						if Instr(25) = '0' then
							next_state <= S6;
						else
							next_state <= S7;
						end if;
					when others =>
						next_state <= S9;
				end case;
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				ALUOp <= '0';
				ResultSrc <= "10";

			when S2 =>
				--Funct0 = Instr(20)
				case Instr(20) is
					when '1' =>
						next_state <= S3;
					when others =>
						next_state <= S5;
				end case;
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= '0';

			when S3 =>
				next_state <= S4;
				ResultSrc <= "00";
				AdrSrc <= '1';

			when S4 =>
				next_state <= S0;
				ResultSrc <= "01";
				RegWrite <= '1';

			when S5 =>
				next_state <= S0;
				ResultSrc <= "00";
				AdrSrc <= '1';
				MemWrite <= '1';

			when S6 =>
				next_state <= S8;
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				ALUOp <= '1';

			when S7 =>
				next_state <= S8;
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= '1';

			when S8 =>
				next_state <= S0;
				ResultSrc <= "00";
				RegWrite <= '1';
			
			when S9 =>
				next_state <= S0;
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= '0';
				ResultSrc <= "10";
				
		end case;
	end process;

end Behavioral;

