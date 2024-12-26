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
    type memory_array is array (0 to 4095) of std_logic_vector(15 downto 0);
    
    impure function init_instruction_mem return memory_array is
        file text_file : text open read_mode is "/home/zizo/CMP Year three/Semester 1/Architecture/Project/CPU/Fetch Stage v2/result.txt";
        variable text_line : line;
        variable ram_content : memory_array;
        variable bv : bit_vector(ram_content(0)'range);
        variable i : integer := 0;
        begin
            while not endfile(text_file) loop
            readline(text_file, text_line);
            read(text_line, bv);
            ram_content(i) := to_stdlogicvector(bv);
            i := i + 1;
            end loop;
            return ram_content;
    end function;
    signal memory: memory_array := init_instruction_mem;

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
