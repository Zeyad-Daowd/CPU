library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_DFF is 
    port (
        clk: in std_logic;
        enable: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end entity my_DFF;

architecture arch_my_DFF of my_DFF is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end arch_my_DFF;