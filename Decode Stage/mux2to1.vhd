library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity mux2to1 is 
    port (
        choice_1 : in std_logic;
        choice_2: in std_logic;
        sel: in std_logic;
        selected: out std_logic
    );
end entity mux2to1;

architecture arch_mux2to1 of mux2to1 is
begin
    with sel select 
        selected <= choice_1 when '0',
                    choice_2 when '1',
                    '0' when others;
end architecture;