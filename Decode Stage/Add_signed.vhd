library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Add_signed is 
    port (
        data_in: in std_logic_vector(15 downto 0);
        added_bit: in std_logic_vector(15 downto 0);
        data_out: out std_logic_vector(15 downto 0)
    );
end entity Add_signed;

architecture arch_Add_signed of Add_signed is 
begin
    data_out <= std_logic_vector(unsigned(signed(data_in) + signed(added_bit)));
end architecture;