
library IEEE;
use IEEE.std_logic_1164.all;

ENTITY partC IS
GENERIC (n : integer := 8);
    PORT(
        A       : IN std_logic_vector (n - 1 DOWNTO 0);
        B       : IN std_logic_vector (n - 1 DOWNTO 0);  
        selector: IN std_logic_vector (1 DOWNTO 0);
        F       : OUT std_logic_vector (n - 1 DOWNTO 0);
        cout    : OUT std_logic;
        cin     : IN std_logic
    );
END partC;

ARCHITECTURE arch1 OF partC IS
BEGIN
    F <= A(n-2 downto 0) & '0' WHEN selector(0) = '0' AND selector(1) = '0'
        ELSE A(n-2 downto 0) & A(n-1) WHEN selector(0) = '1' AND selector(1) = '0'
        ELSE A(n-2 downto 0) & cin WHEN selector(0) = '0' AND selector(1) = '1'
        ELSE (others => '0');
		
    cout <= A(n-1)  WHEN selector(0) = '0' AND selector(1) = '0'
    ELSE A(n-1) WHEN selector(0) = '1' AND selector(1) = '0'
    ELSE A(n-1) WHEN selector(0) = '0' AND selector(1) = '1'
    ELSE '0';

END arch1;
