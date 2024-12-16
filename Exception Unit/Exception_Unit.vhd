LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.Math_Utils.ALL;

ENTITY Exception_Unit IS 
  PORT (
    Mem_read_en : IN std_logic; -- read enable from inst.
    Mem_write_en : IN std_logic; -- write enable from inst.
    push : IN std_logic; -- 1 for push inst.
    pop : IN std_logic; -- 1 for pop inst.
    Mem_read_en_exception : OUT std_logic; -- read enable from excep.
    Mem_write_en_exception : OUT std_logic; -- write enable from excep.

    mem_address : IN std_logic_vector(15 DOWNTO 0); -- memory address to be accessed
    sp : IN std_logic_vector(15 DOWNTO 0); -- stack pointer
    pc : IN std_logic_vector(15 DOWNTO 0); -- program counter of current inst.
    epc : OUT std_logic_vector(15 DOWNTO 0); -- epc "=pc if exception found"

    -- FLUSH FETCH IF STACK EXCEPTION
    -- FLUSH F/D/E IF MEMORY EXCEPTION 
    IF_D_flush : OUT std_logic;
    D_EX_flush : OUT std_logic;
    EX_M_flush : OUT std_logic;

    -- CHOOSE PC = SUITABLE EXCEPTION HANDLER 
    pc_sel :OUT std_logic_vector(1 DOWNTO 0) -- 00 "NO" 01 "INVALID ADDRESS" 10 "EMPTY STACK" 11 "FULL STACK"
  );
END ENTITY Exception_Unit;

ARCHITECTURE excep_arch OF Exception_Unit IS

  SIGNAL invalid_address : std_logic := '0'; -- Indicates invalid memory address exception
  SIGNAL stack_full       : std_logic := '0'; -- Indicates stack full exception
  SIGNAL stack_empty      : std_logic := '0'; -- Indicates stack empty exception
BEGIN

  -- Exception detection logic
  PROCESS (mem_address, sp, push, pop, Mem_read_en, Mem_write_en)
  BEGIN
    -- Default values
    invalid_address <= '0';
    stack_full <= '0';
    stack_empty <= '0';

    -- Invalid memory address exception: Check if memory address is out of bounds
    IF (unsigned(mem_address) > x"0FFF") THEN
      invalid_address <= '1';
    END IF;

    -- Stack full exception: Occurs if push is attempted while stack pointer is at the lowest address (0x0000)
    IF (push = '1' AND sp = x"0000") THEN
      stack_full <= '1';
    END IF;

    -- Stack empty exception: Occurs if pop is attempted while stack pointer is at the highest address (0x0FFF)
    IF (pop = '1' AND sp = x"0FFF") THEN
      stack_empty <= '1';
    END IF;
  END PROCESS;

  PROCESS (invalid_address, stack_full, stack_empty, Mem_read_en, Mem_write_en, pc)
  BEGIN
    Mem_read_en_exception <= Mem_read_en;
    Mem_write_en_exception <= Mem_write_en;
    epc <= (OTHERS => '0');
    IF_D_flush <= '0';
    D_EX_flush <= '0';
    EX_M_flush <= '0';
    pc_sel <= "00";
    
    IF (invalid_address = '1') THEN
      Mem_read_en_exception <= '0';
      Mem_write_en_exception <= '0';
      IF_D_flush <= '1';
      D_EX_flush <= '1';
      EX_M_flush <= '1';
      pc_sel <= "01";
      epc <= pc;
    END IF;
    IF (stack_full = '1') THEN
      epc <= pc;
      IF_D_flush <= '1';
      pc_sel <= "11";
    END IF;
    IF (stack_empty = '1') THEN
      epc <= pc;
      IF_D_flush <= '1';
      pc_sel <= "10";
    END IF;
  END PROCESS;

END ARCHITECTURE excep_arch;
