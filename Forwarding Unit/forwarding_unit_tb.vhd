library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
Entity forwarding_tb is
end forwarding_tb;
Architecture forwarding_tb_arch of forwarding_tb is
COMPONENT forwarding_unit is port
(
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
end COMPONENT;
signal regWrite_ex_mem : std_logic;
signal regWrite_mem_wb : std_logic;
signal rd_ex_mem : std_logic_vector(2 downto 0);
signal rd_mem_wb : std_logic_vector(2 downto 0);
signal rs_id_ex : std_logic_vector(2 downto 0);
signal rt_id_ex : std_logic_vector(2 downto 0);
signal forward_a: std_logic_vector(1 downto 0);
signal forward_b: std_logic_vector(1 downto 0);
begin
process
begin
regWrite_ex_mem <= '1';
regWrite_mem_wb <= '1';
rd_ex_mem <= "000";
rd_mem_wb <= "000";
rs_id_ex <= "000";
rt_id_ex <= "000";
wait for 10 ns;
ASSERT (forward_a = "10" and forward_b = "10") 
REPORT "Test (execute forwarding a,b) failed" SEVERITY FAILURE;
regWrite_ex_mem <= '0';
regWrite_mem_wb <= '1';
rd_ex_mem <= "000";
rd_mem_wb <= "000";
rs_id_ex <= "000";
rt_id_ex <= "000";
wait for 10 ns;
ASSERT (forward_a = "01" and forward_b = "01")
REPORT "Test (forward both from memory) failed" SEVERITY FAILURE;
regWrite_ex_mem <= '1';
regWrite_mem_wb <= '1';
rd_ex_mem <= "001";
rd_mem_wb <= "010";
rs_id_ex <= "001";
rt_id_ex <= "010";
wait for 10 ns;
ASSERT (forward_a = "10" and forward_b = "01")
REPORT "Test (forward rs from exec and rt from mem) failed" SEVERITY FAILURE;
regWrite_ex_mem <= '1';
regWrite_mem_wb <= '1';
rd_ex_mem <= "000";
rd_mem_wb <= "000";
rs_id_ex <= "001";
rt_id_ex <= "010";
wait for 10 ns;
ASSERT (forward_a = "00" and forward_b = "00")
REPORT "Test (no forwarding) failed" SEVERITY FAILURE;
wait;

end process;
uut: forwarding_unit port map(
    regWrite_ex_mem => regWrite_ex_mem,
    regWrite_mem_wb => regWrite_mem_wb,
    rd_ex_mem => rd_ex_mem,
    rd_mem_wb => rd_mem_wb,
    rs_id_ex => rs_id_ex,
    rt_id_ex => rt_id_ex,
    forward_a => forward_a,
    forward_b => forward_b
);
END forwarding_tb_arch;


