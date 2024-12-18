
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity processor is 
end entity processor;

architecture arch_processor of processor is
    component my_nDFF IS
        GENERIC ( n : integer := 8);
        PORT(
            Clk, Rst, writeEN : IN std_logic;
            d : IN std_logic_vector(n-1 DOWNTO 0);
            q : OUT std_logic_vector(n-1 DOWNTO 0)
        );
    end component my_nDFF;
    begin
end architecture;
