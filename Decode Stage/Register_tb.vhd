library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg is
end entity tb_reg;

architecture sim of tb_reg is
    component reg is 
        Port (
            clk : in std_logic;
            reg_write_enable : in std_logic;
            reg_write_data : in std_logic_vector(15 downto 0);
            reg_data_out : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal reg_write_enable : std_logic := '0';
    signal reg_write_data : std_logic_vector(15 downto 0) := (others => '0');
    signal reg_data_out : std_logic_vector(15 downto 0);
    
begin
    uut: reg 
        port map (
            clk => clk,
            reg_write_enable => reg_write_enable,
            reg_write_data => reg_write_data,
            reg_data_out => reg_data_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process clk_process;

    -- Stimulus process
    stimulus : process
    begin
        wait for 10 ns;
        
        reg_write_data <= "1010101010101010";
        reg_write_enable <= '1';
        wait for 20 ns;

        reg_write_enable <= '0';
        wait for 20 ns;

        reg_write_data <= "1111000011110000";
        reg_write_enable <= '1';
        wait for 20 ns;

        reg_write_enable <= '0';
        wait for 20 ns;
        
        wait;
    end process stimulus;
    
end architecture sim;
