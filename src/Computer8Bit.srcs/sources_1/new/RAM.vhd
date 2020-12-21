----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2020 12:00:11 PM
-- Design Name: 
-- Module Name: RAM - Behavioral
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

entity RAM is
    Generic(    AddrSize : Integer := 7;
                DataSize : Integer := 8); 
    Port ( clk :            in STD_LOGIC;
           load :    in STD_LOGIC;
           en :      in STD_LOGIC;
           addr :           in STD_LOGIC_VECTOR (AddrSize-1 downto 0);
           dataBus :  inout STD_LOGIC_VECTOR (DataSize-1 downto 0));
end RAM;

architecture Behavioral of RAM is
    type memory_type is array(0 to (2**AddrSize)-1) of std_logic_vector(DataSize-1 downto 0);
    signal memory : memory_type := (others => (others => '1'));
begin
    process(clk, load, addr, memory, dataBus)
    begin
        if(rising_edge(clk)) then
            if(load = '1') then
                memory(to_integer(unsigned(addr))) <= dataBus;
            end if;
        end if;
end process; 

dataBus <= memory(to_integer(unsigned(addr))) when (en = '1') else
           (others => 'Z');
end Behavioral;
