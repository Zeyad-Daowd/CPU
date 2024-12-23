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
        latest_bit: in std_logic;
        jump_from_exec: in std_logic;
        sp_first, sp_second, sp_required: out std_logic_vector(15 downto 0);
        decode_push_pop: out std_logic;
        decode_int_or_rti: out std_logic;
        decode_sp_wen: out std_logic;
        decode_Mem_addr: out std_logic;
        decode_zero_neg_flag_en: out std_logic;
        decode_carry_flag_en: out std_logic;
        decode_set_carry: out std_logic;
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
        decode_push: out std_logic; 
        decode_pop: out std_logic; 
        decode_mem_to_reg: out std_logic; 
        decode_write_enable_ex_mem_pipe: out std_logic; --
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
            set_carry: out std_logic;
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
            push: out std_logic;
            pop: out std_logic; 
            mem_to_reg: out std_logic; 
            alu_op_code: out std_logic_vector(2 downto 0);
            which_jmp: out std_logic_vector(1 downto 0);
            which_r_src: out std_logic_vector(1 downto 0)
        );
    end component control_unit;

    -- Signals    
    signal rst: std_logic := '0';
    signal write_pipe_en : std_logic := '1';
    
    -- control unit signals --
    signal sim_int_or_rti, sim_push_pop, sim_sp_wen: std_logic := '0';
    signal op_code_counter: integer := 0;

    -- sp signals --
    signal plus_minus_res :  std_logic_vector(15 downto 0) := (others => '0');
    signal add_first_res, add_sec_res : std_logic_vector(15 downto 0) := (others => '0');
    signal one : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal neg_one : std_logic_vector(15 downto 0) := (others => '1');
    signal sp_data_in, sp_data_out : std_logic_vector(15 downto 0) := "0000111111111111";
    signal sp_mux_sel_fatma : std_logic := '0';
    signal sp_read : std_logic_vector(15 downto 0) := "0000111111111111";

    -- stall and flush signals --
    signal counter_flush : std_logic_vector(1 downto 0) := (others => '0');
    signal local_decode_int, local_decode_call, local_decode_ret,
        local_decode_rti, local_decode_Mem_addr, local_decode_zero_neg_flag_en,
        local_decode_carry_flag_en, local_decode_set_carry, local_decode_reg_write,
        local_decode_is_jmp, local_decode_mem_read, local_decode_mem_write,
        local_decode_imm_used, local_decode_imm_loc, local_decode_out_wen,
        local_decode_from_in, local_decode_mem_wr_data, local_decode_ret_or_rti,
        local_decode_push, local_decode_pop, local_decode_mem_to_reg: std_logic := '0';
    signal local_decode_alu_op_code : std_logic_vector(2 downto 0) := (others => '0');
    signal local_decode_which_jmp, local_decode_which_r_src : std_logic_vector(1 downto 0) := (others => '0');
    signal decode_write_enable_ex_mem_pipe_sig: std_logic := '1';
    signal flush_condition: std_logic := '1';  
    signal sp_sim_write_for_exception : std_logic := '0';


