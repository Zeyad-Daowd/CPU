library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is 
    port (
		my_clk: in std_logic; 
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
            call_pc, jmp_pc: in std_logic_vector(15 downto 0);
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
    end component decode;

    component execute IS
        port (
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
            dataBack, Rsrc1Forwarded  : OUT std_logic_vector (15 DOWNTO 0);
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
    END component execute;

    component forwarding_unit is
        Port ( 
            regWrite_ex_mem : in std_logic;
            regWrite_mem_wb : in std_logic;
            rd_ex_mem : in std_logic_vector(2 downto 0); 
            rd_mem_wb : in std_logic_vector(2 downto 0); 
            rs_id_ex : in std_logic_vector(2 downto 0); 
            rt_id_ex : in std_logic_vector(2 downto 0); 
            forward_a: out std_logic_vector(1 downto 0);
            forward_b: out std_logic_vector(1 downto 0)
        );
    end component forwarding_unit;

    component Exception_Unit IS 
        PORT (
            Mem_read_en : IN std_logic; -- read enable from inst.
            Mem_write_en : IN std_logic; -- write enable from inst.
            push : IN std_logic; -- 1 for push inst.
            pop : IN std_logic; -- 1 for pop inst.
            rti : IN std_logic;
            Mem_read_en_exception : OUT std_logic; -- read enable from excep.
            Mem_write_en_exception : OUT std_logic; -- write enable from excep.
            mem_address : IN std_logic_vector(15 DOWNTO 0); -- memory address to be accessed
            sp : IN std_logic_vector(15 DOWNTO 0); -- stack pointer
            epc : OUT std_logic_vector(15 DOWNTO 0); -- epc "=pc if exception found"
            pc_memory : IN std_logic_vector(15 DOWNTO 0); -- program counter of current inst. (memory)
            pc_decode : IN std_logic_vector(15 DOWNTO 0); 
            -- FLUSH FETCH IF STACK EXCEPTION
            -- FLUSH F/D/E IF MEMORY EXCEPTION 
            IF_D_flush : OUT std_logic;
            D_EX_flush : OUT std_logic;
            EX_M_flush : OUT std_logic;
            -- CHOOSE PC = SUITABLE EXCEPTION HANDLER 
            pc_sel :OUT std_logic_vector(1 DOWNTO 0) -- 00 "NO" 01 "INVALID ADDRESS" 10 "EMPTY STACK" 11 "FULL STACK"
        );
    END component Exception_Unit;

    component Memory_Stage IS 
    PORT (
        clk : IN std_logic;
        rst : IN std_logic;
        Mem_reg : IN std_logic; -- write back to memory or to reg
        RegWrite : IN std_logic; -- is there a write back or not
        Mem_read_en : IN std_logic; -- read enable from inst.
        Mem_write_en : IN std_logic; -- write enable from inst.
        Mem_read_en_exception : IN std_logic; -- read enable from excep.
        Mem_write_en_exception : IN std_logic; -- write enable from excep.
        PC : IN std_logic_vector(15 DOWNTO 0); -- PC + 1
        FLAGS : IN std_logic_vector(15 DOWNTO 0); -- FLAGS to be stored in memory (INT)
        SP : IN std_logic_vector(15 DOWNTO 0); --     SP     OR    SP+1
        SP_SEC : IN std_logic_vector(15 DOWNTO 0); -- SP-1   OR    SP+2
        R_Rsrc : IN std_logic_vector(15 DOWNTO 0); -- reg data may be written to memory
        Data_back : IN std_logic_vector(15 DOWNTO 0); -- calculated offset from ALU
        mem_address : IN std_logic; -- MUX Selector to choose address "sp or offset"
        Mem_write_data : IN std_logic; -- MUX Selector to choose data "(pc or flags) or reg data"

        Rdst : IN std_logic_vector(2 DOWNTO 0); -- Rdst of inst.
        -- FLAGS_WR : IN std_logic_vector(2 DOWNTO 0); -- in case of popping flags ??
        Mem_Data_Out : OUT std_logic_vector(15 DOWNTO 0); -- data out from memory

        -- needed to be passed to Mem-WB Reg
        Mem_reg_Out : OUT std_logic;
        RegWrite_Out : OUT std_logic;
        Data_back_Out, address_for_exception : OUT std_logic_vector(15 DOWNTO 0);
        -- FLAGS_WR_Out : OUT std_logic_vector(2 DOWNTO 0);  -- ??

        PC_Out : OUT std_logic; 
        Flags_Out : OUT std_logic;
        Call : IN std_logic;
        INT : IN std_logic;
        RET : IN std_logic;
        RTI : IN std_logic);

    END component Memory_Stage;
    component Write_Back is
        port (
            memToReg: in std_logic;
            dataBack: in std_logic_vector(15 downto 0);
            mem: in std_logic_vector(15 downto 0);
            write_data: out std_logic_vector(15 downto 0)        
        );
    end component Write_Back;
    component hazardUnit IS
    PORT (
        memRead : IN std_logic;   
        Rdst : IN std_logic_vector (2 DOWNTO 0); 
        Rsrc1, Rsrc2 : IN std_logic_vector (2 DOWNTO 0);  
        Rsrc1Used, Rsrc2Used : IN std_logic; 
        hazard_detected : OUT std_logic     
    );
    END component;
    -- TODO: to be removed signals 
    -- simulating hazards and exceptions 
    signal eden_hazard: std_logic := '0';

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
                out_decode_ret_or_rti, out_decode_set_carry,
                out_decode_push, out_decode_pop, out_decode_mem_to_reg, out_decode_write_enable_ex_mem_pipe : std_logic := '0';

    signal out_decode_which_r_src, out_decode_which_jmp : std_logic_vector(1 downto 0);
    signal out_decode_alu_op_code : std_logic_vector(2 downto 0);
    signal out_decode_sp_first, out_decode_sp_second, out_decode_sp_required,out_decode_read_data_1, out_decode_read_data_2: std_logic_vector(15 downto 0);
        ----------------------------- IDIE pipeline -----------------------------
    signal d_idie : std_logic_vector(168 downto 0); 
    signal q_idie: std_logic_vector(168 downto 0) := (others => '0');
    -------------------------------- Forward Unit ----------------------------
    signal forward_a_signal, forward_b_signal : std_logic_vector(1 downto 0) := (others => '0');
    -------------------------------- Exception Unit --------------------------
    signal Mem_read_en_exception_signal, Mem_write_en_exception_signal : std_logic := '1';
    signal exception_sig: std_logic_vector(1 downto 0) := (others => '0');
    signal zeros_16, mem_address_signal_for_exception: std_logic_vector(15 downto 0) := (others => '0');
    signal epc_signal: std_logic_vector(15 downto 0) := (others => '0');
    signal IF_D_flush_signal, D_EX_flush_signal, EX_M_flush_signal : std_logic := '0';
    --------------------------------- Execute Signals ----------------------------
    signal exec_data_out, exec_Rsrc1Forwarded : std_logic_vector(15 downto 0);
    signal exec_jumpFlag, exec_carryFlagOutput, exec_zeroFlagOutput, exec_negativeFlagOutput : std_logic := '0';
        ----------------------------- IEMEM pipeline signals ---------------------
    signal d_ex_mem : std_logic_vector(116 downto 0);
    signal q_ex_mem : std_logic_vector(116 downto 0) := (others => '0');
    signal zeros: std_logic_vector(12 downto 0) := (others => '0');
        ----------------------------- IMEMWB pipeline signals ---------------------
    signal d_mem_wb : std_logic_vector(36 downto 0);
    signal q_mem_wb : std_logic_vector(36 downto 0) := (others => '0');
    signal pcOutFromMemory: std_logic;
    signal dataOutFromMemory, writeBackOut: std_logic_vector(15 downto 0);
    signal writeFlagsFromMemory: std_logic;
    signal reset : std_logic := '0'; -- TODO: handle this
    signal temp: std_logic := '0';
    signal stall_signal: std_logic:='0';

    begin
        stall_signal <= (eden_hazard or out_decode_int);
        d_ifid <= fetch_pc & fetch_next_pc & fetch_instruction;
        decode_pc <= q_ifid(47 downto 32);
        decode_next_pc <= q_ifid(31 downto 16);
        decode_instruction <= q_ifid(15 downto 0);

        d_idie <= (
            out_decode_write_enable_ex_mem_pipe -- 168
            & out_decode_push -- 167
            & out_decode_pop -- 166
            & out_decode_mem_to_reg -- 165
            & out_decode_set_carry -- [164]
            & out_decode_which_jmp -- [163, 162]
            & fetch_instruction -- [161 -> 146] 
            & in_peripheral -- [130 -> 145]
            & out_decode_read_data_2 -- [114 -> 129]
            & out_decode_read_data_1 -- [98 -> 113]
            & decode_instruction(4 downto 2) -- [95 -> 97]
            & decode_instruction(7 downto 5) -- [92 -> 94]
            & decode_instruction(10 downto 8) -- [89 -> 91]
            & decode_next_pc -- [73 -> 88]
            & decode_pc -- [57 -> 72]
            & out_decode_sp_first -- [41 -> 56]
            & out_decode_sp_second -- [25 -> 40]
            & out_decode_which_r_src -- 23, 24
            & out_decode_alu_op_code -- 20, 21, 22
            & out_decode_ret_or_rti -- 19
            & out_decode_rti -- 18
            & out_decode_int -- 17
            & out_decode_ret -- 16
            & out_decode_call -- 15
            & out_decode_mem_wr_data -- 14
            & out_decode_from_in -- 13
            & out_decode_out_wen -- 12
            & out_decode_imm_loc -- 11
            & out_decode_imm_used -- 10
            & out_decode_mem_write -- 9
            & out_decode_mem_read -- 8
            & out_decode_is_jmp -- 7
            & out_decode_reg_write -- 6
            & out_decode_carry_flag_en -- 5
            & out_decode_zero_neg_flag_en -- 4
            & out_decode_Mem_addr -- 3
            & out_decode_sp_wen  -- 2
            & out_decode_int_or_rti -- 1
            & out_decode_push_pop -- 0
        );
        d_ex_mem <= (
            q_idie (97 downto 95) --- 114 to 116 (2nd addr)
            & q_idie (94 downto 92) -- 111 to 113 (first reg addr)
            & q_idie(18) -- 110
            & q_idie(16) -- 109
            & q_idie(17) -- 108
            & q_idie(15) -- 107
            & q_idie(91 downto 89) -- 104 to 106
            & q_idie(14) -- 103
            & q_idie(3) -- 102
            & exec_data_out --86 to 101
            & exec_Rsrc1Forwarded -- 70 to 85
            & q_idie(56 downto 41) -- 54 to 69
            & q_idie(40 downto 25) -- 38 to 53
            & zeros & exec_carryFlagOutput & exec_zeroFlagOutput & exec_negativeFlagOutput -- 22 to 37
            & q_idie(88 downto 73) -- 6 to 21
            & temp      --5
            & temp      --4
            & q_idie(9) --3
            & q_idie(8) -- 2
            & q_idie(6) -- 1
            & q_idie(165) -- 0
        );

        d_mem_wb <= (
            q_ex_mem(1) -- 36
            & q_ex_mem (106 downto 104) -- 33 to 35
            & dataOutFromMemory -- 17 to 32
            & q_ex_mem(101 downto 86) -- 1 to 16
            & q_ex_mem(0) -- 0
        );

        fetch_stage: Fetch_Block port map (
            clk => my_clk,
            ret_rti_sig => pcOutFromMemory,
            call_sig => out_decode_call,
            jmp_sig => exec_jumpFlag, -- TODO: as far as I see, jump is from ex
            hazard_sig => stall_signal, --For stalling after int
            exception_sig => exception_sig,
            pc_en => '1', -- unused now
            rst => reset,
            call_pc => d_idie(113 downto 98),
            jmp_pc => q_idie(113 downto 98), -- TODO: handle this
            ret_pc => dataOutFromMemory, -- TODO: handle this
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
            wb_reg_write => q_mem_wb(36), -- TODO: come from wb
            pipe_IF_out => decode_instruction(15 downto 11),
            in_read_addr_1 => decode_instruction(7 downto 5),
            in_read_addr_2 => decode_instruction(4 downto 2),
            latest_bit => decode_instruction(0),
            jump_from_exec => exec_jumpFlag,
            in_write_addr => q_mem_wb(35 downto 33), -- from wb
            in_write_data => writeBackOut, --from wb
            sp_first => out_decode_sp_first,
            sp_second => out_decode_sp_second,
            sp_required => out_decode_sp_required,  
            decode_push_pop => out_decode_push_pop,
            decode_int_or_rti => out_decode_int_or_rti,
            decode_sp_wen => out_decode_sp_wen,
            decode_Mem_addr => out_decode_Mem_addr,
            decode_zero_neg_flag_en => out_decode_zero_neg_flag_en,
            decode_carry_flag_en => out_decode_carry_flag_en,
            decode_set_carry => out_decode_set_carry,
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
            decode_push => out_decode_push,
            decode_pop => out_decode_pop,
            decode_mem_to_reg => out_decode_mem_to_reg,
            decode_write_enable_ex_mem_pipe => out_decode_write_enable_ex_mem_pipe,
            decode_alu_op_code => out_decode_alu_op_code,
            decode_which_jmp => out_decode_which_jmp,
            decode_which_r_src => out_decode_which_r_src,
            out_read_data_1 => out_decode_read_data_1, 
            out_read_data_2 => out_decode_read_data_2
        );

        ID_IE: my_nDFF generic map (169) port map (
            Clk => my_clk,
            Rst => '0',
            writeEN => '1',
            d => d_idie,
            q => q_idie
        );

        forward_unit: forwarding_unit port map (
            regWrite_ex_mem => q_ex_mem(1), 
            regWrite_mem_wb => q_mem_wb(36), 
            rd_ex_mem => q_ex_mem(106 downto 104),  
            rd_mem_wb => q_mem_wb(35 downto 33),  
            rs_id_ex => q_idie(94 downto 92),  
            rt_id_ex => q_idie(97 downto 95),  
            forward_a => forward_a_signal, 
            forward_b => forward_b_signal
        );
        
        thorgan_hazard_unit: hazardUnit port map (
            memRead => q_idie(8),   -- from execute
            Rdst => q_idie(91 downto 89),-- from execute
            Rsrc1 => decode_instruction(7 downto 5), -- from decode
            Rsrc2 => decode_instruction(4 downto 2),  -- from decode
            Rsrc1Used => out_decode_which_r_src(0), -- from decoder
            Rsrc2Used => out_decode_which_r_src(1), -- from decoder
            hazard_detected => eden_hazard  
        );

        except_unit: Exception_Unit port map (
            Mem_read_en => q_ex_mem(2), 
            Mem_write_en => q_ex_mem(3),
            push => out_decode_push, -- 1 for push inst.
            pop => out_decode_pop, -- 1 for pop inst.
            rti => out_decode_rti,
            Mem_read_en_exception => Mem_read_en_exception_signal, -- read enable from excep.
            Mem_write_en_exception => Mem_write_en_exception_signal, -- write enable from excep.
            mem_address => mem_address_signal_for_exception, --q_ex_mem(101 downto 86), -- memory address to be accessed
            sp => out_decode_sp_required, -- TODO decode -- stack pointer
            pc_memory => zeros_16, -- program counter of current inst. (memory stage)
            pc_decode => zeros_16, -- program counter of current inst. (decode stage)
            epc => epc_signal, -- TODO m4 awy: Fatma epc "=pc if exception found"
            IF_D_flush => IF_D_flush_signal,
            D_EX_flush => D_EX_flush_signal,
            EX_M_flush => EX_M_flush_signal, 
            -- CHOOSE PC = SUITABLE EXCEPTION HANDLER 
            pc_sel => exception_sig -- 00 "NO" 01 "INVALID ADDRESS" 10 "EMPTY STACK" 11 "FULL STACK"
        );

        execute_stage: execute port map (
            clk => my_clk,
            rst => temp,
            RegA => q_idie(113 downto 98),
            RegB => q_idie(129 downto 114),
            ALUop => q_idie(22 downto 20),
            imm_used => q_idie(10),
            imm_loc => q_idie(11),
            imm_value => q_idie(161 downto 146),
            memForward1 => forward_a_signal(0), -- TODO
            memForward2 => forward_b_signal(0), -- TODO
            execForward1 => forward_a_signal(1), -- TODO
            execForward2 => forward_b_signal(1), -- TODO
            memForwardData => writeBackOut, -- TODO
            execForwardData => q_ex_mem(101 downto 86), -- TODO
            fromIn => q_idie(13),
            inData => q_idie(145 downto 130),
            isJump => q_idie(7),
            whichJump => q_idie(163 downto 162),
            carryFlagEn => q_idie(5),
            zeroFlagEn => q_idie(4),
            negativeFlagEn => q_idie(4),
            RTI => writeFlagsFromMemory,  -- from memory stage
            set_C => q_idie(164), 
            carryFlagMem => dataOutFromMemory(2),
            zeroFlagMem => dataOutFromMemory(1),
            negativeFlagMem => dataOutFromMemory(0),
            jumpFlag => exec_jumpFlag,
            carryFlagOutput => exec_carryFlagOutput, 
            zeroFlagOutput => exec_zeroFlagOutput,
            negativeFlagOutput => exec_negativeFlagOutput,
            dataBack => exec_data_out,
            Rsrc1Forwarded => exec_Rsrc1Forwarded
        );

        IE_mem: my_nDFF generic map (117) port map (
            Clk => my_clk,
            Rst => '0',
            writeEN => q_idie(168),
            d => d_ex_mem,
            q => q_ex_mem
        );

        mem_stage: Memory_Stage port map (
            clk => my_clk,
            rst => temp,
            Mem_reg => q_ex_mem(0), 
            RegWrite => q_ex_mem(1),
            Mem_read_en => q_ex_mem(2),
            Mem_write_en => q_ex_mem(3),
            Mem_read_en_exception => Mem_read_en_exception_signal,
            Mem_write_en_exception => Mem_write_en_exception_signal,
            PC => q_ex_mem(21 downto 6),
            FLAGS => q_ex_mem(37 downto 22),
            SP_SEC => q_ex_mem(53 downto 38),
            SP => q_ex_mem(69 downto 54),
            R_Rsrc => q_ex_mem(85 downto 70),
            Data_back => q_ex_mem(101 downto 86),
            mem_address => q_ex_mem(102),
            Mem_write_data => q_ex_mem(103),
            Rdst => q_ex_mem(106 downto 104),
            Mem_Data_Out => dataOutFromMemory, -- data out from memory
            PC_Out => pcOutFromMemory,
            Flags_Out => writeFlagsFromMemory,
            Call => q_ex_mem(107),
            INT => q_ex_mem(108),
            RET => q_ex_mem(109),
            RTI => q_ex_mem(110),
            address_for_exception => mem_address_signal_for_exception
        );

        Imem_wb: my_nDFF generic map (37) port map (
            Clk => my_clk,
            Rst => '0',
            writeEN => '1',
            d => d_mem_wb,
            q => q_mem_wb
        );

        wb_stage: Write_Back port map (
            memToReg => q_mem_wb(0),
            dataBack => q_mem_wb(16 downto 1),
            mem => q_mem_wb(32 downto 17),
            write_data => writeBackOut
        );
end architecture;