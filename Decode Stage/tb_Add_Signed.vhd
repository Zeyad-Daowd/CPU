library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Add_signed is
end entity tb_Add_signed;

architecture arch_tb_Add_signed of tb_Add_signed is
    signal data_in : std_logic_vector(15 downto 0);
    signal added_bit : std_logic_vector(15 downto 0);
    signal data_out : std_logic_vector(15 downto 0);
    
    component Add_signed
        port (
            data_in: in std_logic_vector(15 downto 0);
            added_bit: in std_logic_vector(15 downto 0);
            data_out: out std_logic_vector(15 downto 0)
        );
    end component;

begin
    uut: Add_signed
        port map (
            data_in => data_in,
            added_bit => added_bit,
            data_out => data_out
        );

    process
    begin
        -- Test Case 1: Add 5 and 3 (Unsigned result should be 8)
        data_in <= "0000000000000101";  
        added_bit <= "0000000000000011"; 
        wait for 10 ns;  
        report "Test Case 1: " & "data_in = 5, added_bit = 3, data_out = " & integer'image(to_integer(unsigned(data_out)));

        -- Test Case 2: Add 1 and -1 (Unsigned result should be 0)
        data_in <= "0000000000000001";  
        added_bit <= "1111111111111111"; 
        wait for 10 ns;
        report "Test Case 2: " & "data_in = 1, added_bit = -1, data_out = " & integer'image(to_integer(unsigned(data_out)));

        -- Test Case 3: Add -2 and 2 (Unsigned result should be 0)
        data_in <= "1111111111111110";  
        added_bit <= "0000000000000010"; 
        wait for 10 ns;
        report "Test Case 3: " & "data_in = -2, added_bit = 2, data_out = " & integer'image(to_integer(unsigned(data_out)));

        -- Test Case 4: Add 32767 and 1 (Unsigned result will overflow and show large value)
        data_in <= "0111111111111111";  
        added_bit <= "0000000000000001"; 
        wait for 10 ns;
        report "Test Case 4: " & "data_in = 32767, added_bit = 1, data_out = " & integer'image(to_integer(unsigned(data_out)));

        -- Test Case 5: Add -32768 and -1 (Unsigned result will show large positive value due to overflow)
        data_in <= "1000000000000000";  
        added_bit <= "1111111111111111"; 
        wait for 10 ns;
        report "Test Case 5: " & "data_in = -32768, added_bit = -1, data_out = " & integer'image(to_integer(unsigned(data_out)));

        -- End of simulation
        wait;
    end process;
end architecture arch_tb_Add_signed;
