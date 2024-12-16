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
    -- Declare the signal to hold the state of the register (internal signal)
    signal reg_internal : std_logic_vector(15 downto 0) := (others => '0');  -- Initialize to zero

    component my_DFF is 
        port (
            clk: in std_logic;
            enable: in std_logic;
            D: in std_logic;
            Q: out std_logic
        );
    end component my_DFF;
    
begin
    -- Connect reg_internal to the output port reg_data_out
    reg_data_out <= reg_internal;

    -- Register generation for each bit
    gen_reg: for i in 0 to 15 generate
        reg_i: my_DFF port map (
            clk => clk, 
            enable => reg_write_enable, 
            D => reg_write_data(i), 
            Q => reg_internal(i)
        );
    end generate;
    
end architecture;

