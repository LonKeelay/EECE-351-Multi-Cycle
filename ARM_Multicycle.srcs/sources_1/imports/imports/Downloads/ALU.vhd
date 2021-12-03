----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer: 	   
-- 
-- Create Date:     
-- Design Name:	   ARM Processor ALU 
-- Module Name:    ALU - Behavioral 
-- Project Name:   ARM_Processor
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
	Generic ( data_size : positive := 32 );
    Port ( A, B : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
		   ALUControl : in STD_LOGIC_VECTOR (1 downto 0);
           Result : out  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUFlags : out  STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
signal notB, toSum, Anded, Orred, resOut : std_logic_vector(data_size-1 downto 0);
signal sum, dif: std_logic_vector(data_size downto 0);

begin
	Anded <= A and B;
	Orred <= A or B;
	
	ALUFlags(3) <= resOut(data_size-1);
	ALUFlags(2) <= '1' when resOut = std_logic_vector(to_unsigned(0,data_size)) else '0';
	ALUFlags(1) <= sum(data_size) and not(ALUControl(1));
	ALUFlags(0) <= (not (ALUControl(0) xor A(data_size-1) xor B(data_size-1)))
	and (A(data_size-1) xor sum(data_size-1)) 
    and (not ALUControl(1));
	
	toSum <= not B when ALUControl(0) = '1' else B;
	sum <= std_logic_vector(
	       unsigned(toSum)+ resize(unsigned(A), data_size + 1) + to_unsigned(1,data_size + 1)) when ALUControl(0) = '1' else 
	       std_logic_vector(
	       unsigned(toSum)+ resize(unsigned(A), data_size + 1));
	
	resOut <= Orred when ALUControl = "11" else
	           Anded when ALUControl = "10" else
	           sum(data_size-1 downto 0);
	Result <= resOut;
	           
end Behavioral;