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
        if rst = '1' then
				Q_temp <= '0';
        end if;
        if falling_edge(clk) THEN
            -- if rst = '1' then
            --    Q_temp <= '0';
            -- els
            if enable = '1' THEN
                Q_temp <= D;  
            END IF;
        end if;
    END PROCESS;
END mybehavior;