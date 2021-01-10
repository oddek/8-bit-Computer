
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SixteenToFourMux is
    Port ( x : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0);
           y : out STD_LOGIC_VECTOR (3 downto 0));
end SixteenToFourMux;

architecture Behavioral of SixteenToFourMux is

begin
    y <= x(3 downto 0) when sel = "00" else
         x(7 downto 4) when sel = "01" else
         x(11 downto 8) when sel = "10" else
         x(15 downto 12);
end Behavioral;
