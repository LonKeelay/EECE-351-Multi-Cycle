----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer: 	   
-- 
-- Create Date:    10:14:31 11/08/2016 
-- Design Name: 
-- Module Name:    Instruction_Memory - Behavioral 
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
library std;
use std.textio.all;

--ADAM I have no clue if this would work but theres no errors, its literally just the two things combined

entity MultiCycle_Memory is
   Generic ( data_width : positive := 32; addr_width : positive := 9);
   Port( clk : in STD_LOGIC; 
         WE  : in STD_LOGIC;
         WD  : in  STD_LOGIC_VECTOR (data_width-1 downto 0);
         A  : in  STD_LOGIC_VECTOR (addr_width-1 downto 0);
         RD : out  STD_LOGIC_VECTOR (data_width-1 downto 0));
end MultiCycle_Memory;

architecture Behavioral of MultiCycle_Memory is

   -- Declare type for the memory
   type instr_RAM_type is array(0 to 2**addr_width-1) 
	     	   of bit_vector(data_width-1 downto 0);
   
   -- Declare function for reading a file and returning 
   -- a data array of the initial memory contents with the program
   impure function init_RAM (file_name : in string) 
	  return instr_RAM_type is  
          FILE     ram_file    : text is in file_name;                       
          variable instruction : line;                                 
          variable instr_RAM   : instr_RAM_type;
          variable I           : natural;	
   begin 
      -- Loop for reading each line in the file
	  -- until end of file is reached
	  -- Then, fill in remaining instr_ROMory with zeros
	  I := 0;
	  while not endfile(ram_file) loop
          readline (ram_file, instruction);                             
          read (instruction, instr_RAM(I));
		  I := I + 1;	
      end loop;
	  for J in I to instr_RAM_type'left loop
		  instr_RAM(J) := (others => '0');
	  end loop;
      return instr_RAM;
   end function;                                                

   -- Declare a signal for the instruction array read from the file
   signal Multi_MEM : instr_RAM_type := 
   init_RAM("../../program.txt"); -- Synthesis
--   init_RAM("../../../../program.txt"); -- Simulation

begin

	process (A)    -- Asynchronous Read                                            
	begin                                                        
		RD <= to_stdlogicvector(Multi_MEM(to_integer(unsigned(A))));      
	end process; 
    process (clk)  -- Synchronous Write to Data Memory                                          
    begin
       if rising_edge(clk) then 
          if WE = '1' then
             Multi_MEM(to_integer(unsigned(A))) <= to_bitvector(WD); 
          end if;
       end if;                                                       
    end process;

end Behavioral;
