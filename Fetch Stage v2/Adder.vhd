library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Adder is
    port (
        input_value : in std_logic_vector(15 downto 0);  
        immediate_value : in std_logic_vector(15 downto 0);  
        result : out std_logic_vector(15 downto 0)     
    );
end Adder;

architecture Behavioral of Adder is
begin
    result <= std_logic_vector(unsigned(input_value) + unsigned(immediate_value));
end Behavioral;

