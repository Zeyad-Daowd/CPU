
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--inputs : 16 bit each
entity MUX8to1 is
    port (

        input0  : in std_logic_vector(15 downto 0);
        input1  : in std_logic_vector(15 downto 0);
        input2  : in std_logic_vector(15 downto 0);
        input3  : in std_logic_vector(15 downto 0);
        input4  : in std_logic_vector(15 downto 0);
        input5  : in std_logic_vector(15 downto 0);
        input6  : in std_logic_vector(15 downto 0);
        input7  : in std_logic_vector(15 downto 0);
        
        -- 3-bit selector to choose one of the inputs
        selector : in std_logic_vector(2 downto 0);
        
        -- 16-bit output data
        output : out std_logic_vector(15 downto 0)
    );
end MUX8to1;

architecture Behavioral of MUX8to1 is
begin
    process(selector, input0, input1, input2, input3, input4, input5, input6, input7)
    begin
        case selector is
            when "000" => output <= input0;
            when "001" => output <= input1;
            when "010" => output <= input2;
            when "011" => output <= input3;
            when "100" => output <= input4;
            when "101" => output <= input5;
            when "110" => output <= input6;
            when "111" => output <= input7;
            when others => output <= (others => '0');  
        end case;
    end process;
end Behavioral;

