----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/18/2020 01:15:38 PM
-- Design Name: 
-- Module Name: PIPORegister - Behavioral
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

entity PIPORegister is
    Generic(data_width : integer := 8);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           load : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (data_width-1 downto 0);
           dataBus : inout STD_LOGIC_VECTOR (data_width-1 downto 0));
end PIPORegister;

architecture Behavioral of PIPORegister is

    signal reg : STD_LOGIC_VECTOR(data_width-1 downto 0) := (others => '0');

begin


    dataBus <= reg when en = '1' else (others => 'Z'); 


    process(clk, rst, en, load, dataBus, reg)
    begin
        -- dataBus <= (others => 'Z');
        if(rst = '1') then
            reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(load = '1') then
                reg <= dataBus;
                -- dataBus <= (others => 'Z');
            end if;
            -- if(en = '1') then
            --     dataBus <= reg;
            -- else
            --     dataBus <= (others => 'Z');
            -- end if;
        end if;
    end process;
    q <= reg;
end Behavioral;
