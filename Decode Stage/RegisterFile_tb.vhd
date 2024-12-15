LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Register_File_TB IS
END ENTITY Register_File_TB;

ARCHITECTURE behavior OF Register_File_TB IS

    COMPONENT Register_File
        PORT (
            clk: IN std_logic;
            reg_write: IN std_logic;
            read_addr_1: IN std_logic_vector(2 downto 0);
            read_addr_2: IN std_logic_vector(2 downto 0);
            write_addr: IN std_logic_vector(2 downto 0);
            write_data: IN std_logic_vector(15 downto 0);
            read_data_1: OUT std_logic_vector(15 downto 0);
            read_data_2: OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    signal clk: std_logic := '0';
    signal reg_write: std_logic;
    signal read_addr_1: std_logic_vector(2 downto 0);
    signal read_addr_2: std_logic_vector(2 downto 0);
    signal write_addr: std_logic_vector(2 downto 0);
    signal write_data: std_logic_vector(15 downto 0);
    signal read_data_1: std_logic_vector(15 downto 0);
    signal read_data_2: std_logic_vector(15 downto 0);

    constant clk_period: time := 10 ns;

BEGIN

    uut: Register_File PORT MAP (
        clk => clk,
        reg_write => reg_write,
        read_addr_1 => read_addr_1,
        read_addr_2 => read_addr_2,
        write_addr => write_addr,
        write_data => write_data,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2
    );

    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc: process
    begin
        wait for clk_period / 2;
        -- Test Case 1: Write to register 0
        reg_write <= '1';
        write_addr <= "000"; 
        write_data <= x"AAAA"; 
        wait for clk_period;

        -- Test Case 2: Write to register 7
        write_addr <= "111"; 
        write_data <= x"5555";
        wait for clk_period;

        -- Test Case 3: Read from registers 0 and 7
        reg_write <= '0'; 
        read_addr_1 <= "000"; 
        read_addr_2 <= "111"; 
        wait for clk_period;

        -- Test Case 4: Ensure no write when reg_write is '0'
        reg_write <= '0';
        write_addr <= "010"; 
        write_data <= x"FFFF";
        wait for clk_period;

        -- Test Case 5: Read uninitialized register
        read_addr_1 <= "010"; 
        read_addr_2 <= "001"; 
        wait for clk_period;

        -- Test Case 6: Write to middle address and read back
        reg_write <= '1';
        write_addr <= "011"; 
        write_data <= x"1234";
        wait for clk_period;

        reg_write <= '0';
        read_addr_1 <= "011"; 
        wait for clk_period;

        -- End simulation
        wait;
    end process;

END ARCHITECTURE behavior;
