LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MUX_2_INPUT IS
  PORT (
    sel : IN std_logic; -- Selector input (1 bit)
    data_in0 : IN std_logic_vector(15 DOWNTO 0); -- Input 0 (16 bits)
    data_in1 : IN std_logic_vector(15 DOWNTO 0); -- Input 1 (16 bits)
    data_out : OUT std_logic_vector(15 DOWNTO 0) -- Output (16 bits)
  );
END ENTITY MUX_2_INPUT;

ARCHITECTURE behav OF MUX_2_INPUT IS
BEGIN
  PROCESS(sel, data_in0, data_in1)
  BEGIN
    IF sel = '0' THEN
      data_out <= data_in0;
    ELSE
      data_out <= data_in1;
    END IF;
  END PROCESS;
END ARCHITECTURE behav;
