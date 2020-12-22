----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2020 11:14:44 AM
-- Design Name: 
-- Module Name: RegisterBank - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterBank is
    Generic( addr_width : integer := 3;
             data_width : integer := 8);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           reg_out : in STD_LOGIC_VECTOR(addr_width-1 downto 0);
           reg_load : in STD_LOGIC_VECTOR(addr_width-1 downto 0);
           mem_addr : out STD_LOGIC_VECTOR(7 downto 0);
           instr2CU : out STD_LOGIC_VECTOR(7 downto 0);
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
    signal en_instr1, en_instr2, en_x, en_y, en_sr, en_mem : STD_LOGIC;
    signal load_instr1, load_instr2, load_x, load_y, load_sr, load_mem : STD_LOGIC;

    constant REG_NOOP_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(0, 3));
    constant REG_INSTR1_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1, 3));
    constant REG_INSTR2_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2, 3));
    constant REG_X_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(3, 3));
    constant REG_Y_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(4, 3));
    constant REG_SR_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(5, 3));
    constant REG_MEM_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(6, 3));
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
     port map(clk => clk, rst => rst, en => en_instr2, load => load_instr2, q => open, dataBus => dataBus);

    --X register
     reg_x : PIPORegister
     port map(clk => clk, rst => rst, en => en_x, load => load_x, q => aluBusX, dataBus => dataBus);

     --Y register
     reg_y : PIPORegister
     port map(clk => clk, rst => rst, en => en_y, load => load_y, q => aluBusY, dataBus => dataBus);

     --Status register
     reg_SR : PIPORegister
     port map(clk => clk, rst => rst, en => en_SR, load => load_sr, q => open, dataBus => dataBus);

     --MemoryAddress register
     reg_mem : PIPORegister
     generic map(data_width => 8)
     port map(clk => clk, rst => rst, en => en_mem, load => load_mem, q => mem_addr, dataBus => dataBus);

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
     en_sr <= '1' when reg_out = REG_SR_ADDR else
                  '0';
     load_sr <= '1' when reg_load = REG_SR_ADDR else
                  '0';
     en_mem <= '1' when reg_out = REG_MEM_ADDR else
                  '0';
     load_mem <= '1' when reg_load = REG_MEM_ADDR else
                  '0';


    -- process(reg_out)
    -- begin
    --     en_instr1 <= '0';
    --     en_instr2 <= '0';
    --     en_x <= '0'; 
    --     en_y <= '0';
    --     en_sr <= '0';
    --     en_mem <= '0';
    --     case to_integer(unsigned(reg_out)) is
    --         when REG_INSTR1_ADDR =>
    --             en_instr1 <= '1';
    --         when REG_INSTR2_ADDR =>
    --             en_instr2 <= '1';
    --         when REG_X_ADDR =>
    --             en_x <= '1';
    --         when REG_Y_ADDR =>
    --             en_y <= '1';
    --         when REG_SR_ADDR =>
    --             en_sr <= '1';
    --         when REG_MEM_ADDR =>
    --             en_mem <= '1';
    --         when others =>
    --     end case;
    -- end process;

    -- process(reg_load)
    -- begin
    --     load_instr1 <= '0';
    --     load_instr2 <= '0';
    --     load_x <= '0'; 
    --     load_y <= '0';
    --     load_sr <= '0';
    --     load_mem <= '0';
    --     case to_integer(unsigned(reg_load)) is
    --         when REG_INSTR1_ADDR =>
    --             load_instr1 <= '1';
    --         when REG_INSTR2_ADDR =>
    --             load_instr2 <= '1';
    --         when REG_X_ADDR =>
    --             load_x <= '1';
    --         when REG_Y_ADDR =>
    --             load_y <= '1';
    --         when REG_SR_ADDR =>
    --             load_sr <= '1';
    --         when REG_MEM_ADDR =>
    --             load_mem <= '1';
    --         when others =>
    --     end case;
    -- end process;
end Behavioral;

