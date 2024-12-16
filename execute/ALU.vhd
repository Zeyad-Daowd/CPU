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
BEGIN
PROCESS(RegA, RegB, selector)
BEGIN
    case selector IS
    WHEN "000" => -- PASS
        aluRes <= RegA;
        carryFlag <= '0';
        zeroFlag <= '0';
        negativeFlag <= '0';
    WHEN "001" => -- NOT
        aluRes <= not RegA;
        if RegA = "0000000000000000" then
            zeroFlag <= '1';
        ELSE
            zeroFlag <= '0';
        END IF;
        carryFlag <= '0';
        if(RegA(15) = '1') then
            negativeFlag <= '0';
        ELSE
            negativeFlag <= '1';
        END IF;
    WHEN "010" => -- INCR
        aluRes <= std_logic_vector(unsigned(RegA) + to_unsigned(1, 16));
        if RegA = "1111111111111111" then
            carryFlag <= '1';
            zeroFlag <= '0';
            negativeFlag <= '0';
        ELSE
            carryFlag <= '0';
            zeroFlag <= '0';
            if(RegA < "0111111111111111") then
                negativeFlag <= '0';
            ELSE
                negativeFlag <= '1';
            END IF;
        END IF;
        
    WHEN "011" => -- ADD
        aluRes <= std_logic_vector(unsigned(RegA) + unsigned(RegB));
        if std_logic_vector(unsigned(RegA) + unsigned(RegB)) = "0000000000000000" then
        zeroFlag <= '1';
        ELSE
        zeroFlag <= '0';
        END IF;
        if  (unsigned(RegA) + unsigned(RegB) > ("0111111111111111")) then
            negativeFlag <= '1';
        ELSE
            negativeFlag <= '0';
        END IF;
        if (unsigned(RegA) + unsigned(RegB) > ("1111111111111111")) then
            carryFlag <= '1';
        ELSE
            carryFlag <= '0';
        END IF;

    WHEN "100" => -- SUB
        aluRes <= std_logic_vector(unsigned(RegA) - unsigned(RegB));
        if std_logic_vector(unsigned(RegA) - unsigned(RegB)) = "0000000000000000" then
            zeroFlag <= '1';
        ELSE
            zeroFlag <= '0';
        END IF;
        if (unsigned(RegA) - unsigned(RegB) > ("0111111111111111")) then
            negativeFlag <= '1';
        ELSE
            negativeFlag <= '0';
        END IF;
        if unsigned(RegB) > unsigned(RegA) then
            carryFlag <= '1';
        ELSE
            carryFlag <= '0';
        END IF;
    WHEN "101" => -- AND
        carryFlag <= '0';
        aluRes <= RegA and RegB;
        if (RegA and RegB) = "0000000000000000" then
            zeroFlag <= '1';
        ELSE
            zeroFlag <= '0';
        END IF;
        if (RegA and RegB) > "0111111111111111" then
            negativeFlag <= '1';
        ELSE
            negativeFlag <= '0';
        END IF;
    when others =>
        aluRes <= (others => '0');
        carryFlag <= '0';
        zeroFlag <= '0';
        negativeFlag <= '0';
    END CASE;
END PROCESS;
END arch1;
