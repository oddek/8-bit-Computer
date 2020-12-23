----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2020 04:37:51 PM
-- Design Name: 
-- Module Name: ControlUnit - Behavioral
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

entity ControlUnit is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR(7 downto 0);
           alu_opcode : out STD_LOGIC_VECTOR(2 downto 0);
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
end ControlUnit;

architecture Behavioral of ControlUnit is

    type state_type is (halt, init, read_pc, instr_fetch, instr_decode, exe, mem, write_reg);
    signal state_reg, state_next : state_type := instr_fetch;

    constant REG_NOOP_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(0, 3));
    constant REG_INSTR1_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1, 3));
    constant REG_INSTR2_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2, 3));
    constant REG_X_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(3, 3));
    constant REG_Y_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(4, 3));
    constant REG_SR_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(5, 3));
    constant REG_MEM_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(6, 3));

    constant nop : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#00#, 5));
    constant ldw : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#01#, 5));
    constant ldi : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#02#, 5));
    constant stw : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#03#, 5));
    constant add : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#05#, 5));
    constant addu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#06#, 5));
    constant sub : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#07#, 5));
    constant subu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#08#, 5));
    constant jmp : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#09#, 5));
    constant ret : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0A#, 5));
    constant beq : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0B#, 5));
    constant bne : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0C#, 5));
    constant bgt : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0C#, 5));
    constant bge : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0C#, 5));
    constant mov : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0D#, 5));
    constant psh : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0E#, 5));
    constant pul : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0F#, 5));
    constant and : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#10#, 5));
    constant or : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#11#, 5));
    constant not : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#12#, 5));
    constant xor : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#13#, 5));
    constant xnor : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#14#, 5));
    constant sll : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#15#, 5));
    constant srl : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#16#, 5));
    constant mul : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#17#, 5));
    constant div : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#18#, 5));
    constant inl : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#19#, 5));
    constant ini : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#1A#, 5));
    constant mfhi : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#1A#, 5));
    constant mflo : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#1A#, 5));




    type instr_arg is(first_arg, second_arg);
    signal instr_curr, instr_next : instr_arg := first_arg;

    signal instruction_stage, instruction_stage_next : integer := 0;

begin

    process(clk, rst, state_next)
    begin
        if(rst = '1') then
            --Reset everything
            state_reg <= halt;
            instr_curr <= first_arg;
        elsif(falling_edge(clk)) then
            state_reg <= state_next;
            instr_curr <= instr_next;
            instruction_stage <= instruction_stage_next;
        end if;
    end process;


    --Next state logic
    process(state_reg, instr, instr_curr, instruction_stage)
    begin
        --Turning everything off by default:
        alu_out <= '0';
        alu_opcode <= "000";
        pc_load <= '0';
        pc_inc <= '0';
        pc_out <= '0';
        sp_inc <= '0';
        sp_dec <= '0';
        sp_out <= '0';
        reg_load <= REG_NOOP_ADDR;
        reg_out <= REG_NOOP_ADDR;
        mem_load <= '0';
        mem_out <= '0';
        --Dont change current instruction on next cycle, unless explicitly told to do so
        instr_next <= instr_curr;
        state_next <= state_reg;

        case state_reg is
            when halt =>
                --Do nothing forever
                state_next <= init;
            when init =>
                -- pc_out <= '1';
                state_next <= read_pc;
            --Program counter out, memory register in:
                
            when read_pc =>
                reg_load <= REG_MEM_ADDR; 
                pc_out <= '1';
                state_next <= instr_fetch;

            when instr_fetch =>
                --Let address register put current address on addrbus
                --Let memory put current data on bus
                mem_out <= '1';
                --Increment program counter
                pc_inc <= '1';
                --Go back to find next address
                state_next <= read_pc;
                case instr_curr is
                    when first_arg =>
                        reg_load <= REG_INSTR1_ADDR;
                        instr_next <= second_arg;
                    when second_arg =>
                        reg_load <= REG_INSTR2_ADDR;
                        instr_next <= first_arg;
                        state_next <= instr_decode;
                    when others =>
                        
                end case;
            when instr_decode =>
                --Enable instruction decode component
                case instr(7 downto 3) is
                    --On No operation just fetch next instruction
                    when nop =>
                        state_next <= read_pc;
                    --On load word, 
                    when ldw =>
                        case instruction_stage is
                            when 0 =>
                                -- read memory address into memory register
                                reg_load <= REG_MEM_ADDR;
                                reg_out <= REG_INSTR2_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                            when 1 =>
                                reg_load <= instr(2 downto 0);
                                mem_out <= '1';
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;
                    when add =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= "001";
                        state_next <= read_pc;
                    when stw =>
                        case instruction_stage is
                            when 0 =>
                                reg_load <= REG_MEM_ADDR;
                                reg_out <= REG_INSTR2_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                            when 1 =>
                                reg_out <= instr(2 downto 0);

                                mem_load <= '1';
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>
                        end case;
                    when jmp =>
                        case instruction_stage is
                            when 0 =>
                                --load stackpointer into memory register
                                sp_out <= '1';
                                reg_load <= REG_MEM_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                            when 1 =>
                                mem_load <= '1';
                                pc_out <= '1';
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                            when 2 =>
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>

                        end case;
                                

                    when others =>

                end case;
            when exe =>
            --Enable alu with suitable opcode

            when mem =>
            --Write to memory, enable stuff

            when write_reg =>
        --Enable registers
        end case;
    end process;

end architecture;
