LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Memory_Stage IS 
  PORT (
    clk : IN std_logic;
    rst : IN std_logic;

    Mem_reg : IN std_logic; -- write back to memory or to reg
    RegWrite : IN std_logic; -- is there a write back or not
    Mem_read_en : IN std_logic; -- read enable from inst.
    Mem_write_en : IN std_logic; -- write enable from inst.
    Mem_read_en_exception : IN std_logic; -- read enable from excep.
    Mem_write_en_exception : IN std_logic; -- write enable from excep.
    PC : IN std_logic_vector(15 DOWNTO 0); -- PC + 1
    FLAGS : IN std_logic_vector(15 DOWNTO 0); -- FLAGS to be stored in memory (INT)
    SP : IN std_logic_vector(15 DOWNTO 0); --     SP     OR    SP+1
    SP_SEC : IN std_logic_vector(15 DOWNTO 0); -- SP-1   OR    SP+2
    R_Rsrc : IN std_logic_vector(15 DOWNTO 0); -- reg data may be written to memory
    Data_back : IN std_logic_vector(15 DOWNTO 0); -- calculated offset from ALU
    mem_address : IN std_logic; -- MUX Selector to choose address "sp or offset"
    Mem_write_data : IN std_logic; -- MUX Selector to choose data "(pc or flags) or reg data"

    Rdst : IN std_logic_vector(2 DOWNTO 0); -- Rdst of inst.
    -- FLAGS_WR : IN std_logic_vector(2 DOWNTO 0); -- in case of popping flags ??
    Mem_Data_Out : OUT std_logic_vector(15 DOWNTO 0); -- data out from memory

    -- needed to be passed to Mem-WB Reg
    Mem_reg_Out : OUT std_logic;
    RegWrite_Out : OUT std_logic;
    Data_back_Out : OUT std_logic_vector(15 DOWNTO 0);
    -- FLAGS_WR_Out : OUT std_logic_vector(2 DOWNTO 0);  -- ??

    PC_Out : OUT std_logic; -- when popping pc
    Flags_Out : OUT std_logic; -- when popping flags

    -- Call
    -- Flags_reserved
    -- RET
    Call : IN std_logic;
    INT : IN std_logic;
    RET : IN std_logic;
    RTI : IN std_logic);

END ENTITY Memory_Stage;

ARCHITECTURE mem_arch OF Memory_Stage IS
  COMPONENT MUX_2_INPUT
    PORT (
    sel : IN std_logic; -- Selector input (1 bit)
    data_in0 : IN std_logic_vector(15 DOWNTO 0); -- Input 0 (16 bits)
    data_in1 : IN std_logic_vector(15 DOWNTO 0); -- Input 1 (16 bits)
    data_out : OUT std_logic_vector(15 DOWNTO 0) -- Output (16 bits)
  );
  END COMPONENT;

  COMPONENT Data_Memory IS
    PORT (
        clk: in std_logic; 
        read_enable: in std_logic;  
        read_address: in std_logic_vector(15 downto 0); 
        mem_data_out: out std_logic_vector(15 downto 0); 
        write_enable: in std_logic;  
        write_address: in std_logic_vector(15 downto 0); 
        write_data: in std_logic_vector(15 downto 0) 
  );
  END COMPONENT;

  SIGNAL mem_data_out_tmp : std_logic_vector(15 DOWNTO 0);

  -- Signals for MUX outputs
  SIGNAL mem_selected_address : std_logic_vector(15 DOWNTO 0);
  SIGNAL mem_selected_data : std_logic_vector(15 DOWNTO 0);
  SIGNAL sp_selected : std_logic_vector(15 DOWNTO 0);

  SIGNAL flags_pc : std_logic_vector(15 DOWNTO 0); -- selected flags / pc

  SIGNAL sp_sel : std_logic; -- MUX Selector to choose sp "sp or sp_sec"
  SIGNAL flags_pc_sel : std_logic; -- MUX Selector to choose flags or pc
  SIGNAL counter : std_logic_vector(1 DOWNTO 0) := "00";  -- 00 default 01 first cycle for "int or rti" 10 second cycle

  SIGNAL write_enable_signal : std_logic;
  SIGNAL read_enable_signal : std_logic;
