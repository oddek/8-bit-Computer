----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2020 11:06:12 AM
-- Design Name: 
-- Module Name: CPU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity CPU is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rw : out STD_LOGIC;
           mem_en : out STD_LOGIC;
           addr : out STD_LOGIC_VECTOR (7 downto 0);
           dataBus : inout STD_LOGIC_VECTOR (7 downto 0));
end CPU;

architecture Behavioral of CPU is


    Component ControlUnit 
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alu_boolean : in STD_LOGIC; 
           instr : in STD_LOGIC_VECTOR(7 downto 0);
           instr2 : in STD_LOGIC_VECTOR(7 downto 0);
           alu_opcode : out STD_LOGIC_VECTOR(4 downto 0);
           alu_out : out STD_LOGIC;
           pc_load : out STD_LOGIC;
           pc_inc : out STD_LOGIC;
           pc_out : out STD_LOGIC;
           sp_inc : out STD_LOGIC;
           sp_dec : out STD_LOGIC;
           sp_out : out STD_LOGIC;
           reg_load : out STD_LOGIC_VECTOR(2 downto 0);
           reg_out : out STD_LOGIC_VECTOR(2 downto 0);
           mem_load : out STD_LOGIC;
           mem_out : out STD_LOGIC);
    end Component;

    --Program counter signals
    signal pc_inc : STD_LOGIC;
    signal pc_load : STD_LOGIC;
    signal pc_en : STD_LOGIC;

    Component ProgramCounter 
        generic(N : integer := 8;
                M : integer := 256);
        Port ( rst 		: in STD_LOGIC;
               clk 		: in STD_LOGIC;
               inc 		: in STD_LOGIC;
               en 		: in STD_LOGIC;
               load     : in STD_LOGIC;
               dataBus	: inout STD_LOGIC_VECTOR (N-1 downto 0));
    end Component;

    --StackPointer signals:
    signal sp_inc, sp_dec, sp_en : STD_LOGIC;

    Component StackPointer 
        generic(N : integer := 4;
                M : integer := 16);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en : in STD_LOGIC;
               inc : in STD_LOGIC;
               dec : in STD_LOGIC;
               q : out STD_LOGIC_VECTOR (7 downto 0));
    end Component;

    --RegisterBank signals
    signal reg_out : STD_LOGIC_VECTOR(2 downto 0);
    signal reg_load : STD_LOGIC_VECTOR(2 downto 0);
    signal reg2AluX, reg2AluY, instr2CU, instr2CU2 : STD_LOGIC_VECTOR(7 downto 0);

    Component RegisterBank 
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
    end Component;

    --ALU signals
    signal alu_opcode : STD_LOGIC_VECTOR(4 downto 0);
    signal alu_en : STD_LOGIC;
    signal alu_boolean : STD_LOGIC;

    Component ALU 
        Generic(code_width : integer := 5;
                data_width : integer := 8);
        Port ( opcode : in STD_LOGIC_VECTOR (code_width-1 downto 0);
               en : STD_LOGIC;
               x : in STD_LOGIC_VECTOR (data_width-1 downto 0);
               y : in STD_LOGIC_VECTOR (data_width-1 downto 0);
               logical_bool : out STD_LOGIC;
               Z : out STD_LOGIC_VECTOR (data_width-1 downto 0));
    end Component;


begin
    --Instantiation CONTROLUNIT
    cu : ControlUnit port map(clk => clk, rst => rst, instr => instr2CU, instr2 => instr2CU2, alu_opcode => alu_opcode, alu_boolean => alu_boolean, alu_out => alu_en, mem_load => rw, mem_out => mem_en, pc_load => pc_load, pc_inc => pc_inc, pc_out => pc_en, reg_load => reg_load, reg_out => reg_out, sp_out => sp_en, sp_inc => sp_inc, sp_dec => sp_dec);

    --Instantiation PROGRAMCOUNTER
    pc : ProgramCounter port map(rst => rst, clk => clk, en => pc_en, inc => pc_inc, load => pc_load, dataBus => dataBus);

    --Instantiation StackPointer
    sp : StackPointer port map(clk => clk, rst => rst, en => sp_en, inc => sp_inc, dec => sp_dec, q => dataBus);

    --Instantiation REGISTERBANK
    registers : RegisterBank port map(clk => clk, rst => rst, reg_out => reg_out, reg_load => reg_load, mem_addr => addr, instr2CU => instr2CU, instr2CU2 => instr2CU2, aluBusX => reg2AluX, aluBusY => reg2AluY, dataBus => dataBus);

    --Instantiation ALU
    aluInst : ALU port map(opcode => alu_opcode, en => alu_en, x => reg2AluX, y => reg2AluY, logical_bool => alu_boolean, Z => dataBus);

end Behavioral;
