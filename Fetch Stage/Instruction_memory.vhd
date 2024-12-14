library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Instruction_Memory is
    port (
        clk: in std_logic; -- Clock 
        -- for reading the instructions
        pc: in std_logic_vector(15 downto 0); -- read addres [PC]
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
        -- to test interrupt instruction
        -- 0 => "1111000000000000",   -- Instruction at index 0
        -- 1 => "0000000000000100",     -- Instruction at index 1
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
    instruction_reg <= memory(to_integer(unsigned(pc)));

    -- Output the instruction
    instruction <= instruction_reg;
end Behavioral;
