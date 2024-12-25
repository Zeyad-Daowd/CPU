library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Instruction_Memory is
    port (
        clk: in std_logic; -- Clock 
        -- for reading the instructions
        pc: in std_logic_vector(15 downto 0); -- read address [PC]
        instruction: out std_logic_vector(15 downto 0); -- 16-bit instruction 
        -- for writing the instructions
        write_enable: in std_logic;  -- Write enable signal
        write_address: in std_logic_vector(15 downto 0); -- 16-bit write address, like pc
        write_data: in std_logic_vector(15 downto 0) -- 16-bit instruction to be written
    );
end Instruction_Memory;

architecture Behavioral of Instruction_Memory is
    -- memory array
    type memory_array is array (0 to 127) of std_logic_vector(15 downto 0);
    
    
    signal memory: memory_array := (
        0 => "0000000000010000",
			1 => "0000000000000000",
			2 => "0000000000000000",
			3 => "0000000000000000",
			4 => "0000000000000000",
			5 => "0000000000000000",
			6 => "0000000000000000",
			7 => "0000000000000000",
			8 => "0000000000000000",
			9 => "0000000000000000",
			10 => "0000000000000000",
			11 => "0000000000000000",
			12 => "0000000000000000",
			13 => "0000000000000000",
			14 => "0000000000000000",
			15 => "0000000000000000",
			16 => "0001100100100000",
			17 => "0000000000000000",
			18 => "0010000100100000",
			19 => "0011000100000000",
			20 => "0011001000000000",
			21 => "0001101001000000",
			22 => "0010000100100000",
			23 => "1001001100000001",
			24 => "0000000000000101",
			25 => "0101001001001100",
			26 => "0010100000100000",
			27 => "0010100001000000",
        others => (others => '0')
    );

    signal instruction_reg: std_logic_vector(15 downto 0); -- Register for instruction output
begin

    process(clk)
    begin
    -- write then read
        if rising_edge(clk) then
            if write_enable = '1' then
                memory(to_integer(unsigned(write_address))) <= write_data;
            end if;
        end if;
    end process;

    instruction_reg <= memory(to_integer(unsigned(pc))) when to_integer(unsigned(pc)) < 4096 else (others => '0');

    -- Output the instruction
    instruction <= instruction_reg;
end Behavioral;
