
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ControlUnit is
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
           ip_load : out STD_LOGIC;
           ip_inc : out STD_LOGIC;
           ip_out : out STD_LOGIC;
           sp_inc : out STD_LOGIC;
           sp_dec : out STD_LOGIC;
           sp_out : out STD_LOGIC;
           reg_load : out STD_LOGIC_VECTOR(2 downto 0);
           reg_out : out STD_LOGIC_VECTOR(2 downto 0);
           mem_load : out STD_LOGIC;
           mem_out : out STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is

    --A lot of these states arent necessary anymore, and the ones that are necessary should be renamed
    type state_type is (halt, init, read_pc, instr_fetch, instr_decode, exe, mem, write_reg);
    signal state_reg, state_next : state_type := instr_fetch;

    --Addressess for activating approriate register from registerbank
    constant REG_NOOP_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(0, 3));
    constant REG_INSTR1_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1, 3));
    constant REG_INSTR2_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2, 3));
    constant REG_X_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(3, 3));
    constant REG_Y_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(4, 3));
    constant REG_MEM_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(5, 3));
    constant REG_HI_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(6, 3));
    constant REG_LO_ADDR : STD_LOGIC_VECTOR(2 downto 0) := STD_LOGIC_VECTOR(to_unsigned(7, 3));

    --Instructions
    constant nop : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#00#, 5));
    constant ldw : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#01#, 5));
    constant ldi : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#02#, 5));
    constant stw : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#03#, 5));
    constant add : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#04#, 5));
    constant addu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#05#, 5));
    constant sub : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#06#, 5));
    constant subu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#07#, 5));
    constant jmp : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#08#, 5));
    constant ret : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#09#, 5));
    constant beq : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0A#, 5));
    constant bne : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0B#, 5));
    constant bgt : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0C#, 5));
    constant bge : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0D#, 5));
    constant mov : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0E#, 5));
    constant psh : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0F#, 5));
    constant pul : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#10#, 5));
    constant and_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#11#, 5));
    constant or_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#12#, 5));
    constant not_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#13#, 5));
    constant xor_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#14#, 5));
    constant xnor_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#15#, 5));
    constant sll_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#16#, 5));
    constant srl_logical : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#17#, 5));
    constant mul : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#18#, 5));
    constant div : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#19#, 5));
    constant inl : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#1A#, 5));
    constant ini : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#1B#, 5));

    --Alu opcodes
    constant alu_nop : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#00#, 5));
    constant alu_add : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#01#, 5));
    constant alu_addu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#02#, 5));
    constant alu_sub : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#03#, 5));
    constant alu_subu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#04#, 5));
    constant alu_equ : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#05#, 5));
    constant alu_eqg : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#06#, 5));
    constant alu_gre : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#07#, 5));
    constant alu_and : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#08#, 5));
    constant alu_or : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#09#, 5));
    constant alu_notx : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0A#, 5));
    constant alu_noty : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0B#, 5));
    constant alu_xor : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0C#, 5));
    constant alu_xnor : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0D#, 5));
    constant alu_sxl : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0E#, 5));
    constant alu_sxr : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#0F#, 5));
    constant alu_syl : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#10#, 5));
    constant alu_syr : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#11#, 5));
    constant alu_mull : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#12#, 5));
    constant alu_mulu : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#13#, 5));
    constant alu_divq : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#14#, 5));
    constant alu_divr : STD_LOGIC_VECTOR(4 downto 0) := std_logic_vector(to_unsigned(16#15#, 5));

    --State machine for knowing which arguments of the instruction were reading at the moment
    type instr_arg is(first_arg, second_arg);
    signal instr_curr, instr_next : instr_arg := first_arg;

    --Necessary for separating the execution of the instruction into separate clock cycles
    signal instruction_stage, instruction_stage_next : integer := 0;

begin

    process(clk, rst, state_next)
    begin
        if(rst = '1') then
            --Reset everything
            state_reg <= halt;
            instr_curr <= first_arg;
            instruction_stage <= 0;
        elsif(falling_edge(clk)) then
            state_reg <= state_next;
            instr_curr <= instr_next;
            instruction_stage <= instruction_stage_next;
        end if;
    end process;


    --Next state logic
    process(state_reg, instr, instr2, instr_curr, instruction_stage, alu_boolean)
    begin
        --Turning everything off by default:
        alu_out <= '0';
        alu_opcode <= "00000";
        pc_load <= '0';
        pc_inc <= '0';
        pc_out <= '0';
        ip_load <= '0';
        ip_out <= '0';
        ip_inc <= '0';
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
        instruction_stage_next <= instruction_stage;

        case state_reg is
            when halt =>
                --Do nothing forever
                state_next <= init;
            when init =>
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
            --This part should really be renamed, at it decodes and executes instructions
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
                                state_next <= instr_decode;
                            when 1 =>
                                reg_load <= instr(2 downto 0);
                                mem_out <= '1';
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;
                    when ldi =>
                        -- Load constant, only needs to load value from instruction reg 2, into register chosen in argument
                        reg_load <= instr(2 downto 0);
                        reg_out <= REG_INSTR2_ADDR;
                        state_next <= read_pc;
                    when stw =>
                        case instruction_stage is
                            when 0 =>
                                reg_load <= REG_MEM_ADDR;
                                reg_out <= REG_INSTR2_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                reg_out <= instr(2 downto 0);

                                mem_load <= '1';
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>
                        end case;
                    when add =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_add;
                        state_next <= read_pc;
                    when addu =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_add;
                        state_next <= read_pc;
                    when sub =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_sub;
                        state_next <= read_pc;
                    when subu =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_subu;
                        state_next <= read_pc;
                    when jmp =>
                        case instruction_stage is
                            when 0 =>
                                --load stackpointer into memory register
                                sp_out <= '1';
                                reg_load <= REG_MEM_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- Write programcounter value to memory at stackpointer location
                                mem_load <= '1';
                                pc_out <= '1';
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 2 =>
                                --Load program counter with address from jmp argument
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>

                        end case;
                    when ret =>
                        case instruction_stage is
                            when 0 =>
                                --Decrement stackpointer
                                sp_dec <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- Read stackpointer into memory register
                                sp_out <= '1';
                                reg_load <= REG_MEM_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 2 =>
                                pc_load <= '1';
                                mem_out <= '1';
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                                
                        end case;
                    when beq =>
                        case instruction_stage is
                            when 0 =>
                                alu_opcode <= alu_equ;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- If it returns false, we go to next line in program counter
                                if(alu_boolean = '0') then
                                    instruction_stage_next <= 0;
                                    state_next <= read_pc;
                                else
                                    --If not we have to do the jump
                                    --load stackpointer into memory register
                                    sp_out <= '1';
                                    reg_load <= REG_MEM_ADDR;
                                    instruction_stage_next <= instruction_stage + 1;
                                    state_next <= instr_decode;
                                end if;
                            --We only get two case 2 if previous if failed.
                            when 2 =>
                                -- Write programcounter value to memory at stackpointer location
                                mem_load <= '1';
                                pc_out <= '1';
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 3 =>
                                --Load program counter with address from jmp argument
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                           when others =>
                        end case;
                    when bne =>
                        case instruction_stage is
                            when 0 =>
                                alu_opcode <= alu_equ;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- If it returns true, we go to next line in program counter
                                if(alu_boolean = '1') then
                                    instruction_stage_next <= 0;
                                    state_next <= read_pc;
                                else
                                    --If not we have to do the jump
                                    --load stackpointer into memory register
                                    sp_out <= '1';
                                    reg_load <= REG_MEM_ADDR;
                                    instruction_stage_next <= instruction_stage + 1;
                                    state_next <= instr_decode;
                                end if;
                            --We only get two case 2 if previous if failed.
                            when 2 =>
                                -- Write programcounter value to memory at stackpointer location
                                mem_load <= '1';
                                pc_out <= '1';
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 3 =>
                                --Load program counter with address from jmp argument
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>
                        end case;

                    when bgt =>
                        case instruction_stage is
                            when 0 =>
                                alu_opcode <= alu_gre;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- If it returns true, we go to next line in program counter
                                if(alu_boolean = '0') then
                                    instruction_stage_next <= 0;
                                    state_next <= read_pc;
                                else
                                    --If not we have to do the jump
                                    --load stackpointer into memory register
                                    sp_out <= '1';
                                    reg_load <= REG_MEM_ADDR;
                                    instruction_stage_next <= instruction_stage + 1;
                                    state_next <= instr_decode;
                                end if;
                            --We only get two case 2 if previous if failed.
                            when 2 =>
                                -- Write programcounter value to memory at stackpointer location
                                mem_load <= '1';
                                pc_out <= '1';
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 3 =>
                                --Load program counter with address from jmp argument
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>
                        end case;

                    when bge =>
                        case instruction_stage is
                            when 0 =>
                                alu_opcode <= alu_eqg;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- If it returns true, we go to next line in program counter
                                if(alu_boolean = '0') then
                                    instruction_stage_next <= 0;
                                    state_next <= read_pc;
                                else
                                    --If not we have to do the jump
                                    --load stackpointer into memory register
                                    sp_out <= '1';
                                    reg_load <= REG_MEM_ADDR;
                                    instruction_stage_next <= instruction_stage + 1;
                                    state_next <= instr_decode;
                                end if;
                            --We only get two case 2 if previous if failed.
                            when 2 =>
                                -- Write programcounter value to memory at stackpointer location
                                mem_load <= '1';
                                pc_out <= '1';
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 3 =>
                                --Load program counter with address from jmp argument
                                pc_load <= '1';
                                reg_out <= REG_INSTR2_ADDR;
                                state_next <= read_pc;
                                instruction_stage_next <= 0;
                            when others =>
                        end case;

                    when mov =>
                        reg_load <= instr(2 downto 0);
                        reg_out <= instr2(2 downto 0);
                        state_next <= read_pc;
                    when psh =>
                        case instruction_stage is
                            when 0 =>
                                --load stackpointer into memory register
                                sp_out <= '1';
                                reg_load <= REG_MEM_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- Write register value to memory at stackpointer location
                                mem_load <= '1';
                                reg_out <= instr(2 downto 0);
                                -- Increment stackpointer
                                sp_inc <= '1';
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;

                    when pul =>
                        case instruction_stage is
                            when 0 =>
                                --Decrement stackpointer
                                sp_dec <= '1';
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                -- Read stackpointer into memory register
                                sp_out <= '1';
                                reg_load <= REG_MEM_ADDR;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 2 =>
                                -- REad contents of memory at stackpointer into register from argument
                                reg_load <= instr(2 downto 0);
                                mem_out <= '1';
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;

                    when and_logical =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_and;
                        state_next <= read_pc;
                    when or_logical =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_or;
                        state_next <= read_pc;
                    when not_logical =>
                        if(instr(2 downto 0) = REG_X_ADDR) then
                            alu_opcode <= alu_notx;
                            reg_load <= REG_X_ADDR;
                        else
                            alu_opcode <= alu_noty;
                            reg_load <= REG_Y_ADDR;
                        end if;
                        alu_out <= '1';
                        state_next <= read_pc;
                    when xor_logical =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_xor;
                        state_next <= read_pc;
                    when xnor_logical =>
                        reg_load <= instr(2 downto 0);
                        alu_out <= '1';
                        alu_opcode <= alu_xnor;
                        state_next <= read_pc;
                    when sll_logical =>
                        --First figure out if it is X or Y reg we want to shift
                        if(instr(2 downto 0) = REG_X_ADDR) then
                            alu_opcode <= alu_sxl;
                        else
                            alu_opcode <= alu_syl;
                        end if;
                        -- Read from alu back into the same register
                        alu_out <= '1';
                        reg_load <= instr(2 downto 0);
                        state_next <= read_pc;
                    when srl_logical =>
                        --First figure out if it is X or Y reg we want to shift
                        if(instr(2 downto 0) = REG_X_ADDR) then
                            alu_opcode <= alu_sxr;
                        else
                            alu_opcode <= alu_syr;
                        end if;
                        -- Read from alu back into the same register
                        alu_out <= '1';
                        reg_load <= instr(2 downto 0);
                        state_next <= read_pc;

                    when mul =>
                        case instruction_stage is 
                            when 0 =>
                                reg_load <= REG_HI_ADDR;
                                alu_out <= '1';
                                alu_opcode <= alu_mulu;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                reg_load <= REG_LO_ADDR;
                                alu_out <= '1';
                                alu_opcode <= alu_mull;
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;
                    when div =>
                        case instruction_stage is 
                            when 0 =>
                                reg_load <= REG_HI_ADDR;
                                alu_out <= '1';
                                alu_opcode <= alu_divq;
                                instruction_stage_next <= instruction_stage + 1;
                                state_next <= instr_decode;
                            when 1 =>
                                reg_load <= REG_LO_ADDR;
                                alu_out <= '1';
                                alu_opcode <= alu_divr;
                                instruction_stage_next <= 0;
                                state_next <= read_pc;
                            when others =>
                        end case;
                    when inl =>
                        --Load instruction
                        ip_load <= '1';
                        reg_out <= REG_INSTR2_ADDR;
                        state_next <= read_pc;
                    when ini =>
                        ip_inc <= '1';
                        state_next <= read_pc;

                    when others =>
                end case;
            --These two states arent necessary i think
            when exe =>
            --Enable alu with suitable opcode

            when mem =>
            --Write to memory, enable stuff

            when write_reg =>
        --Enable registers
        end case;
    end process;

end architecture;
