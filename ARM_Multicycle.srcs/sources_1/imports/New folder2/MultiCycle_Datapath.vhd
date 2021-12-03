----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer(s):    
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name:    ARM Processor Datapath
-- Module Name:    Datapath - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity datapath is  
  generic(addr_width : positive := 9);
  port(clk, reset, en_ARM : in  STD_LOGIC;
       RegSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
       RegWrite     : in  STD_LOGIC;
       ImmSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
       ALUSrcA      : in  STD_LOGIC;    --new
       ALUSrcB      : in  STD_LOGIC_VECTOR(1 downto 0);--new
       ALUControl   : in  STD_LOGIC_VECTOR(1 downto 0);
       ResultSrc    : in  STD_LOGIC_VECTOR(1 downto 0); --new
       PCWrite      : in  STD_LOGIC; --new
       AdrSrc       : in  STD_LOGIC; --new
       MemWrite     : in  STD_LOGIC; --new
       IRWrite      : in  STD_LOGIC; --new
       ALUFlags     : out STD_LOGIC_VECTOR(3 downto 0);
       PC           : out STD_LOGIC_VECTOR(31 downto 0);
       Instr        : out STD_LOGIC_VECTOR(31 downto 0);
       ALUResult    : out STD_LOGIC_VECTOR(31 downto 0); --new
       ReadData     : out STD_LOGIC_VECTOR(7 downto 0); --needed? new
       ALUOut       : out STD_LOGIC_VECTOR(31 downto 0); --new
       Adr          : out STD_LOGIC_VECTOR(31 downto 0); --needed? new
       Data         : out STD_LOGIC_VECTOR(31 downto 0) --new
       );
end;

architecture Behavioral of datapath is
 
	component MultiCycle_Memory --new combined instruction and data
    generic ( data_width : positive := 32; 
			  addr_width : positive := 9);
	port(clk, WE :  in STD_LOGIC;
		 WD :  in STD_LOGIC_VECTOR(data_width-1 downto 0);
		 A  : in  STD_LOGIC_VECTOR(addr_width-1 downto 0);
		 RD :  out STD_LOGIC_VECTOR(data_width-1 downto 0));
	end component;
	
	COMPONENT Register_File
	GENERIC (data_size : natural := 32;
			 addr_size : natural := 4 );
	PORT(
		clk : IN std_logic;
		WE3 : IN std_logic;
		A1  : IN std_logic_vector(3 downto 0);
		A2  : IN std_logic_vector(3 downto 0);
		A3  : IN std_logic_vector(3 downto 0);
		WD3 : IN std_logic_vector(31 downto 0);
		R15 : IN std_logic_vector(31 downto 0);          
		RD1 : OUT std_logic_vector(31 downto 0);
		RD2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT ALU
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);
		ALUControl : IN std_logic_vector(1 downto 0);          
		Result : OUT std_logic_vector(31 downto 0);
		ALUFlags : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	signal InstrSig : std_logic_vector(31 downto 0);
	signal AdrSig : std_logic_vector(addr_width-1 downto 0); --new needed?
	signal PCsig : std_logic_vector(31 downto 0) := (others => '0');
	signal ExtImm : std_logic_vector(31 downto 0);
	signal ShiftedImm24 : signed(31 downto 0); --needed?
	signal RA1mux : std_logic_vector(3 downto 0);
	signal RA2mux : std_logic_vector(3 downto 0);
	signal SrcA : std_logic_vector(31 downto 0);
	signal SrcB : std_logic_vector(31 downto 0);
	signal DataSig : std_logic_vector(31 downto 0); --new
	signal ALUOutSig : std_logic_vector(31 downto 0); --new
	signal ALUResultSig : std_logic_vector(31 downto 0);
	signal ReadDataSig : std_logic_vector(31 downto 0);
	signal WriteDataSig : std_logic_vector(31 downto 0);
	signal Result : std_logic_vector(31 downto 0);	
	signal RF_WE3 : std_logic; --new
	signal RD1 : std_logic_vector(31 downto 0); --new
	signal RD2 : std_logic_vector(31 downto 0); --new
	signal A : std_logic_vector(31 downto 0); --new
	
