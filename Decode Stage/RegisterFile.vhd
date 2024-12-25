library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Register_File IS 
    PORT (
        clk: IN std_logic;
        reg_write: IN std_logic;
        read_addr_1: IN std_logic_vector(2 downto 0);
        read_addr_2: IN std_logic_vector(2 downto 0);
        write_addr: IN std_logic_vector(2 downto 0);
        write_data: IN std_logic_vector(15 downto 0);
        read_data_1: OUT std_logic_vector(15 downto 0);
        read_data_2: OUT std_logic_vector(15 downto 0)
    );
END ENTITY Register_File;

ARCHITECTURE Register_File_Arch OF Register_File IS
    TYPE reg_file is Array(0 TO 7) of std_logic_vector(15 DOWNTO 0);
    signal my_reg_file: reg_file := (
        0 => "0000000000000000",
        1 => "0000000000000000",
        2 => "0000000000000000",
        3 => "0000000000000000",
        4 => "0000000000000000",
        5 => "0000000000000000",
        6 => "0000000000000000",
        7 => "0000000000000000"
    );
BEGIN
    process (clk)
    begin
        if falling_edge(clk) then
            if reg_write = '1' then
                my_reg_file(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;  
    end process;

    read_data_1 <= my_reg_file(to_integer(unsigned(read_addr_1)));
    read_data_2 <= my_reg_file(to_integer(unsigned(read_addr_2)));
    
END Register_File_Arch;