library IEEE;
use IEEE.std_logic_1164.all;

ENTITY zeyad_DFF IS
PORT (
    clk : IN std_logic;   
    rst : IN std_logic;  
    enable : IN std_logic; 
    D : IN std_logic;     
    Q : OUT std_logic     
);
END zeyad_DFF;

ARCHITECTURE mybehavior OF zeyad_DFF IS
signal Q_temp : std_logic := '0';
BEGIN

    Q <= Q_temp; 
    PROCESS (clk, rst)
    BEGIN
        -- IF rst = '1' THEN
        --     Q <= '0';  
        -- ELS
        IF clk'event and clk = '0' THEN
            if rst = '1' then
                Q_temp <= '0';
            elsIF enable = '1' THEN
                Q_temp <= D;  
            END IF;
        END IF;
    END PROCESS;
END mybehavior;