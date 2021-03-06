
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity StackPointer is
    generic(N : integer := 4;
            M : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           inc : in STD_LOGIC;
           dec : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR (7 downto 0));
end StackPointer;

architecture Behavioral of StackPointer is

    signal r_reg, r_next, r_prev : unsigned(N-1 downto 0) := (others => '0');

begin

    process(rst, clk)
    begin
        if(rst = '1') then
            r_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(inc = '1') then
                r_reg <= r_next;
            elsif(dec = '1') then
                r_reg <= r_prev;
            end if;
        end if;
    end process;


    --Next state logic
    r_next <= (others => '0') when r_reg = M-1 else
              r_reg + 1;

    r_prev <= (others => '1') when r_reg = 0 else
              r_reg - 1;

    q <= "1000" & STD_LOGIC_VECTOR(r_reg) when en = '1' else
         (others => 'Z');

end Behavioral;
