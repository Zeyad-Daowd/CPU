library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is 
    port (
        in_peripheral: in std_logic_vector(15 downto 0);
        out_peripheral: out std_logic_vector(15 downto 0)
    );
end entity processor;

architecture arch_processor of processor is
    component my_nDFF IS
        generic ( n : integer := 8);
        port(
            Clk, Rst, writeEN : in std_logic;
            d : in std_logic_vector(n-1 downto 0);
            q : out std_logic_vector(n-1 downto 0)
        );
    end component my_nDFF;

    component Fetch_Block is
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
    
            -- outputs of fetch stage
            current_pc: out std_logic_vector(15 downto 0); -- Current PC address
            next_pc: out std_logic_vector(15 downto 0); --  PC+1 address
            instruction: out std_logic_vector(15 downto 0) -- Instruction output
    
        );
    end component Fetch_Block;

    component decode is
        port (
            clk : in std_logic; --
            wb_reg_write: in std_logic; --
            pipe_IF_out : in  std_logic_vector(4 downto 0); --
            in_read_addr_1: in std_logic_vector(2 downto 0); --
            in_read_addr_2: in std_logic_vector(2 downto 0); --
            in_write_addr: in std_logic_vector(2 downto 0); -- 
            in_write_data: in std_logic_vector(15 downto 0); --
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
            out_read_data_1: out std_logic_vector(15 downto 0); --
            out_read_data_2: out std_logic_vector(15 downto 0) --
        );
    end component decode;
    -- TODO: to be removed signals 
    -- simulating clock -- 
    signal my_clk: std_logic := '0';
    -- simulating hazards and exceptions 
    signal eden_hazard: std_logic := '0';
    signal exception_sig: std_logic_vector(1 downto 0) := (others => '0');
    -- simulating data from wb stage
    signal write_addr_from_wb : std_logic_vector(2 downto 0);
    signal write_data_from_wb : std_logic_vector(15 downto 0);
    signal reg_write_from_wb: std_logic; -- TODO: come from wb
    -- simulating data from IF stage
    signal immediate: std_logic_vector(15 downto 0) := (others => '0');
    -- simulating IDIE
    signal temp_idie: std_logic_vector(113 downto 0) := (others => '0');

        -----------------------------------------------------------------------
    signal fetch_pc, fetch_next_pc, fetch_instruction : std_logic_vector(15 downto 0);
        ----------------------------- IFID pipeline -----------------------------
    signal d_ifid : std_logic_vector(47 downto 0);
    signal q_ifid: std_logic_vector(47 downto 0) := (others => '0');
    --------------------------------- Decode Signals ----------------------------
    signal decode_pc, decode_next_pc, decode_instruction : std_logic_vector(15 downto 0);
    signal out_decode_push_pop, out_decode_int_or_rti, out_decode_sp_wen, out_decode_Mem_addr, out_decode_zero_neg_flag_en,
                out_decode_carry_flag_en, out_decode_reg_write, out_decode_is_jmp, out_decode_mem_read,
                out_decode_mem_write, out_decode_imm_used, out_decode_imm_loc, out_decode_out_wen, out_decode_from_in, out_decode_mem_wr_data,
                out_decode_call, out_decode_ret, out_decode_int,out_decode_rti,
                out_decode_ret_or_rti : std_logic := '0';

    signal out_decode_which_r_src, out_decode_which_jmp : std_logic_vector(1 downto 0);
    signal out_decode_alu_op_code : std_logic_vector(2 downto 0);
    signal out_decode_sp_plus_minus, out_decode_sp_chosen,out_decode_read_data_1, out_decode_read_data_2: std_logic_vector(15 downto 0);
        ----------------------------- IDIE pipeline -----------------------------
    signal d_idie : std_logic_vector(161 downto 0);
    signal q_idie: std_logic_vector(161 downto 0) := (others => '0');
    --------------------------------- Execute Signals ----------------------------
    
    signal reset : std_logic := '0'; -- TODO: handle this
    
    begin
        my_clk_process: process begin
            wait for 10 ns;
            my_clk <= not my_clk;
        end process;

        d_ifid <= fetch_pc & fetch_next_pc & fetch_instruction;

        q_ifid <= decode_pc & decode_next_pc & decode_instruction;

        d_idie <= (
            out_decode_push_pop & out_decode_int_or_rti & out_decode_sp_wen & out_decode_Mem_addr & out_decode_zero_neg_flag_en &
            out_decode_carry_flag_en & out_decode_reg_write & out_decode_is_jmp & out_decode_mem_read &
            out_decode_mem_write & out_decode_imm_used & out_decode_imm_loc & out_decode_out_wen & out_decode_from_in & out_decode_mem_wr_data
            & out_decode_call & out_decode_ret & out_decode_int & out_decode_rti & out_decode_ret_or_rti
            & out_decode_alu_op_code & out_decode_which_r_src
            & out_decode_sp_chosen & out_decode_sp_plus_minus 
            & decode_pc & decode_next_pc
            & decode_instruction(10 downto 8) & decode_instruction(7 downto 5) &  decode_instruction(4 downto 2) 
            & out_decode_read_data_1 & out_decode_read_data_2
            & immediate
            & in_peripheral
        );

        q_idie <= decode_pc & decode_next_pc & decode_instruction & temp_idie;

        fetch_stage: Fetch_Block port map (
            clk => my_clk,
            ret_rti_sig => out_decode_ret_or_rti,
            call_sig => out_decode_call,
            jmp_sig => out_decode_is_jmp, -- TODO: as far as I see, jump is from ex
            hazard_sig => eden_hazard,
            exception_sig => exception_sig,
            pc_en => '1', -- unused now
            rst => reset,
            call_and_jmp_pc => (others => '0'), -- TODO: handle this
            ret_pc => (others => '0'), -- TODO: handle this
            im_write_enable => '0', -- TODO: handle this
            im_write_address => (others => '0'), -- TODO: handle this
            im_write_data => (others => '0'), -- TODO: handle this
            current_pc => fetch_pc,
            next_pc => fetch_next_pc,
            instruction => fetch_instruction 
        );

        If_ID: my_nDFF generic map (48) port map (
            Clk => my_clk,
            Rst => '0',
            writeEN => '1',
            d => d_ifid,
            q => q_ifid
        );

        decode_stage: decode port map ( 
            clk => my_clk,
            wb_reg_write => reg_write_from_wb, -- TODO: come from wb
            pipe_IF_out => decode_instruction(15 downto 11),
            in_read_addr_1 => decode_instruction(7 downto 5),
            in_read_addr_2 => decode_instruction(4 downto 2),
            in_write_addr => write_addr_from_wb,
            in_write_data => write_data_from_wb, 
            sp_plus_minus => out_decode_sp_plus_minus,
            sp_chosen => out_decode_sp_chosen,
            decode_push_pop => out_decode_push_pop,
            decode_int_or_rti => out_decode_int_or_rti,
            decode_sp_wen => out_decode_sp_wen,
            decode_Mem_addr => out_decode_Mem_addr,
            decode_zero_neg_flag_en => out_decode_zero_neg_flag_en,
            decode_carry_flag_en => out_decode_carry_flag_en,
            decode_reg_write => out_decode_reg_write,
            decode_is_jmp => out_decode_is_jmp,
            decode_mem_read => out_decode_mem_read,
            decode_mem_write => out_decode_mem_write,
            decode_imm_used => out_decode_imm_used,
            decode_imm_loc => out_decode_imm_loc,
            decode_out_wen => out_decode_out_wen,
            decode_from_in => out_decode_from_in,
            decode_mem_wr_data => out_decode_mem_wr_data,
            decode_call => out_decode_call,
            decode_ret => out_decode_ret,
            decode_int => out_decode_int,
            decode_rti => out_decode_rti,
            decode_ret_or_rti => out_decode_ret_or_rti,
            decode_alu_op_code => out_decode_alu_op_code,
            decode_which_jmp => out_decode_which_jmp,
            decode_which_r_src => out_decode_which_r_src,
            out_read_data_1 => out_decode_read_data_1, 
            out_read_data_2 => out_decode_read_data_2 
        );

        ID_IE: my_nDFF generic map (162) port map (
            Clk => my_clk,
            Rst => '0',
            writeEN => '1',
            d => d_idie,
            q => q_idie
        );
end architecture;