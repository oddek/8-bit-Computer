----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2021 09:38:08 AM
-- Design Name: 
-- Module Name: IndexRegister - Behavioral
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

entity IndexRegister is
    generic(N : integer := 8;
            M : integer := 256);
    Port ( rst 		: in STD_LOGIC;
           clk 		: in STD_LOGIC;
           en 		: in STD_LOGIC;
           inc : in STD_LOGIC;
           load : in STD_LOGIC;
           dataBus : inout STD_LOGIC_VECTOR (N-1 downto 0));
end IndexRegister;

architecture Behavioral of IndexRegister is

    signal r_reg, r_next : unsigned(N-1 downto 0) := (others => '0');

begin
    process(rst, clk, en, dataBus, load)
    begin
        if(rst = '1') then
            r_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(inc = '1') then
                r_reg <= r_next;
            elsif(load = '1') then
                r_reg <= unsigned(dataBus);
            end if;
        end if;
    end process;

--unsigned(dataBus) when load = '1' else
    --Next state logic
    r_next <= (others => '0') when r_reg = M-1 else
              r_reg + 1;

    dataBus <= STD_LOGIC_VECTOR(r_reg) when en = '1' else
               (others => 'Z');

end Behavioral;
