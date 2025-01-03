library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_SP_sim is
end entity TB_SP_sim;

architecture testbench of TB_SP_sim is
    -- DUT components
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

    signal clk : std_logic := '0';
    signal sp_write_enable : std_logic := '0';
    signal sp_data_in, sp_data_out : std_logic_vector(15 downto 0) := (others => '0');
    signal push_pop : std_logic := '0';
    signal plus_minus_res :  std_logic_vector(15 downto 0) := (others => '0');
    signal add_first_res, add_sec_res : std_logic_vector(15 downto 0) := (others => '0');
    signal In_Or_RTI : std_logic := '0'; -- 0 passes RTI
    signal one : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
    signal neg_one : std_logic_vector(15 downto 0) := (others => '1');
    signal test: std_logic_vector(15 downto 0) := (others => '0');
    constant clk_period : time := 10 ns;
begin
    sp: reg
        port map (
            clk => clk,
            reg_write_enable => sp_write_enable,
            reg_write_data => sp_data_in,
            reg_data_out => sp_data_out
        );
    
    test_reg : reg
        port map (
            clk => clk,
            reg_write_enable => sp_write_enable,
            reg_write_data => add_first_res,
            reg_data_out => test
        );

    mux_plus_minus: mux2to1
        port map (
            choice_1 => one,
            choice_2 => neg_one,
            sel => push_pop,
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
            sel => In_Or_RTI,
            selected => sp_data_in
        );

    clk_gen: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stimulus: process
    begin
        -- Test initialization
        sp_write_enable <= '0';
        push_pop <= '0';
        In_Or_RTI <= '0';

        wait for clk_period;

        -- Test Case 1: INT sim
        sp_write_enable <= '1';
        push_pop <= '1'; 
        In_Or_RTI <= '1';
        wait for clk_period;

        -- Test Case 2: RTI
        sp_write_enable <= '1';
        push_pop <= '0'; 
        In_Or_RTI <= '1'; 
        wait for clk_period;

        -- Test Case 3: Push
        push_pop <= '0';  
        In_Or_RTI <= '0';
        wait for clk_period;

        -- Test Case 4: Pop
        In_Or_RTI <= '0'; 
        wait for clk_period;

        -- Finish the test
        wait;
    end process;
end architecture;
