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
        hazard_sig:  in std_logic;
        exception_sig: in std_logic_vector(1 downto 0);

        -- PC signals
        pc_en:      in std_logic; --unused now
        rst:        in std_logic;
        -- possible PCs
        call_and_jmp_pc: in std_logic_vector(15 downto 0);
        ret_pc: in std_logic_vector(15 downto 0);

        -- writing to instruction memory
        im_write_enable: in std_logic;
        im_write_address: in std_logic_vector(15 downto 0);
        im_write_data: in std_logic_vector(15 downto 0);

        --outputs of fetch stage
        current_pc: out std_logic_vector(15 downto 0); -- Current PC address
        next_pc: out std_logic_vector(15 downto 0); --  PC+1 address
        instruction: out std_logic_vector(15 downto 0) -- Instruction output

    );
end Fetch_Block;

architecture Fetch_Block_arch OF Fetch_Block is

    COMPONENT hana_reg IS 
        PORT(
            clk: in std_logic;
            reg_write_enable: in std_logic;
            reg_write_data: in std_logic_vector(15 downto 0);
            reg_data_out: out std_logic_vector(15 downto 0)
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


    COMPONENT Adder IS
        PORT(
            input_value: in std_logic_vector(15 downto 0);
            immediate_value: in std_logic_vector(15 downto 0);
            result: out std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    signal pc_address_in_tmp: std_logic_vector(15 downto 0) := (others => '0');
    signal pc_address_out_tmp: std_logic_vector(15 downto 0);
    signal instruction_tmp: std_logic_vector(15 downto 0);
    signal next_pc_tmp: std_logic_vector(15 downto 0);
    signal int_pc: std_logic_vector(15 downto 0);
    signal INT_CTRL_sig: std_logic;
    signal HLT : std_logic;
    signal index: std_logic_vector(15 downto 0);



begin

    INT_CTRL_sig <= '1' when (instruction_tmp(15 downto 11) = "11110" and rst ='0') else '0';
    HLT <= '1' when (instruction_tmp(15 downto 11) = "00001" and rst = '0') else '0';
    index <= "0000000000000010" when instruction_tmp(7) = '1' else "0000000000000000";

    process(call_sig, jmp_sig, ret_rti_sig, INT_CTRL_sig, HLT, hazard_sig, exception_sig, rst, pc_address_in_tmp,pc_address_out_tmp, next_pc_tmp, call_and_jmp_pc, ret_pc, int_pc, clk)
    begin
        --choosing a pc
        if (call_sig = '1' or jmp_sig = '1') then
            pc_address_in_tmp <= call_and_jmp_pc;
        elsif (ret_rti_sig = '1') then
            pc_address_in_tmp <= ret_pc;
        elsif (INT_CTRL_sig = '1') then
            pc_address_in_tmp <= int_pc;
        elsif (rst = '1') then --rst
            pc_address_in_tmp <= "0000000000000000"; 
        elsif (HLT = '1' or hazard_sig = '1') then --hlt or stall when hazard
            pc_address_in_tmp <= pc_address_out_tmp;
        elsif (exception_sig = "01") then 
            pc_address_in_tmp <= "0000000000000011";
        elsif (exception_sig = "10") then 
            pc_address_in_tmp <= "0000000000000010";
        else
            pc_address_in_tmp <= next_pc_tmp; --pc=pc+1
        end if;
    end process;


    
    pc0: hana_reg PORT MAP(
        clk => clk,
        reg_write_enable => '1',
        reg_write_data => pc_address_in_tmp,
        reg_data_out => pc_address_out_tmp
    );

    im0: Instruction_Memory PORT MAP(
        clk => clk,
        pc => pc_address_out_tmp,
        instruction => instruction_tmp,
        write_enable => im_write_enable,
        write_address => im_write_address,
        write_data => im_write_data
    );
 
    a_int : Adder PORT MAP(
        input_value => index,
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
    next_pc <= next_pc_tmp; --pc+1
    instruction <= instruction_tmp;

end Fetch_Block_arch;
