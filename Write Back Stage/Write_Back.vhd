library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
entity Write_Back is
port (
    --signals
    regWrite: in std_logic;
    memToReg: in std_logic;
    flagWriteCTRL: in std_logic;
    --write address
    write_address: in std_logic_vector(2 downto 0);
    --write data
    dataBack: in std_logic_vector(15 downto 0);
    mem: in std_logic_vector(15 downto 0);
    --outputs
    --signals 
    regWrite_out: out std_logic;
    flagWriteCTRL_out: out std_logic;
    --write address
    write_address_out: out std_logic_vector(2 downto 0);
    --write data
    write_data: out std_logic_vector(15 downto 0);
    --stack data or mem forwarding
    mem_out: out std_logic_vector(15 downto 0)

);
end Write_Back;

architecture Write_Back_arch of Write_Back is
begin
    regWrite_out <= regWrite;
    flagWriteCTRL_out <= flagWriteCTRL;
    write_address_out <= write_address;
    mem_out <= mem;
    write_data <= dataBack when memToReg = '0' else mem;
end Write_Back_arch;

