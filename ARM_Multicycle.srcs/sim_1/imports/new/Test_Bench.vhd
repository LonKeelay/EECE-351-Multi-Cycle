----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2021 04:08:07 PM
-- Design Name: 
-- Module Name: Test_Bench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

ENTITY Test_Bench IS
END Test_Bench;

--MUCH OF THIS IS ADAPTED FROM LAB6'S TEST_TOPLEVEL

ARCHITECTURE behavior OF Test_Bench IS
    component ARM is -- single cycle processor
      generic(IM_addr_width : positive := 9;
              DM_addr_width : positive := 9);
      port(clk, reset, en_ARM : in  STD_LOGIC;
                     Switch   : in STD_LOGIC_VECTOR(7 downto 0);
                     PC       : out STD_LOGIC_VECTOR(7 downto 0);
                     Instr    : out STD_LOGIC_VECTOR(31 downto 0);
                     ReadData : out STD_LOGIC_VECTOR(7 downto 0));
      end component;

    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal en_ARM : std_logic := '1';
    signal Switch : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal PC : std_logic_vector(7 downto 0);
    signal Instr : std_logic_vector(31 downto 0);
    signal ReadData : std_logic_vector(7 downto 0);

	-- Other Signals

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    
    -- Test Data(I think you put machine code from the excel file here)
    
    --type test_vector is record
	--end record;

	--type test_data_array is array (natural range <>) of test_vector;
	--constant test_data : test_data_array :=
	--	(
	--	);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: ARM 
		--GENERIC MAP () -- idk if needed
		PORT MAP (
          Clk => Clk,
          reset => reset,
          en_ARM => en_ARM,
          Switch => Switch,
          PC => PC,
          Instr => Instr,
          ReadData => ReadData
        );
    
    -- Clock process definitions
    Clk_process :process
    begin
		wait for Clk_period/2; Clk <= not Clk;
    end process;
    
    -- Stimulus process (Uncomment if needed)
    --stim_proc: process
END;
