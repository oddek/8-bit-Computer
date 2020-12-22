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
use IEEE.NUMERIC_STD.ALL;

--Opcodes
--ADD 000
--SUB 001
--...

entity ALU is
    Generic(code_width : integer := 3;
            data_width : integer := 8);
    Port ( opcode : in STD_LOGIC_VECTOR (code_width-1 downto 0);
           en : STD_LOGIC;
           x : in STD_LOGIC_VECTOR (data_width-1 downto 0);
           y : in STD_LOGIC_VECTOR (data_width-1 downto 0);
           Z : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end ALU;

architecture Behavioral of ALU is

begin
    Z <= std_logic_vector(signed(x) + signed(y)) when opcode = "001" else
         std_logic_vector(signed(x) - signed(y)) when opcode = "010" else
         (others => 'Z');


end Behavioral;
