library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit_tb is
end entity control_unit_tb;

architecture testbench of control_unit_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component control_unit
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
    end component;

    -- Function to convert std_logic to character
    function std_logic_to_char(sl : std_logic) return character is
    begin
        case sl is
            when '0' => return '0';
            when '1' => return '1';
            when others => return 'X';
        end case;
    end function;

    -- Function to convert std_logic_vector to string
    function slv_to_string(slv : std_logic_vector) return string is
        variable result : string(slv'left+1 downto 1);
    begin
        for i in slv'left downto 0 loop
            result(i+1) := std_logic_to_char(slv(i));
        end loop;
        return result;
    end function;

    -- Inputs
    signal op_code : std_logic_vector(4 downto 0) := (others => '0');

    -- Outputs
    signal push_pop : std_logic;
    signal int_or_rti : std_logic;
    signal sp_wen : std_logic;
    signal Mem_addr : std_logic;
    signal zero_neg_flag_en : std_logic;
    signal carry_flag_en : std_logic;
    signal reg_write : std_logic;
    signal is_jmp : std_logic;
    signal mem_read : std_logic;
    signal mem_write : std_logic;
    signal imm_used : std_logic;
    signal imm_loc : std_logic;
    signal out_wen : std_logic;
    signal from_in : std_logic;
    signal mem_wr_data : std_logic;
    signal alu_op_code : std_logic_vector(2 downto 0);
    signal which_jmp : std_logic_vector(1 downto 0);

    -- Simulation process
    signal stop_simulation : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: control_unit PORT MAP (
        op_code => op_code,
        push_pop => push_pop,
        int_or_rti => int_or_rti,
        sp_wen => sp_wen,
        Mem_addr => Mem_addr,
        zero_neg_flag_en => zero_neg_flag_en,
        carry_flag_en => carry_flag_en,
        reg_write => reg_write,
        is_jmp => is_jmp,
        mem_read => mem_read,
        mem_write => mem_write,
        imm_used => imm_used,
        imm_loc => imm_loc,
        out_wen => out_wen,
        from_in => from_in,
        mem_wr_data => mem_wr_data,
        alu_op_code => alu_op_code,
        which_jmp => which_jmp
    );

    -- Stimulus process
    stim_proc: process
    begin
        -- Iterate through all possible 5-bit op_code values
        for i in 0 to 31 loop
            op_code <= std_logic_vector(to_unsigned(i, 5));
            wait for 10 ns;

            -- Print out the current op_code and all outputs for verification
            report "Op Code: " & slv_to_string(op_code) & 
                   " | Push/Pop: " & std_logic_to_char(push_pop) & 
                   " | Int/RTI: " & std_logic_to_char(int_or_rti) & 
                   " | SP WEN: " & std_logic_to_char(sp_wen) & 
                   " | Mem Addr: " & std_logic_to_char(Mem_addr) & 
                   " | Zero/Neg Flag EN: " & std_logic_to_char(zero_neg_flag_en) & 
                   " | Carry Flag EN: " & std_logic_to_char(carry_flag_en) & 
                   " | Reg Write: " & std_logic_to_char(reg_write) & 
                   " | Is Jump: " & std_logic_to_char(is_jmp) & 
                   " | Mem Read: " & std_logic_to_char(mem_read) & 
                   " | Mem Write: " & std_logic_to_char(mem_write) & 
                   " | Imm Used: " & std_logic_to_char(imm_used) & 
                   " | Imm Loc: " & std_logic_to_char(imm_loc) & 
                   " | Out WEN: " & std_logic_to_char(out_wen) & 
                   " | From In: " & std_logic_to_char(from_in) & 
                   " | Mem WR Data: " & std_logic_to_char(mem_wr_data) & 
                   " | ALU Op Code: " & slv_to_string(alu_op_code) & 
                   " | Which Jump: " & slv_to_string(which_jmp);
        end loop;

        stop_simulation <= true;
        wait;
    end process;

    -- Optional: Watchdog to stop simulation if it runs too long
    watchdog: process
    begin
        wait for 1 ms;
        if not stop_simulation then
            report "Simulation timed out" severity failure;
        end if;
        wait;
    end process;
end architecture testbench;