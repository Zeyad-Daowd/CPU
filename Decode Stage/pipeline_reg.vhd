LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY my_nDFF IS
	GENERIC ( n : integer := 8);
	PORT( Clk,Rst,writeEN : IN std_logic;

	d : IN std_logic_vector(n-1 DOWNTO 0);
	q : OUT std_logic_vector(n-1 DOWNTO 0));

END my_nDFF;

ARCHITECTURE b_my_nDFF OF my_nDFF IS
	signal q_temp : std_logic_vector(n-1 downto 0) := (others => '0');
BEGIN
	q <= q_temp;
	PROCESS(clk,rst) IS BEGIN
		IF rst = '1' then
			q_temp <= (others => '0'); 
		elsIF rising_edge(clk) THEN
			IF writeEN = '1' THEN
				q_temp <= d;
			END IF;
		END IF;
	END PROCESS;
END b_my_nDFF;