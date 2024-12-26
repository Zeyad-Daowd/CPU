library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
entity Write_Back is
port (
    --signals
    memToReg: in std_logic;
    --write address
    --write data
    dataBack: in std_logic_vector(15 downto 0);
    mem: in std_logic_vector(15 downto 0);
    --outputs

    --write data
    write_data: out std_logic_vector(15 downto 0)

);
end Write_Back;

architecture Write_Back_arch of Write_Back is
begin
    write_data <= dataBack when memToReg = '0' else mem;
end Write_Back_arch;

