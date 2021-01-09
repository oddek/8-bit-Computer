----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2021 02:49:20 PM
-- Design Name: 
-- Module Name: IO - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en_load : in STD_LOGIC; 
           load_a : in STD_LOGIC;
           load_b : in STD_LOGIC;
           dataBus : in STD_LOGIC_VECTOR(7 downto 0);
           Z_a  : out STD_LOGIC_VECTOR(7 downto 0);
           Z_b  : out STD_LOGIC_VECTOR(7 downto 0));
end IO;

architecture Behavioral of IO is

    signal reg_a : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal reg_b : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin

    process(clk, rst, en_load, load_a, load_b, dataBus)
    begin
        -- dataBus <= (others => 'Z');
        if(rst = '1') then
            reg_a <= (others => '0');
            reg_b <= (others => '0');
        elsif(rising_edge(clk)) then
            if(en_load = '1') then
                if(load_a = '1') then
                    reg_a <= dataBus;
                elsif(load_b = '1') then
                    reg_b <= dataBus;
                end if;
            end if;
        end if;
    end process;
    Z_a <= reg_a;
    Z_b <= reg_b;

end Behavioral;
