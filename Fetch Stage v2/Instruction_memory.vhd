library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

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
    signal memory: memory_array := (
        0 => "1000000000000000", -- 00010|xxxxxxxxxx|0
        1 => "1000001001100000", -- 00011|010|011|xxxx|0
        2 => "1000001100000000", -- 00110|011|xxxxxxx|0
        3 => "1000010101000000", -- 01001|101 010 000|x|0 
        4 => "1000000001000000", -- push
        5 => "1000100000000000", -- pop
        6 => "1111111111111111",
        7 => "1110101001100000",
        others => (others => '0')   -- Initialize the rest of the memory to 0
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
