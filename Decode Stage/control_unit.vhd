library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is 
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
end entity;


architecture arch_control_unit of control_unit is 
begin
    push_pop <= (op_code(4) and not op_code(0)) and ((not op_code(3) and not op_code(2) and not op_code(1)) 
                or
                (op_code(3) and op_code(2) and op_code(1))
                or
                (op_code(3) and op_code(2) and not op_code(1)));
    int_or_rti <= op_code(4) and op_code(3) and op_code(2) and op_code(1); 
    sp_wen <= op_code(4) and (
            (op_code(3) and op_code(2)) or
            (not op_code(3) and not op_code(2) and not op_code(1))
          );
    Mem_addr <= op_code(4) and (
        (op_code(3) and op_code(2)) or
        (not op_code(3) and not op_code(2) and not op_code(1))
      ); 
    zero_neg_flag_en <= (not op_code(4) and op_code(3) and (op_code(2) or op_code(1) or op_code(0))) or
                        (op_code(4) and op_code(3) and op_code(2) and op_code(1) and op_code(0)) or
                        (not op_code(4) and not op_code(3) and op_code(2) and not op_code(1) and not op_code(0));
                        
    carry_flag_en <= (not op_code(4) and op_code(3) and (op_code(2) xor op_code(1) xor op_code(0))) or
                    (op_code(4) and op_code(3) and op_code(2) and op_code(1) and op_code(0)) or
                    (not op_code(4) and not op_code(3) and not op_code(2) and op_code(1) and not op_code(0)) or
                    (not op_code(4) and not op_code(3) and op_code(2) and not op_code(1) and not op_code(0));
    
    set_carry <= (not op_code(4) and not op_code(3) and not op_code(2) and op_code(1) and not op_code(0));
    
    reg_write <= (op_code(4) and not op_code(3) and not op_code(2) and op_code(1)) or
                 (not op_code(4) and op_code(3)) or
                 (not op_code(4) and not op_code(3) and not op_code(2) and op_code(1) and op_code(0)) or
                 (not op_code(4) and not op_code(3) and op_code(2) and not op_code(1) and not op_code(0)) or
                 (not op_code(4) and not op_code(3) and op_code(2) and op_code(1) and not op_code(0));

    is_jmp <= (op_code(4) and op_code(3) and not op_code(2));

    mem_read <= (op_code(4) and not op_code(3) and not op_code(2) and op_code(0)) or
                (op_code(4) and op_code(3) and op_code(2) and op_code(0));

    mem_write <= (op_code(4) and (
                    (op_code(3) and op_code(2) and (
                        (op_code(1) and not op_code(0)) or  
                        (not op_code(1) and not op_code(0)) 
                    )) or
                    (not op_code(3) and (
                        (op_code(2) and not op_code(1) and not op_code(0)) or  
                        (not op_code(2) and not op_code(1) and not op_code(0)) 
                    ))
                ));
            
    imm_used <= (op_code(4) and not op_code(3) and (
                    (not op_code(2) and op_code(1)) or  
                    (op_code(2) and not op_code(1) and not op_code(0)) 
                )) or
                (not op_code(4) and op_code(3) and op_code(2) and not op_code(1) and not op_code(0));  -- 01100
            
    imm_loc <=  (not op_code(4) and op_code(3) and op_code(2) and not op_code(1) and not op_code(0)) or
                (op_code(4) and not op_code(3) and not op_code(2) and op_code(1) and op_code(0));
            
    out_wen <= (not op_code(4) and not op_code(3) and op_code(2) and not op_code(1) and op_code(0));
                    
    from_in <= (not op_code(4) and not op_code(3) and op_code(2) and op_code(1) and not op_code(0));
                    
    mem_wr_data <= (op_code(4) and op_code(3) and op_code(2));

    call <= (op_code(4) and op_code(3) and op_code(2) and not op_code(1) and not op_code(0));

    ret <= (op_code(4) and op_code(3) and op_code(2) and not op_code(1) and op_code(0));

    int <= (op_code(4) and op_code(3) and op_code(2) and op_code(1) and not op_code(0));

    rti <= (op_code(4) and op_code(3) and op_code(2) and op_code(1) and op_code(0));

    ret_or_rti <= (op_code(4) and op_code(3) and op_code(2) and not op_code(1) and op_code(0)) or
                    (op_code(4) and op_code(3) and op_code(2) and op_code(1) and op_code(0));
    
    mem_to_reg <= (op_code(4) and not op_code(3) and not op_code(2)) and (op_code(0));  --- zeyad editted

    push <= (op_code(4) and not op_code(3) and not op_code(2) and not op_code(1) and not op_code(0));

    pop <= (op_code(4) and not op_code(3) and not op_code(2) and not op_code(1) and op_code(0));

    process(op_code) begin
        case op_code is
            when "00011" => alu_op_code <= "001";
            when "00100" => alu_op_code <= "010";
            when "01001" | "01100" | "10011" => alu_op_code <= "011";
            when "01010" => alu_op_code <= "100";
            when "01011" => alu_op_code <= "101";
            when others => alu_op_code <= "000";
        end case;  
    end process; 

    process(op_code) begin
        case op_code is
            when "11000" => which_jmp <= "01";
            when "11001" => which_jmp <= "10";
            when "11010" => which_jmp <= "11";
            when others => which_jmp <= "00";
        end case;
    end process;

    process(op_code)
    begin
        case op_code is
            when "11100" | "11011" | "11010" | "11001" | "11000" | 
                 "10011" | "10000" | "01100" | "01000" | "00101" | 
                 "00100" | "00011" =>
                which_r_src <= "01";

            when "10100" | "01011" | "01010" | "01001" =>
                which_r_src <= "11";

            when others =>
                which_r_src <= "00"; 

        end case;
    end process;

end architecture;