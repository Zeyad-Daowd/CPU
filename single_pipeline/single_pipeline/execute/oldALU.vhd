library IEEE;
use IEEE.std_logic_1164.all;

ENTITY ALUOLD IS
GENERIC (n : integer := 4);
    PORT(
        A, B    : IN std_logic_vector (n-1 DOWNTO 0);
        selector: IN std_logic_vector (3 DOWNTO 0);
        F       : OUT std_logic_vector (n-1 DOWNTO 0);
        cout    : OUT std_logic;
        cin     : IN std_logic
    );
END ALUOLD;

ARCHITECTURE arch1 OF ALUOLD IS
    COMPONENT partB IS
GENERIC (n : integer := 8);
        PORT(
            A, B    : IN std_logic_vector (n-1 DOWNTO 0);
            selector: IN std_logic_vector (1 DOWNTO 0);
            F       : OUT std_logic_vector (n-1 DOWNTO 0);
            cout    : OUT std_logic;
            cin     : IN std_logic
        );
    END COMPONENT;

    COMPONENT partC IS
GENERIC (n : integer := 8);
        PORT(
            A, B    : IN std_logic_vector (n-1 DOWNTO 0);
            selector: IN std_logic_vector (1 DOWNTO 0);
            F       : OUT std_logic_vector (n-1 DOWNTO 0);
            cout    : OUT std_logic;
            cin     : IN std_logic
        );
    END COMPONENT;

    COMPONENT partD IS
GENERIC (n : integer := 8);
        PORT(
            A, B    : IN std_logic_vector (n-1 DOWNTO 0);
            selector: IN std_logic_vector (1 DOWNTO 0);
            F       : OUT std_logic_vector (n-1 DOWNTO 0);
            cout    : OUT std_logic;
            cin     : IN std_logic
        );
    END COMPONENT;

    COMPONENT mux4 IS
GENERIC (n : integer := 8);
	PORT(
        in1, in2, in3 ,in4   : IN std_logic_vector (n-1 DOWNTO 0);
        selector: IN std_logic_vector (1 DOWNTO 0);
        F       : OUT std_logic_vector (n-1 DOWNTO 0);
        cout    : OUT std_logic;
        cin1, cin2, cin3, cin4     : IN std_logic
    );
    END COMPONENT;

    SIGNAL FB, FC, FD  : std_logic_vector (n-1 DOWNTO 0);
    SIGNAL coutB, coutC, coutD : std_logic;
BEGIN
    
    uB: partB generic map (n) PORT MAP (A, B, selector(1 DOWNTO 0), FB, coutB, cin);

    
    uC: partC generic map (n) PORT MAP (A, B, selector(1 DOWNTO 0), FC, coutC, cin);

   
    uD: partD generic map (n) PORT MAP (A, B, selector(1 DOWNTO 0), FD, coutD, cin);

    uMux: mux4 generic map (n) PORT MAP ((others => 'X'), FB, FC, FD, selector(3 DOWNTO 2), F, cout, 'X', coutB, coutC, coutD);

    

END arch1;

