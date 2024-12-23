library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hambola_dff is 
    port (
        clk: in std_logic;
        enable: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end entity hambola_dff;

architecture arch_hambola_dff of hambola_dff is
    signal Q_int : std_logic := '0';  
begin
    Q <= Q_int;

    process (clk)
    begin
        if falling_edge(clk) then
            if enable = '1' then
                Q_int <= D;  
            end if;
        end if;
    end process;
end arch_hambola_dff;
