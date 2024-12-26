library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Data_Memory is
    port (
        clk: in std_logic; -- Clock 
        -- for reading the instructions
        read_enable: in std_logic;  -- read enable signal
        read_address: in std_logic_vector(15 downto 0); -- read addres [PC]
        mem_data_out: out std_logic_vector(15 downto 0); -- 16-bit instruction 
        -- for writing the instructions
        write_enable: in std_logic;  -- Write enable signal
        write_address: in std_logic_vector(15 downto 0); -- 16-bit write address, like pc
        write_data: in std_logic_vector(15 downto 0) -- 16-bit instruction to be written
    );
end Data_Memory;

architecture Behavioral of Data_Memory is
    -- memory array
    type memory_array is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal memory: memory_array := (
        others => (others => '0') 
    );

    signal data_reg: std_logic_vector(15 downto 0);
begin

    process(clk)
    begin
    -- write then read
        if rising_edge(clk) then
            if write_enable = '1'  and (to_integer(unsigned(write_address)) < 4096) then
                memory(to_integer(unsigned(write_address))) <= write_data;
            end if;
        end if;
    end process;

    -- Output the instruction
    process(read_enable, read_address)
    begin
        if (read_enable = '1') and (to_integer(unsigned(read_address)) < 4096) then
            data_reg <= memory(to_integer(unsigned(read_address)));
        else
            data_reg <= (others => '0');
        end if;

    end process;
    mem_data_out <= data_reg;
end Behavioral;
