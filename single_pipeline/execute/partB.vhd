library IEEE;
use IEEE.std_logic_1164.all;

ENTITY partB IS
GENERIC (n : integer := 8);
    PORT(
        A, B    : IN std_logic_vector (n-1 DOWNTO 0);
        selector: IN std_logic_vector (1 DOWNTO 0);
        F       : OUT std_logic_vector (n-1 DOWNTO 0);
        cout    : OUT std_logic;
        cin     : IN std_logic
    );
END partB;

ARCHITECTURE arch1 OF partB IS
BEGIN
    F <= A xor B WHEN selector(0) = '0' AND selector(1) = '0'
        ELSE A nand B WHEN selector(0) = '1' AND selector(1) = '0'
        ELSE A or B WHEN selector(0) = '0' AND selector(1) = '1'
        ELSE not A;

    cout <= '0'; 
END arch1;

