LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Exception_Unit_tb IS
END ENTITY Exception_Unit_tb;

ARCHITECTURE tb_arch OF Exception_Unit_tb IS

  -- Component Declaration
  COMPONENT Exception_Unit IS
    PORT (
      Mem_read_en : IN std_logic;
      Mem_write_en : IN std_logic;
      push : IN std_logic;
      pop : IN std_logic;
      Mem_read_en_exception : OUT std_logic;
      Mem_write_en_exception : OUT std_logic;

      mem_address : IN std_logic_vector(15 DOWNTO 0);
      sp : IN std_logic_vector(15 DOWNTO 0);
      pc : IN std_logic_vector(15 DOWNTO 0);
      epc : OUT std_logic_vector(15 DOWNTO 0);

      IF_D_flush : OUT std_logic;
      D_EX_flush : OUT std_logic;
      EX_M_flush : OUT std_logic
    );
  END COMPONENT;

  -- Test Signals
  SIGNAL Mem_read_en : std_logic := '0';
  SIGNAL Mem_write_en : std_logic := '0';
  SIGNAL push : std_logic := '0';
  SIGNAL pop : std_logic := '0';
  SIGNAL Mem_read_en_exception : std_logic;
  SIGNAL Mem_write_en_exception : std_logic;

  SIGNAL mem_address : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sp : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL pc : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL epc : std_logic_vector(15 DOWNTO 0);

  SIGNAL IF_D_flush : std_logic;
  SIGNAL D_EX_flush : std_logic;
  SIGNAL EX_M_flush : std_logic;

  -- Clock period (removed clock signal, but keeping for potential timing control)
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate Exception_Unit
  uut: Exception_Unit
    PORT MAP (
      Mem_read_en => Mem_read_en,
      Mem_write_en => Mem_write_en,
      push => push,
      pop => pop,
      Mem_read_en_exception => Mem_read_en_exception,
      Mem_write_en_exception => Mem_write_en_exception,
      mem_address => mem_address,
      sp => sp,
      pc => pc,
      epc => epc,
      IF_D_flush => IF_D_flush,
      D_EX_flush => D_EX_flush,
      EX_M_flush => EX_M_flush
    );

  -- Stimulus process
  stim_proc: PROCESS
  BEGIN
    -- Test Case 1: Normal Operation Without Exceptions
    mem_address <= x"000A";
    sp <= x"0010";
    pc <= x"0020";
    push <= '0';
    pop <= '0';
    Mem_read_en <= '1';
    Mem_write_en <= '1';
    WAIT FOR clk_period;

    -- Assert expected behavior for Test Case 1
    ASSERT (Mem_read_en_exception = '1' AND Mem_write_en_exception = '1')
      REPORT "Test Case 1 Failed: Normal operation" SEVERITY FAILURE;
    REPORT "Test Case 1 Passed: Normal operation" SEVERITY NOTE;

    -- Test Case 2: Invalid Memory Address Exception
    mem_address <= x"1000"; -- Out of bounds
    WAIT FOR clk_period;

    -- Assert expected behavior for Test Case 2
    ASSERT (Mem_read_en_exception = '0' AND Mem_write_en_exception = '0' AND epc = pc)
      REPORT "Test Case 2 Failed: Invalid memory address exception" SEVERITY FAILURE;
    REPORT "Test Case 2 Passed: Invalid memory address exception" SEVERITY NOTE;

    -- Test Case 3: Stack Full Exception
    mem_address <= x"000A"; -- Valid address
    sp <= x"0000"; -- Stack pointer at lowest address
    push <= '1';
    pop <= '0';
    WAIT FOR clk_period;

    -- Assert expected behavior for Test Case 3
    ASSERT (epc = pc)
      REPORT "Test Case 3 Failed: Stack full exception" SEVERITY FAILURE;
    REPORT "Test Case 3 Passed: Stack full exception" SEVERITY NOTE;
    push <= '0';

    -- Test Case 4: Stack Empty Exception
    sp <= x"0FFF"; -- Stack pointer at highest address
    push <= '0';
    pop <= '1';
    WAIT FOR clk_period;

    -- Assert expected behavior for Test Case 4
    ASSERT (epc = pc)
      REPORT "Test Case 4 Failed: Stack empty exception" SEVERITY FAILURE;
    REPORT "Test Case 4 Passed: Stack empty exception" SEVERITY NOTE;
    pop <= '0';

    -- Final report after all test cases
    REPORT "All test cases passed successfully." SEVERITY NOTE;

    -- Finish simulation
    WAIT FOR 10 * clk_period;
    WAIT;
  END PROCESS;

END ARCHITECTURE tb_arch;
