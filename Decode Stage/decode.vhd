library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
    port (
        clk : in std_logic; 
        wb_reg_write: in std_logic;
        pipe_IF_out : in  std_logic_vector(4 downto 0); 
        in_read_addr_1: in std_logic_vector(2 downto 0); 
        in_read_addr_2: in std_logic_vector(2 downto 0); 
        in_write_addr: in std_logic_vector(2 downto 0);  
        in_write_data: in std_logic_vector(15 downto 0); 
        sp_plus_minus, sp_chosen: out std_logic_vector(15 downto 0);
        decode_push_pop: out std_logic;
        decode_int_or_rti: out std_logic;
        decode_sp_wen: out std_logic;
        decode_Mem_addr: out std_logic;
        decode_zero_neg_flag_en: out std_logic;
        decode_carry_flag_en: out std_logic;
        decode_reg_write: out std_logic;
        decode_is_jmp: out std_logic;
        decode_mem_read: out std_logic;
        decode_mem_write: out std_logic;
        decode_imm_used: out std_logic;
        decode_imm_loc: out std_logic;
        decode_out_wen: out std_logic;
        decode_from_in: out std_logic;
        decode_mem_wr_data: out std_logic;
        decode_call: out std_logic;
        decode_ret: out std_logic;
        decode_int: out std_logic;
        decode_rti: out std_logic;
        decode_ret_or_rti: out std_logic;
        decode_alu_op_code: out std_logic_vector(2 downto 0);
        decode_which_jmp: out std_logic_vector(1 downto 0);
        decode_which_r_src: out std_logic_vector(1 downto 0);
        out_read_data_1: out std_logic_vector(15 downto 0); 
        out_read_data_2: out std_logic_vector(15 downto 0)
    );
end entity decode;
architecture arch_decode of decode is
    component reg is
        port (
            clk : in std_logic;
            reg_write_enable : in std_logic;
            reg_write_data : in std_logic_vector(15 downto 0);
            reg_data_out : out std_logic_vector(15 downto 0)
        );
    end component reg;

    component mux2to1 is
        port (
            choice_1 : in std_logic_vector(15 downto 0);
            choice_2: in std_logic_vector(15 downto 0);
            sel: in std_logic;
            selected: out std_logic_vector(15 downto 0)
        );
    end component mux2to1;

    component Add_signed is
        port (
            data_in: in std_logic_vector(15 downto 0);
            added_bit: in std_logic_vector(15 downto 0);
            data_out: out std_logic_vector(15 downto 0)
        );
    end component Add_signed;

    component Register_File is 
        port (
            clk: in std_logic;
            reg_write: in std_logic;
            read_addr_1: in std_logic_vector(2 downto 0);
            read_addr_2: in std_logic_vector(2 downto 0);
            write_addr: in std_logic_vector(2 downto 0);
            write_data: in std_logic_vector(15 downto 0);
            read_data_1: out std_logic_vector(15 downto 0);
            read_data_2: out std_logic_vector(15 downto 0)
        );
    end component Register_File;

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
            call: out std_logic;
            ret: out std_logic;
            int: out std_logic;
            rti: out std_logic;
            ret_or_rti: out std_logic;
            alu_op_code: out std_logic_vector(2 downto 0);
            which_jmp: out std_logic_vector(1 downto 0);
            which_r_src: out std_logic_vector(1 downto 0)
        );
    end component control_unit;

    -- Signals    
    signal my_clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal write_pipe_en : std_logic := '1';
    
    -- control unit signals --
    signal sim_rti, sim_int_or_rti, sim_push_pop, sim_sp_wen: std_logic := '0';
    signal op_code_counter: integer := 0;

    -- sp signals --
    signal plus_minus_res :  std_logic_vector(15 downto 0) := (others => '0');
    signal add_first_res, add_sec_res : std_logic_vector(15 downto 0) := (others => '0');
    signal one : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal neg_one : std_logic_vector(15 downto 0) := (others => '1');
    signal sp_data_in, sp_data_out : std_logic_vector(15 downto 0) := (others => '0');

begin
    decode_int_or_rti <= sim_int_or_rti;
    decode_rti <= sim_rti;
    decode_push_pop <= sim_push_pop;
    decode_sp_wen <= sim_sp_wen;

    sp: reg
        port map (
            clk => my_clk,
            reg_write_enable => sim_sp_wen,
            reg_write_data => sp_data_in,
            reg_data_out => sp_data_out
        );
    
    mux_plus_minus: mux2to1
        port map (
            choice_1 => one,
            choice_2 => neg_one,
            sel => sim_push_pop,
            selected => plus_minus_res
        );

    add_first: Add_signed
        port map (
            data_in => sp_data_out,
            added_bit => plus_minus_res,
            data_out => add_first_res
        );

    add_sec: Add_signed
        port map (
            data_in => add_first_res,
            added_bit => plus_minus_res,
            data_out => add_sec_res
        );

    mux_plus_minus_2: mux2to1
        port map (
            choice_1 => add_first_res,
            choice_2 => add_sec_res,
            sel => sim_int_or_rti,
            selected => sp_data_in
        );
    
    mux_sp_sp_plus_2: mux2to1
        port map (
            choice_1 => sp_data_out,
            choice_2 => add_sec_res,
            sel => sim_rti,
            selected => sp_chosen
        );

    reg_file : Register_File port map (
        clk => clk,
        reg_write => wb_reg_write,
        read_addr_1 => in_read_addr_1, 
        read_addr_2 => in_read_addr_2,
        write_addr => in_write_addr,
        write_data => in_write_data,
        read_data_1 => out_read_data_1,
        read_data_2 => out_read_data_2
    );
    
    control: control_unit 
        port map(
            op_code => pipe_IF_out,
            push_pop => sim_push_pop,
            int_or_rti => sim_int_or_rti,
            sp_wen => sim_sp_wen,
            Mem_addr => decode_Mem_addr,
            zero_neg_flag_en => decode_zero_neg_flag_en,
            carry_flag_en => decode_carry_flag_en,
            reg_write => decode_reg_write,
            is_jmp => decode_is_jmp,
            mem_read => decode_mem_read,
            mem_write => decode_mem_write,
            imm_used => decode_imm_used,
            imm_loc => decode_imm_loc,
            out_wen => decode_out_wen,
            from_in => decode_from_in,
            mem_wr_data => decode_mem_wr_data,
            call => decode_call,
            ret => decode_ret,
            int => decode_int,
            rti => sim_rti,
            alu_op_code => decode_alu_op_code,
            which_jmp => decode_which_jmp,
            which_r_src => decode_which_r_src
        );

end architecture;