BEGIN

  -- Update control signals based on INT, RTI, CALL, and RET conditions
  control_logic: PROCESS(INT, RTI, CALL, RET, clk,rst)
  BEGIN
    IF rst = '1' THEN
      sp_sel <= '0';
      counter <= "00";
      flags_pc_sel <= '0';
    ELSIF clk = '1' THEN
      sp_sel <= '0';
      flags_pc_sel <= '0';
      counter <= "00";
      IF CALL = '1' OR RET = '1' THEN -- call and ret chooses sp and pc 
          sp_sel <= '0';
          flags_pc_sel <= '1';
        END IF;
      IF INT = '1' THEN
        IF counter = "00" THEN -- int first cycle chooses sp and flags
          sp_sel <= '0';
          flags_pc_sel <= '0';
          counter <= "01";
        ELSIF counter = "01" THEN -- int second cycle chooses sp_sec and pc
          sp_sel <= '1';
          flags_pc_sel <= '1';
          counter <= "10";
        END IF;
      END IF;
      IF RTI = '1' THEN
        IF counter = "00" THEN -- rti first cycle chooses sp and pc
          sp_sel <= '0';
          flags_pc_sel <= '1';
          counter <= "01";
        ELSIF counter = "01" THEN -- rti second cycle chooses sp_sec and flags
          sp_sel <= '1';
          flags_pc_sel <= '0';
          counter <= "10";
        END IF;
      END IF;
    END IF;
  END PROCESS;

  -- MUX for SP selection
  sp_mux: MUX_2_INPUT
    PORT MAP (
      sel => sp_sel,
      data_in0 => SP,
      data_in1 => SP_SEC,
      data_out => sp_selected
    );

  -- MUX for memory address selection
  address_mux: MUX_2_INPUT
    PORT MAP (
      sel => mem_address,
      data_in0 => Data_back,
      data_in1 => sp_selected,
      data_out => mem_selected_address
    );

-- MUX for memory write flags or pc (in case of INT RTI)
  flags_pc_mux: MUX_2_INPUT
    PORT MAP (
      sel => flags_pc_sel,
      data_in0 => FLAGS,
      data_in1 => PC,
      data_out => flags_pc
    );

  -- MUX for memory write data selection (flags_pc or R_Rsrc)
  data_mux: MUX_2_INPUT
    PORT MAP (
      sel => Mem_write_data,
      data_in0 => R_Rsrc,
      data_in1 => flags_pc,
      data_out => mem_selected_data
    );

  write_enable_signal <= Mem_write_en AND Mem_write_en_exception;
  read_enable_signal <= Mem_read_en AND Mem_read_en_exception;

  dm0: Data_Memory PORT MAP(
        clk => clk,
        read_enable => read_enable_signal,
        read_address => mem_selected_address,
        mem_data_out => mem_data_out_tmp,
        write_enable => write_enable_signal,
        write_address => mem_selected_address,
        write_data => mem_selected_data
    );

  -- Process for handling memory read and write operations
  memory_operations: PROCESS(clk, rst)
  BEGIN
    IF rst = '1' THEN
      -- Reset all outputs and memory
      Mem_Data_Out <= (OTHERS => '0');
      Mem_reg_Out <= '0';
      RegWrite_Out <= '0';
      Data_back_Out <= (OTHERS => '0');
      -- FLAGS_WR_Out <= (OTHERS => '0');
      PC_Out <= '0';
      Flags_Out  <= '0';
    ELSIF rising_edge(clk) THEN
      if RET = '1' THEN
        PC_Out <= '1';
      END IF;
      if RTI = '1' THEN
        if flags_pc_sel = '1' THEN
          PC_Out <= '1';
        ELSIF flags_pc_sel = '0' THEN
          Flags_Out <= '1';
        END IF;
      END IF;
      Mem_Data_Out <= mem_data_out_tmp;

      -- Pass-through signals
      Data_back_Out <= Data_back;
      RegWrite_Out <= RegWrite;
      -- FLAGS_WR_Out <= FLAGS_WR;
      Mem_reg_Out <= Mem_reg;
    END IF;
  END PROCESS;

END ARCHITECTURE mem_arch;

