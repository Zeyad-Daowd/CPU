library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity whole_stage is
end entity whole_stage;
architecture arch_whole_stage of whole_stage is
    component my_nDFF IS
        GENERIC ( n : integer := 8);
        PORT(
            Clk, Rst, writeEN : IN std_logic;
            d : IN std_logic_vector(n-1 DOWNTO 0);
            q : OUT std_logic_vector(n-1 DOWNTO 0)
        );
    end component my_nDFF;

    component control_unit is 
        port (
            op_code: in std_logic_vector(4 downto 0);
            push_pop: out std_logic;
            int_or_rti: out std_logic;
            sp_wen: out std_logic;
            Mem_addr: out std_logic;
            zero_neg_flag_en: out std_logic;
            carry_flag_en: out std_logic;
            reg_write: out std_logic;
            is_jmp: out std_logic;
            mem_read: out std_logic;
            mem_write: out std_logic;
            imm_used: out std_logic;
            imm_loc: out std_logic;
            out_wen: out std_logic;
            from_in: out std_logic;
            mem_wr_data: out std_logic;
            alu_op_code: out std_logic_vector(2 downto 0);
            which_jmp: out std_logic_vector(1 downto 0)
        );
    end component control_unit;

    -- Signals
    signal pipe_1_in, pipe_1_out, pipe_2_in, pipe_2_out : std_logic_vector(7 downto 0) := (others => '0');
    signal my_clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal write_pipe_en : std_logic := '1';
    signal sim_op_code: std_logic_vector(4 downto 0) := (others => '0');
    signal sim_push_pop, sim_int_or_rti, sim_sp_wen, sim_Mem_addr: std_logic := '0';
    signal sim_zero_neg_flag_en, sim_carry_flag_en, sim_reg_write, sim_is_jmp: std_logic := '0';
    signal sim_mem_read, sim_mem_write, sim_imm_used, sim_imm_loc: std_logic := '0';
    signal sim_out_wen, sim_from_in, sim_mem_wr_data: std_logic := '0';
    signal sim_alu_op_code: std_logic_vector(2 downto 0) := (others => '0');
    signal sim_which_jmp: std_logic_vector(1 downto 0) := (others => '0');

    signal op_code_counter: integer := 0;

begin
    IF_ID: my_nDFF 
        port map(
            clk => my_clk, 
            Rst => rst, 
            writeEN => write_pipe_en, 
            d => pipe_1_in, 
            q => pipe_1_out
        );

    ID_EX: my_nDFF 
        port map(
            clk => my_clk, 
            Rst => rst, 
            writeEN => write_pipe_en, 
            d => pipe_2_in, 
            q => pipe_2_out
        );

    control: control_unit 
        port map(
            op_code => pipe_1_out(7 downto 3),
            push_pop => sim_push_pop,
            int_or_rti => sim_int_or_rti,
            sp_wen => sim_sp_wen,
            Mem_addr => sim_Mem_addr,
            zero_neg_flag_en => sim_zero_neg_flag_en,
            carry_flag_en => sim_carry_flag_en,
            reg_write => sim_reg_write,
            is_jmp => sim_is_jmp,
            mem_read => sim_mem_read,
            mem_write => sim_mem_write,
            imm_used => sim_imm_used,
            imm_loc => sim_imm_loc,
            out_wen => sim_out_wen,
            from_in => sim_from_in,
            mem_wr_data => sim_mem_wr_data,
            alu_op_code => sim_alu_op_code,
            which_jmp => sim_which_jmp
        );

    clk_process: process
    begin
        wait for 10 ns;  
        my_clk <= not my_clk;
    end process;

    test_process: process(my_clk)
    begin
        if falling_edge(my_clk) then
            if rst = '1' then
                pipe_1_in <= (others => '0');  
                op_code_counter <= 0;         
            else
                pipe_1_in(7 downto 3) <= std_logic_vector(to_unsigned(op_code_counter, 5));
                op_code_counter <= op_code_counter + 1;

                pipe_2_in(7) <= sim_push_pop;
                pipe_2_in(6) <= sim_int_or_rti;
                pipe_2_in(5) <= sim_sp_wen;
                pipe_2_in(4) <= sim_Mem_addr;
                pipe_2_in(3) <= sim_zero_neg_flag_en;
                pipe_2_in(2) <= sim_carry_flag_en;
                pipe_2_in(1) <= sim_reg_write;
                pipe_2_in(0) <= sim_is_jmp;

                if op_code_counter = 2**5 then
                    
                end if;
            end if;
        end if;
    end process;
end architecture;
