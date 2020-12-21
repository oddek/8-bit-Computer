----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2020 01:25:08 PM
-- Design Name: 
-- Module Name: ROM - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
     
entity ROM is
    Generic(AddrSize : Integer := 7;
            DataSize : Integer := 8); 
    Port ( addr :           in STD_LOGIC_VECTOR (AddrSize-1 downto 0);
           en : in STD_LOGIC;
           dataOut :    out STD_LOGIC_VECTOR (Datasize-1 downto 0));
end ROM; 

architecture Behavioral of ROM is

    type memory_type is array(0 to (2**AddrSize)-1) of std_logic_vector(DataSize-1 downto 0);

    impure function getFile(fileName : string) return memory_type is
        file fileHandle : TEXT open READ_MODE is FileName;
        variable currentLine : LINE;
        variable tempWord : STD_LOGIC_VECTOR(DataSize - 1 downto 0);
        variable result : memory_type := (others => (others => '0'));
        variable lineNumber : integer := 0;
    begin
        while not endFile(fileHandle) loop
            readline(fileHandle, currentLine);
            read(currentLine, tempWord);
            result(lineNumber) := tempWord;
            lineNumber := lineNumber + 1;
        end loop;
        return result;
    end function;
    
    signal memory : memory_type := getFile("../../../../input.bin");

begin
    dataOut <= memory(to_integer(unsigned(addr))) when en = '1' else
               (others => 'Z');
end Behavioral;
