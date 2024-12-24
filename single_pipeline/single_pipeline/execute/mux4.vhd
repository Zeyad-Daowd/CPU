library IEEE;
use IEEE.std_logic_1164.all;

ENTITY mux4 IS
GENERIC (n : integer := 8);
    PORT(
        in1, in2, in3 ,in4   : IN std_logic_vector (n-1 DOWNTO 0);
        selector: IN std_logic_vector (1 DOWNTO 0);
        F       : OUT std_logic_vector (n-1 DOWNTO 0);
        cout    : OUT std_logic;
        cin1, cin2, cin3, cin4     : IN std_logic
    );
END mux4;

ARCHITECTURE arch1 OF mux4 IS
BEGIN
    F <= in1 WHEN selector(0) = '0' AND selector(1) = '0'
        ELSE in2 WHEN selector(0) = '1' AND selector(1) = '0'
        ELSE in3 WHEN selector(0) = '0' AND selector(1) = '1'
        ELSE in4;

     cout <= cin1 WHEN selector(0) = '0' AND selector(1) = '0'
     ELSE cin2 WHEN selector(0) = '1' AND selector(1) = '0'
     ELSE cin3 WHEN selector(0) = '0' AND selector(1) = '1'
     ELSE cin4;

END arch1;