begin

	-- Instantiate the Instruction Memory
	i_imem: MultiCycle_Memory --new combined instr and data
	generic map (data_width => 32, 
	             addr_width => addr_width)
	port map(A  => AdrSig,
	         clk => Clk, 
	         WE => MemWrite, 
			 WD => WriteDataSig, 
			 RD => ReadDataSig);
	         
    -- Output the instruction
    Instr <= InstrSig;
			 
	-- Data Memory ReadData(7:0) to the toplevel for display
	ReadData <= ReadDataSig(7 downto 0); 		 
									       
	-- Output the Program Counter
	PC <= PCsig;
	-- Output the ALUResult for the Data Memory Address
	ALUResult <= ALUResultSig;
	
	--Other Outputs (Unknown if needed) all new
	Data <= DataSig;
	Adr <= AdrSig;
	ALUOut <= ALUOutSig;
	
	-- This Mux provides the data loaded into the PC
	-- When PCSrc = '1', the source of the PC in output of ALU or Data Memory
	--     Used for branching
	-- When PCSrc = '0', the source of the PC is PCPlus4
	--     Used when accessing the next consecutive instruction
	AdrSig <= Result(addr_width-1 downto 0) when AdrSrc = '1' else PCSig(addr_width-1 downto 0); --new
	
	-- Program Counter
	-- reset clears it to 0
	-- en_ARM allows PC to be loaded from PCmux
	Process(clk) --new, combined all clock functions
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				PCsig <= (others => '0');
			elsif PCWrite = '1' then	
				PCsig <= Result;
			else
				PCsig <= PCsig;
			end if;
			
			if IRWrite = '1' then
			     InstrSig <= ReadDataSig;
			end if;
			
			DataSig <= ReadDataSig;
			A <= RD1;
			WriteDataSig <= RD2;
			ALUOutSig <= ALUResultSig;
			
		end if; 
	end process;

	
	-- Mux selects address for Port 1 of the Register File
	RA1mux <= InstrSig(19 downto 16) when RegSrc(0) = '0' else x"F";
	
	-- Mux selects address for Port 2 of the Register File
	RA2mux <= InstrSig(3 downto 0) when RegSrc(1) = '0' else InstrSig(15 downto 12);
	
	-- Write enable for Register File is gated by en_ARM
	RF_WE3 <= RegWrite and en_ARM;
	
	-- Instantiate Register File (16 registers x 32 bits)
	i_Register_File: Register_File PORT MAP(
		clk => clk,
		WE3 => RF_WE3,
		A1 => RA1mux,
		A2 => RA2mux,
		A3 => InstrSig(15 downto 12),
		WD3 => Result,
		R15 => Result, --new was pcplus8
		RD1 => RD1, --new was srcA
		RD2 => RD2  --new was Writedatasig
	);
	
	-- 24-bit Immediate Field sign extended and shifted left twice
	ShiftedImm24 <= resize(signed(InstrSig(23 downto 0)),30) & "00";
	
	-- Extend function for Immediate data
	with ImmSrc select
	ExtImm <= std_logic_vector(resize(unsigned(InstrSig(7 downto 0)),ExtImm'length))  when "00",
			  std_logic_vector(resize(unsigned(InstrSig(11 downto 0)),ExtImm'length)) when "01",
			  std_logic_vector(ShiftedImm24) when others;
	
	-- Selects Source of ALU input B
	-- When ALUSrc = '1', selects Extended Immediate Data
	-- When ALUSrc = '0', selects data from register file on Port 2
	SrcA <= A when ALUSrcA = '0' else PCSig; --new
	
	with ALUSrcB select --new
	SrcB <= WriteDataSig when "00",
	        ExtImm when "01",
	        x"4" when others;
	
	
	-- Instantiate the ALU
	i_ALU: ALU PORT MAP(
		A => SrcA,
		B => SrcB,
		ALUControl => ALUControl,
		Result => ALUResultSig,
		ALUFlags => ALUFlags
	);	
	
	-- MUX "ReadData" from Data Memory and "ALUResult" from the ALU to produce "Result"
	-- Result is data written to the PC or the Register File
	with ResultSrc select --new
	Result <= ALUOutSig when "00",
	        DataSig when "01",
	        ALUResultSig when others;
	
end Behavioral;

