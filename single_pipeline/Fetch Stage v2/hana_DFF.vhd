library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hana_DFF is 
    port (
        clk: in std_logic;
        enable: in std_logic;
        D: in std_logic;
        Q: out std_logic
    );
end entity hana_DFF;

architecture arch_hana_DFF of hana_DFF is
    signal Q_int : std_logic := '0';  
begin
    Q <= Q_int;

    process (clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                Q_int <= D;  
            end if;
        end if;
    end process;
end arch_hana_DFF;

