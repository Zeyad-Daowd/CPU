library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
ENTITY execute IS
    PORT(
        RegA, RegB    : IN std_logic_vector (15 DOWNTO 0);
        ALUop: IN std_logic_vector (2 DOWNTO 0);
        imm_used: IN std_logic;
        imm_loc: IN std_logic;
        imm_value: IN std_logic_vector (15 DOWNTO 0);
        memForward1, memForward2: IN std_logic;
        execForward1, execForward2: IN std_logic;
        memForwardData: IN std_logic_vector (15 DOWNTO 0);
        execForwardData: IN std_logic_vector (15 DOWNTO 0);
        fromIn: IN std_logic;
        inData: IN std_logic_vector (15 DOWNTO 0);
        dataBack, Rsrc1Forwarded       : OUT std_logic_vector (15 DOWNTO 0);
        isJump: in std_logic;
        clk, rst: in std_logic;
        whichJump: in std_logic_vector(1 DOWNTO 0); -- 00 = always, 01 = zero, 10 = negative, 11 = carry
        jumpFlag: OUT std_logic;
        carryFlagEn, zeroFlagEn, negativeFlagEn: in std_logic;
        RTI, set_C : in std_logic;
        carryFlagMem    : in std_logic;
        zeroFlagMem     : in std_logic;
        negativeFlagMem : in std_logic;
        carryFlagOutput, zeroFlagOutput, negativeFlagOutput : out std_logic
    );
END execute;

ARCHITECTURE arch1 OF execute IS
COMPONENT zeyad_DFF IS
    PORT (
        clk    : IN std_logic;   -- Clock input
        rst    : IN std_logic;   -- Reset input
        enable : IN std_logic;   -- Enable input
        D      : IN std_logic;   -- Data input
        Q      : OUT std_logic   -- Data output
    );
END COMPONENT;
component ALU IS
    PORT(
        RegA, RegB    : IN std_logic_vector (15 DOWNTO 0);
        selector: IN std_logic_vector (2 DOWNTO 0);
        aluRes       : OUT std_logic_vector (15 DOWNTO 0);
        carryFlag    : OUT std_logic;
        zeroFlag     : OUT std_logic;
        negativeFlag : OUT std_logic
    );
END component;
signal carryFlagALU, zeroFlagALU, negativeFlagALU : std_logic;
signal aluRes : std_logic_vector(15 DOWNTO 0);
signal aluin1, aluin2 : std_logic_vector(15 DOWNTO 0);
signal carryFlagEnable, zeroFlagEnable, negativeFlagEnable : std_logic;
signal carryFlagIN, zeroFlagIN, negativeFlagIN : std_logic;
signal carryFlagOUT, zeroFlagOUT, negativeFlagOUT : std_logic;
signal resetCarry, resetZero, resetNegative : std_logic;
BEGIN
    
    PROCESS (RegA, RegB, ALUop, imm_used, imm_loc, imm_value, memForward1, memForward2, execForward1, execForward2, memForwardData, execForwardData, fromIn, inData, isJump, whichJump, carryFlagEn, zeroFlagEn, negativeFlagEn, RTI, set_C, carryFlagMem, zeroFlagMem, negativeFlagMem, aluRes, negativeFlagOUT, zeroFlagOUT, carryFlagOUT, clk)
    BEGIN
    ----- setting ALU INPUTS
    if memForward1 = '1' then
        Rsrc1Forwarded <= memForwardData;
    elsif execForward1 = '1' then
        Rsrc1Forwarded <= execForwardData;
    else
        Rsrc1Forwarded <= RegA;
    end if;
    if ((not imm_loc) AND imm_used) = '1' then
        aluin1 <= imm_value;
    else 
        if memForward1 = '1' then
            aluin1 <= memForwardData;
        elsif execForward1 = '1' then
            aluin1 <= execForwardData;
        else
            aluin1 <= RegA;
        end if;
    end if;
    if (imm_loc AND imm_used) = '1' then
        aluin2 <= imm_value;
    else
        if memForward2 = '1' then
            aluin2 <= memForwardData;
        elsif execForward2 = '1' then
            aluin2 <= execForwardData;
        else
            aluin2 <= RegB;
        end if;
    end if;
    ----- setting databack
    if (fromIn = '1') then
        dataBack <= inData;
    else
        dataBack <= aluRes;
    end if;
   
    ----- setting flags enables
    carryFlagEnable <= carryFlagEn or RTI or set_C;
    zeroFlagEnable <= zeroFlagEn or RTI;
    negativeFlagEnable <= negativeFlagEn or RTI;
    ----- setting flags inputs
    carryFlagIN <= (RTI and carryFlagMem) or (not RTI and carryFlagALU) or set_C;
    zeroFlagIN <= (RTI and zeroFlagMem) or (not RTI and zeroFlagALU);
    negativeFlagIN <= (RTI and negativeFlagMem) or (not RTI and negativeFlagALU);
    ----- setting flags outputs
    carryFlagOutput <= carryFlagOUT;
    zeroFlagOutput <= zeroFlagOUT;
    negativeFlagOutput <= negativeFlagOUT;
    ---- resetting after jumpCondition
    if rising_edge(clk) then
        if (isJump = '1' and whichJump = "01" and zeroFlagOUT = '1') then
            resetZero <= '1';
        else
            resetZero <= '0';
        end if;
        if (isJump = '1' and whichJump = "10" and negativeFlagOUT = '1') then
            resetNegative <= '1';
        else
            resetNegative <= '0';
        end if;
        if (isJump = '1' and whichJump = "11" and carryFlagOUT = '1') then
            resetCarry <= '1';
        else
            resetCarry <= '0';
        end if;
    end if;
    ---- setting jumpCondition

    if (isJump = '1') then
        case whichJump is
            when "00" =>
                jumpFlag <= '1';
            when "01" =>
                if zeroFlagOUT = '1' then
                    jumpFlag <= '1';
                else
                    jumpFlag <= '0';
                end if;
            when "10" =>
                if negativeFlagOUT = '1' then
                    jumpFlag <= '1';
                else
                    jumpFlag <= '0';
                end if;

            when "11" =>
                if carryFlagOUT = '1' then
                    jumpFlag <= '1';
                else
                    jumpFlag <= '0';
                end if;
            when others =>
                jumpFlag <= '0';
        end case;
    else
        jumpFlag <= '0';
    end if;
    
END PROCESS;
ALU_component: ALU PORT MAP(
    RegA => aluin1,
    RegB => aluin2,
    selector => ALUop,
    aluRes => aluRes,
    carryFlag => carryFlagALU,
    zeroFlag => zeroFlagALU,
    negativeFlag => negativeFlagALU
);
zeroflag_Register: zeyad_DFF PORT MAP(
    clk => clk,
    rst => resetZero,
    enable => zeroFlagEnable,
    D => zeroFlagIN,
    Q => zeroFlagOUT
);
carryflag_Register: zeyad_DFF PORT MAP(
    clk => clk,
    rst => resetCarry,
    enable => carryFlagEnable,
    D => carryFlagIN,
    Q => carryFlagOUT
);
negativeflag_Register: zeyad_DFF PORT MAP(
    clk => clk,
    rst => resetNegative,
    enable => negativeFlagEnable,
    D => negativeFlagIN,
    Q => negativeFlagOUT
);
END arch1;
