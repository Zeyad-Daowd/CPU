library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
ENTITY Fetch_Stage is 
    PORT(
        clk: IN std_logic;
        ret_rti_sig: IN std_logic;
        call_sig: IN std_logic;
        jmp_sig: IN std_logic;
        hazard_sig: IN std_logic;
        exception_sig: IN std_logic_vector(1 DOWNTO 0);
        --pc_en: IN std_logic;
        rst: IN std_logic;
        call_and_jmp_pc: IN std_logic_vector(15 DOWNTO 0);
        ret_pc: IN std_logic_vector(15 DOWNTO 0);
        im_write_enable: IN std_logic;
        im_write_address: IN std_logic_vector(15 DOWNTO 0);
        im_write_data: IN std_logic_vector(15 DOWNTO 0);
        --
        out_fetch: OUT std_logic_vector(47 DOWNTO 0)
    );
END Fetch_Stage;
ARCHITECTURE Fetch_Stage_arch of Fetch_Stage is
COMPONENT Fetch_Block IS
    PORT(
        clk: IN std_logic;
        ret_rti_sig: IN std_logic;
        call_sig: IN std_logic;
        jmp_sig: IN std_logic;
        hazard_sig: IN std_logic;
        exception_sig: IN std_logic_vector(1 DOWNTO 0);
        rst: IN std_logic;
        pc_en: IN std_logic;
        call_and_jmp_pc: IN std_logic_vector(15 DOWNTO 0);
        ret_pc: IN std_logic_vector(15 DOWNTO 0);
        im_write_enable: IN std_logic;
        im_write_address: IN std_logic_vector(15 DOWNTO 0);
        im_write_data: IN std_logic_vector(15 DOWNTO 0);
        current_pc: OUT std_logic_vector(15 DOWNTO 0);
        next_pc: OUT std_logic_vector(15 DOWNTO 0);
        instruction: OUT std_logic_vector(15 DOWNTO 0)
    );
END COMPONENT;
COMPONENT my_nDFF
    GENERIC(
        n: INTEGER := 8
    );
    PORT(
        Clk, Rst, writeEN: IN std_logic;
        d: IN std_logic_vector(n-1 DOWNTO 0);
        q: OUT std_logic_vector(n-1 DOWNTO 0)
    );
END COMPONENT;

signal in_fetch_reg : std_logic_vector(47 DOWNTO 0);
signal fetch_current_pc : std_logic_vector(15 DOWNTO 0);
signal fetch_next_pc : std_logic_vector(15 DOWNTO 0);
signal fetch_instruction : std_logic_vector(15 DOWNTO 0);
begin
    in_fetch_reg <= fetch_instruction & fetch_current_pc & fetch_next_pc;
    Fetch_Block_inst: Fetch_Block PORT MAP(
        clk => clk,
        ret_rti_sig => ret_rti_sig,
        call_sig => call_sig,
        jmp_sig => jmp_sig,
        hazard_sig => hazard_sig,
        exception_sig => exception_sig,
        rst => rst,
        pc_en => '1',
        call_and_jmp_pc => call_and_jmp_pc,
        ret_pc => ret_pc,
        im_write_enable => im_write_enable,
        im_write_address => im_write_address,
        im_write_data => im_write_data,
        current_pc => fetch_current_pc,
        next_pc => fetch_next_pc,
        instruction => fetch_instruction
    );
    my_nDFF_inst: my_nDFF GENERIC MAP(
        n => 48
    ) PORT MAP(
        Clk => clk,
        Rst => rst,
        writeEN => '1',
        d => in_fetch_reg,
        q => out_fetch
    );

end Fetch_Stage_arch;
