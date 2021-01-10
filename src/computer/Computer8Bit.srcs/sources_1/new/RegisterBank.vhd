
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RegisterBank is
    Generic( addr_width : integer := 3;
             data_width : integer := 8);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           reg_out : in STD_LOGIC_VECTOR(addr_width-1 downto 0);
           reg_load : in STD_LOGIC_VECTOR(addr_width-1 downto 0);
           mem_addr : out STD_LOGIC_VECTOR(7 downto 0);
           instr2CU : out STD_LOGIC_VECTOR(7 downto 0);
           instr2CU2 : out STD_LOGIC_VECTOR(7 downto 0);
           aluBusX : out STD_LOGIC_VECTOR(data_width-1 downto 0);
           aluBusY : out STD_LOGIC_VECTOR(data_width-1 downto 0);
           dataBus : inout STD_LOGIC_VECTOR (data_width-1 downto 0));
end RegisterBank;

architecture Behavioral of RegisterBank is

    Component PIPORegister 
        Generic(data_width : integer := 8);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en : in STD_LOGIC;
               load : in STD_LOGIC;
               q : out STD_LOGIC_VECTOR (data_width-1 downto 0);
               dataBus : inout STD_LOGIC_VECTOR (data_width-1 downto 0));
    end Component;

    --Choosing which register to put on the bus, in any given time
    --value 000 unables all of them
    signal en_instr1, en_instr2, en_x, en_y, en_mem, en_hi, en_lo : STD_LOGIC;
    signal load_instr1, load_instr2, load_x, load_y, load_mem, load_hi, load_lo : STD_LOGIC;

    constant REG_NOOP_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(0, 3));
    constant REG_INSTR1_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1, 3));
    constant REG_INSTR2_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2, 3));
    constant REG_X_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(3, 3));
    constant REG_Y_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(4, 3));
    constant REG_MEM_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(5, 3));
    constant REG_HI_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(6, 3));
    constant REG_LO_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(7, 3));
begin

    --instruction register 1, OPCODE argument, shares bus with register argument
     reg_op : PIPORegister
     generic map(data_width => 5)
     port map(clk => clk, rst => rst, en => en_instr1, load => load_instr1, q => instr2CU(7 downto 3), dataBus => dataBus(7 downto 3));

     --instruction register 1, REGISTER argument, shares bus with opcode argument 
     reg_instr_reg : PIPORegister
     generic map(data_width => 3)
     port map(clk => clk, rst => rst, en => en_instr1, load => load_instr1, q => instr2CU(2 downto 0), dataBus => dataBus(2 downto 0));

     --instruction register 2, ADDRESS argument 
     reg_instr_addr : PIPORegister
     generic map(data_width => 8)
     port map(clk => clk, rst => rst, en => en_instr2, load => load_instr2, q => instr2CU2, dataBus => dataBus);

    --X register
     reg_x : PIPORegister
     port map(clk => clk, rst => rst, en => en_x, load => load_x, q => aluBusX, dataBus => dataBus);

     --Y register
     reg_y : PIPORegister
     port map(clk => clk, rst => rst, en => en_y, load => load_y, q => aluBusY, dataBus => dataBus);

     --MemoryAddress register
     reg_mem : PIPORegister
     generic map(data_width => 8)
     port map(clk => clk, rst => rst, en => en_mem, load => load_mem, q => mem_addr, dataBus => dataBus);

     --HI register
     reg_hi : PIPORegister
     generic map(data_width => 8)
     port map(clk => clk, rst => rst, en => en_hi, load => load_hi, q => open, dataBus => dataBus);

     --LO register
     reg_lo : PIPORegister
     generic map(data_width => 8)
     port map(clk => clk, rst => rst, en => en_lo, load => load_lo, q => open, dataBus => dataBus);


     --Logic for enabling either loading or output from the correct register
     en_instr1 <= '1' when reg_out = REG_INSTR1_ADDR else
                  '0';
     load_instr1 <= '1' when reg_load = REG_INSTR1_ADDR else
                  '0';

     en_instr2 <= '1' when reg_out = REG_INSTR2_ADDR else
                  '0';
     load_instr2 <= '1' when reg_load = REG_INSTR2_ADDR else
                  '0';

     en_x <= '1' when reg_out = REG_X_ADDR else
                  '0';
     load_x <= '1' when reg_load = REG_X_ADDR else
                  '0';

     en_y <= '1' when reg_out = REG_Y_ADDR else
                  '0';
     load_y <= '1' when reg_load = REG_Y_ADDR else
                  '0';
     en_mem <= '1' when reg_out = REG_MEM_ADDR else
                  '0';
     load_mem <= '1' when reg_load = REG_MEM_ADDR else
                  '0';
     en_hi <= '1' when reg_out = REG_HI_ADDR else
              '0';
     load_hi <= '1' when reg_load = REG_HI_ADDR else
                '0';
     en_lo <= '1' when reg_out = REG_LO_ADDR else
              '0';
     load_lo <= '1' when reg_load = REG_LO_ADDR else
                '0';
end Behavioral;

