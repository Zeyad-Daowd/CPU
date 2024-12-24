library IEEE;
use IEEE.std_logic_1164.all;

ENTITY partD IS
GENERIC (n : integer := 8);
    PORT(
        A       : IN std_logic_vector (n-1 DOWNTO 0);
        B       : IN std_logic_vector (n-1 DOWNTO 0);  
        selector: IN std_logic_vector (1 DOWNTO 0);
        F       : OUT std_logic_vector (n-1 DOWNTO 0);
        cout    : OUT std_logic;
        cin     : IN std_logic
    );
END partD;

ARCHITECTURE arch1 OF partD IS
BEGIN
    F <= '0' & A(n-1 downto 1) WHEN selector(0) = '0' AND selector(1) = '0'
        ELSE A(0) & A(n-1 downto 1) WHEN selector(0) = '1' AND selector(1) = '0'
        ELSE cin & A(n-1 downto 1) WHEN selector(0) = '0' AND selector(1) = '1'
        ELSE A(n-1) & A(n-1 downto 1);

    cout <= A(0);  
END arch1;

