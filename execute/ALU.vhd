library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY ALU IS
    PORT(
        RegA, RegB    : IN std_logic_vector (15 DOWNTO 0);
        selector: IN std_logic_vector (2 DOWNTO 0);
        aluRes       : OUT std_logic_vector (15 DOWNTO 0);
        carryFlag    : OUT std_logic;
        zeroFlag     : OUT std_logic;
        negativeFlag : OUT std_logic
    );
END ALU;

ARCHITECTURE arch1 OF ALU IS
signal temp: std_logic_vector(16 DOWNTO 0);
BEGIN
zeroFlag <= not (temp(0) or temp(1) or temp(2) or temp(3) or 
                 temp(4) or temp(5) or temp(6) or temp(7) or
                 temp(8) or temp(9) or temp(10) or temp(11) or
                 temp(12) or temp(13) or temp(14) or temp(15));
negativeFlag <= temp(15);
carryFlag <= temp(16);
aluRes <= temp(15 DOWNTO 0);
PROCESS(RegA, RegB, selector)
BEGIN
    case selector IS
    WHEN "000" => -- PASS
        temp <= '0' & RegA;
    WHEN "001" => -- NOT
        temp <= '0' & not RegA;
    WHEN "010" => -- INCR
        temp <= std_logic_vector(unsigned('0' & RegA) + to_unsigned(1, 17));
    WHEN "011" => -- ADD
        temp <= std_logic_vector(unsigned('0' & RegA) + unsigned('0' & RegB));
    WHEN "100" => -- SUB
        temp <= std_logic_vector(unsigned(RegA(15) & RegA) + unsigned(not RegB(15) & not RegB) + to_unsigned(1, 17));
        --temp <= std_logic_vector(unsigned('0' & RegA) + unsigned('0' & not RegB) + to_unsigned(1, 17));
    WHEN "101" => -- AND
        temp <= ( '0' & RegA) and ( '0' &  RegB);
    when others =>
        temp <= (others => '0');
    END CASE;
END PROCESS;
END arch1;
