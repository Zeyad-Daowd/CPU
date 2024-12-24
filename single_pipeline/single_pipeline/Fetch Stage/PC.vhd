library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity PC is
    port (
        clk: in std_logic; -- Clock signal
        pc_address_in: in std_logic_vector(15 downto 0); -- Input address to write
        write_enable: in std_logic; -- Enable signal for writing
        rst: in std_logic; -- Reset signal
        pc_address_out: out std_logic_vector(15 downto 0) -- Output address to read
    );
end PC;

architecture Behavioral of PC is
    signal pc_register: std_logic_vector(15 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_register <= (others => '0'); 
            elsif write_enable = '1' then
                pc_register <= pc_address_in; 
            end if;
        end if;
    end process;
    pc_address_out <= pc_register; -- Output the PC address

end Behavioral;
