library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity forwarding_unit is
    Port ( 
        -- reg write
        regWrite_ex_mem : in std_logic;
        regWrite_mem_wb : in std_logic;
        -- destinations
        rd_ex_mem : in std_logic_vector(2 downto 0); --execute forwarding
        rd_mem_wb : in std_logic_vector(2 downto 0); --memory forwarding
        -- sources
        rs_id_ex : in std_logic_vector(2 downto 0); --source1
        rt_id_ex : in std_logic_vector(2 downto 0); --source2
        -- Forwarding signals output
        forward_a: out std_logic_vector(1 downto 0);
        forward_b: out std_logic_vector(1 downto 0)
    );
end forwarding_unit;
architecture forwarding_behavioral of forwarding_unit is
begin
    process(regWrite_ex_mem, regWrite_mem_wb, rd_ex_mem, rd_mem_wb, rs_id_ex, rt_id_ex)
    begin
        --first source forwarding
        if(regWrite_ex_mem = '1' and rd_ex_mem = rs_id_ex) then
            forward_a <= "10";
        elsif(regWrite_mem_wb = '1' and rd_mem_wb = rs_id_ex) then
            forward_a <= "01";
        else
            forward_a <= "00";
        end if;
        -- second source forwarding
        if(regWrite_ex_mem = '1' and rd_ex_mem = rt_id_ex) then
            forward_b <= "10";
        elsif(regWrite_mem_wb = '1' and rd_mem_wb = rt_id_ex) then
            forward_b <= "01";
        else
            forward_b <= "00";
        end if;
    end process;
end forwarding_behavioral;
