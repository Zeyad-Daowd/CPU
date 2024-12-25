library IEEE;
use IEEE.std_logic_1164.all;

ENTITY hazardUnit IS
PORT (
    memRead, ret_or_rti_hazard : IN std_logic;   -- from execute reg i guess
    Rdst : IN std_logic_vector (2 DOWNTO 0); -- from execute reg
    Rsrc1, Rsrc2 : IN std_logic_vector (2 DOWNTO 0);  -- from decode reg
    Rsrc1Used, Rsrc2Used : IN std_logic; -- from decoder
    hazard_detected : OUT std_logic     
);
END hazardUnit;

ARCHITECTURE mybehavior OF hazardUnit IS
BEGIN
    PROCESS (memRead, Rdst, Rsrc1, Rsrc2, Rsrc1Used, Rsrc2Used, ret_or_rti_hazard)
    BEGIN
        if (memRead = '1' and ret_or_rti_hazard = '0' AND ((Rdst = Rsrc1 and Rsrc1Used = '1') OR (Rdst = Rsrc2 and Rsrc2Used = '1'))) then
            hazard_detected <= '1';
        else
            hazard_detected <= '0';
        end if;
    END PROCESS;
END mybehavior;