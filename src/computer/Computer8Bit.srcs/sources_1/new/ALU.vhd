----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2020 11:14:44 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
    Generic(code_width : integer := 5;
            data_width : integer := 8);
    Port ( opcode : in STD_LOGIC_VECTOR (code_width-1 downto 0);
           en : STD_LOGIC;
           x : in STD_LOGIC_VECTOR (data_width-1 downto 0);
           y : in STD_LOGIC_VECTOR (data_width-1 downto 0);
           logical_bool : out STD_LOGIC;
           Z : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end ALU;

architecture Behavioral of ALU is

    signal temp : STD_LOGIC_VECTOR(data_width-1 downto 0);
    signal mul_temp : STD_LOGIC_VECTOR((data_width * 2) - 1 downto 0) := (others => '0');

    signal x_signed : signed(x'Range);
    signal y_signed : signed(y'Range);
    signal x_unsigned : unsigned(x'Range);
    signal y_unsigned : unsigned(y'Range);

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

begin
    --Todo: Bytt ut verdier med variabler i case

    x_signed <= signed(x);
    y_signed <= signed(y);
    x_unsigned <= unsigned(x);
    y_unsigned <= unsigned(y);

    process(opcode, x, y, x_signed, y_signed, x_unsigned, y_unsigned, mul_temp)
    begin
        
        case opcode is
            --Noop
            when "00000" =>
                null;
            --Add signed
            when "00001" =>
                temp <= std_logic_vector(x_signed + y_signed); 
            --Add unsigned
            when "00010" =>
                temp <= std_logic_vector(x_unsigned + y_unsigned);
            --Sub signed
            when "00011" =>
                temp <= std_logic_vector(x_signed - y_signed);
            --Sub unsigned
            when "00100" =>
                temp <= std_logic_vector(x_unsigned - y_unsigned);
            -- Equals
            when "00101" =>
                if(x_signed = y_signed) then
                    logical_bool <= '1';
                    temp <= (others => '1');
                else
                    logical_bool <= '0';
                    temp <= (others => '0');
                end if;
            --Greater or equal
            when "00110" =>
                if(x_signed >= y_signed) then
                    logical_bool <= '1';
                    temp <= (others => '1');
                else
                    logical_bool <= '0';
                    temp <= (others => '0');
                end if;
            --Greater than
            when "00111" =>
                if(x_signed > y_signed) then
                    logical_bool <= '1';
                    temp <= (others => '1');
                else
                    temp <= (others => '0');
                    logical_bool <= '0';
                end if;
            -- AND
            when "01000" =>
                temp <= x and y;
            -- OR
            when "01001" =>
                temp <= x or y;
            --NOT X
            when "01010" =>
                temp <= not x;
            --NOT Y
            when "01011" =>
                temp <= not y;
            -- XOR
            when "01100" =>
                temp <= x xor y;
            -- XNOR
            when "01101" =>
                temp <= x xnor y;
            -- SXL (shift X reg left)
            when "01110" =>
                temp <= x(6 downto 0) & '0';
            -- SXR (shift X reg right) 
            when "01111" =>
                temp <= '0' & x(7 downto 1);
            -- SYL (shift Y reg left)
            when "10000" =>
                temp <= y(6 downto 0) & '0';

            --SYR (shift Y reg right)
            when "10001" =>
                temp <= '0' & y(7 downto 1);

            -- MULL (Multiply, return lower bits)
            when "10010" =>
                mul_temp <= std_logic_vector(x_signed * y_signed);
                temp <= mul_temp(7 downto 0);
            -- MULU (Multiply, return upper bits)
            when "10011" =>
                mul_temp <= std_logic_vector(x_signed * y_signed);
                temp <= mul_temp(15 downto 8);
            -- DIVQ, (Divide, return Quotient)
            when "10100" =>
                --TO BE IMPLEMENTED
                temp <= (others => '0');
            -- DIVR (Divide, return remainder)
            when "10101" =>
                --TO BE IMPLEMENTED
                temp <= (others => '0');
            when others =>
        end case;
    end process;

    Z <= temp when en = '1' else
         (others => 'Z');

end Behavioral;
