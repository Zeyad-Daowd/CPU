
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is 
    port (
        clk : in std_logic;
        reg_write_enable : in std_logic;
        reg_write_data : in std_logic_vector(15 downto 0);
        reg_data_out : out std_logic_vector(15 downto 0)
    );
end entity reg;

architecture arch_reg of reg is
    component my_DFF is 
        port (
            clk: in std_logic;
            enable: in std_logic;
            D: in std_logic;
            Q: out std_logic
        );
    end component my_DFF;
    
begin
    gen_reg: for i in 0 to 15 generate
        reg_i: my_DFF port map (clk, reg_write_enable, reg_write_data(i), reg_data_out(i));
    end generate;
end architecture;