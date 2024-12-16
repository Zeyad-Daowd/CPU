library IEEE;
use IEEE.std_logic_1164.all;

ENTITY myDFF IS
PORT (
    clk : IN std_logic;   
    rst : IN std_logic;  
    enable : IN std_logic; 
    D : IN std_logic;     
    Q : OUT std_logic     
);
END myDFF;

ARCHITECTURE mybehavior OF myDFF IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        -- IF rst = '1' THEN
        --     Q <= '0';  
        -- ELS
        IF clk'event and clk = '0' THEN
            if rst = '1' then
                Q <= '0';
            elsIF enable = '1' THEN
                Q <= D;  
            END IF;
        END IF;
    END PROCESS;
END mybehavior;