begin
    
    flush_condition <= '1' when (counter_flush = "00" and jump_from_exec = '0') else '0';  
    decode_int_or_rti <= sim_int_or_rti and flush_condition;
    decode_push_pop <= sim_push_pop and flush_condition;
    sp_sim_write_for_exception <= sim_sp_wen and flush_condition;
    decode_sp_wen <= sim_sp_wen and flush_condition;
    decode_int <= local_decode_int and flush_condition;
    decode_call <= local_decode_call and flush_condition;
    decode_ret <= local_decode_ret and flush_condition;
    decode_rti <= local_decode_rti and flush_condition;
    decode_write_enable_ex_mem_pipe <= decode_write_enable_ex_mem_pipe_sig;
    decode_Mem_addr <= local_decode_Mem_addr and flush_condition;
    decode_zero_neg_flag_en <= local_decode_zero_neg_flag_en and flush_condition;
    decode_carry_flag_en <= local_decode_carry_flag_en and flush_condition;
    decode_set_carry <= local_decode_set_carry and flush_condition;
    decode_reg_write <= local_decode_reg_write and flush_condition;                                  
    decode_is_jmp <= local_decode_is_jmp and flush_condition;
    decode_mem_read <= local_decode_mem_read and flush_condition;
    decode_mem_write <= local_decode_mem_write and flush_condition;
    decode_imm_used <= local_decode_imm_used and flush_condition;
    decode_imm_loc <= local_decode_imm_loc and flush_condition;
    decode_out_wen <= local_decode_out_wen and flush_condition;
    decode_from_in <= local_decode_from_in and flush_condition;
    decode_mem_wr_data <= local_decode_mem_wr_data and flush_condition;
    decode_call <= local_decode_call and flush_condition;
    decode_ret <= local_decode_ret and flush_condition;
    decode_int <= local_decode_int and flush_condition;
    decode_rti <= local_decode_rti and flush_condition;
    decode_ret_or_rti <= local_decode_ret_or_rti and flush_condition;
    decode_push <= local_decode_push and flush_condition;
    decode_pop <= local_decode_pop and flush_condition;
    decode_mem_to_reg <= local_decode_mem_to_reg and flush_condition;
    decode_alu_op_code <= local_decode_alu_op_code when counter_flush = "00" else (others => '0');
    decode_which_jmp <= local_decode_which_jmp when counter_flush = "00" else (others => '0');
    decode_which_r_src <= local_decode_which_r_src when counter_flush = "00" else (others => '0');

    sp_mux_sel_fatma <= local_decode_push or local_decode_call or local_decode_int;
    sp_required <= sp_read;
    decode_write_enable_ex_mem_pipe_sig <= '1' when (counter_flush = "00" or counter_flush = "11") else '0';
    
    process (clk)
    begin
        if rising_edge(clk) then
            sp_read <= sp_data_out;
            if jump_from_exec = '1' then
                counter_flush <= "00";
            elsif counter_flush = "00" then
                -- decode_write_enable_ex_mem_pipe_sig <= '1';
                if local_decode_int = '1' or local_decode_call = '1' or latest_bit = '1' then
                    counter_flush <= "01";
                elsif local_decode_ret = '1' or local_decode_rti = '1' then
                    counter_flush <= "11";
                end if;
            elsif counter_flush = "01" or counter_flush = "10" then
                -- decode_write_enable_ex_mem_pipe_sig <= '0';
                counter_flush <= std_logic_vector(to_unsigned(to_integer(unsigned(counter_flush)) - 1, counter_flush'length));
            else
                counter_flush <= std_logic_vector(to_unsigned(to_integer(unsigned(counter_flush)) - 1, counter_flush'length));
            end if;
        end if;
    end process;


    
    sp: reg
        port map (
            clk => clk,
            reg_write_enable => sp_sim_write_for_exception,
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
            data_in => sp_read,
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

    mux_sp_first: mux2to1
        port map (
            choice_1 => add_first_res,
            choice_2 => sp_read,
            sel => sp_mux_sel_fatma,  
            selected => sp_first
        );

    mux_sp_second: mux2to1
        port map (
            choice_1 => add_sec_res,
            choice_2 => add_first_res,
            sel => sp_mux_sel_fatma,  
            selected => sp_second
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
            Mem_addr => local_decode_Mem_addr,
            zero_neg_flag_en => local_decode_zero_neg_flag_en,
            carry_flag_en => local_decode_carry_flag_en,
            set_carry => local_decode_set_carry,
            reg_write => local_decode_reg_write,                                  
            is_jmp => local_decode_is_jmp,
            mem_read => local_decode_mem_read,
            mem_write => local_decode_mem_write,
            imm_used => local_decode_imm_used,
            imm_loc => local_decode_imm_loc,
            out_wen => local_decode_out_wen,
            from_in => local_decode_from_in,
            mem_wr_data => local_decode_mem_wr_data,
            call => local_decode_call,
            ret => local_decode_ret,
            int => local_decode_int,
            rti => local_decode_rti,
            ret_or_rti => local_decode_ret_or_rti,
            push => local_decode_push,
            pop => local_decode_pop,
            mem_to_reg => local_decode_mem_to_reg,
            alu_op_code => local_decode_alu_op_code,
            which_jmp => local_decode_which_jmp,
            which_r_src => local_decode_which_r_src
        );

end architecture;