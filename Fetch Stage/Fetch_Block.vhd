library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Fetch_Block is
    port (
        clk: in std_logic; -- Clock signal
        --control signals
        ret_rti_sig: in std_logic; 
        call_sig:    in std_logic;
        jmp_sig:     in std_logic;
        -- PC signals
        pc_en:      in std_logic;
        rst:        in std_logic;
        -- possible PCs
        call_and_jmp_pc: in std_logic_vector(15 downto 0);
        hazard_pc: in std_logic_vector(15 downto 0);
        ret_pc: in std_logic_vector(15 downto 0);

        --outputs of fetch stage
        current_pc: out std_logic_vector(15 downto 0); -- Current PC address
        next_pc: out std_logic_vector(15 downto 0); -- Next PC address
        instruction: out std_logic_vector(15 downto 0) -- Instruction output

    );
end Fetch_Block;

architecture Fetch_Block_arch OF Fetch_Block is

    COMPONENT PC IS 
        PORT(
            clk: in std_logic;
            pc_address_in: in std_logic_vector(15 downto 0);
            write_enable: in std_logic;
            rst: in std_logic;
            pc_address_out: out std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT Instruction_Memory IS
        PORT(
            clk: in std_logic;
            pc: in std_logic_vector(15 downto 0);
            instruction: out std_logic_vector(15 downto 0);
            write_enable: in std_logic;
            write_address: in std_logic_vector(15 downto 0);
            write_data: in std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT Mux8to1 IS
        PORT(
            input0: in std_logic_vector(15 downto 0);
            input1: in std_logic_vector(15 downto 0);
            input2: in std_logic_vector(15 downto 0);
            input3: in std_logic_vector(15 downto 0);
            input4: in std_logic_vector(15 downto 0);
            input5: in std_logic_vector(15 downto 0);
            input6: in std_logic_vector(15 downto 0);
            input7: in std_logic_vector(15 downto 0);
            selector: in std_logic_vector(2 downto 0);
            output: out std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    COMPONENT Adder IS
        PORT(
            input_value: in std_logic_vector(15 downto 0);
            immediate_value: in std_logic_vector(15 downto 0);
            result: out std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    signal pc_address_in_tmp: std_logic_vector(15 downto 0);
    signal pc_address_out_tmp: std_logic_vector(15 downto 0);
    signal instruction_tmp: std_logic_vector(15 downto 0);
    signal pc_address_out_mux: std_logic_vector(15 downto 0);
    signal next_pc_tmp: std_logic_vector(15 downto 0);
    signal int_pc: std_logic_vector(15 downto 0);
    signal INT_CTRL_sig: std_logic;
    signal mux_selector: std_logic_vector(2 downto 0);



begin

    INT_CTRL_sig <= '1' when (instruction_tmp(15 downto 11) = "11110") else '0';

    mux_selector <= INT_CTRL_sig & ret_rti_sig & (call_sig or jmp_sig);
    
    pc0: PC PORT MAP(
        clk => clk,
        pc_address_in => pc_address_out_mux,
        write_enable => pc_en,
        rst => rst,
        pc_address_out => pc_address_out_tmp
    ); 

    im0: Instruction_Memory PORT MAP(
        clk => clk,
        pc => pc_address_out_tmp,
        instruction => instruction_tmp,
        write_enable => '0',
        write_address => (others => '0'),
        write_data => (others => '0')
    );
    -- selector is INT_CTRL RET_RTI CALL_OR_JMP
    m0: Mux8to1 PORT MAP(
        input0 => next_pc_tmp, -- 000 :next pc
        input1 => call_and_jmp_pc, --001 call or jm
        input2 => ret_pc,         --010 ret
        input3 => (others => '0'), --011 don't care
        input4 => int_pc,     -- 100 INT
        input5 => hazard_pc,   -- 101 hazard , hazard selector is yet to be defined
        input6 => (others => '0'),
        input7 => (others => '0'),
        selector => mux_selector,
        output => pc_address_out_mux
    );

    a_int : Adder PORT MAP(
        input_value => pc_address_out_tmp,
        immediate_value => "0000000000000110",
        result => int_pc
    );
    a_next : Adder PORT MAP(
        input_value => pc_address_out_tmp,
        immediate_value => "0000000000000001",
        result => next_pc_tmp
    );
    -- assign the outputs
    current_pc <= pc_address_out_tmp;   
    next_pc <= next_pc_tmp;
    instruction <= instruction_tmp;

end Fetch_Block_arch;
