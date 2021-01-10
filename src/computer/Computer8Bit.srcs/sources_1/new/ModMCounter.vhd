
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ModMCounter is
    Generic(N : integer := 7;
            M : Integer := 100);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           q : out STD_LOGIC_VECTOR(N-1 downto 0);
           max_tick : out STD_LOGIC);

end ModMCounter;

architecture Behavioral of ModMCounter is

    signal r_reg, r_next : unsigned(N-1 downto 0) := (others=> '0');
begin

    process(rst, clk)
    begin
        if rst = '1' then
            r_reg <= (others => '0');
        elsif rising_edge(clk) then
            r_reg <= r_next;
        end if;
    end process;

    r_next <= (others => '0') when r_reg = M-1 else
              r_reg + 1;

    q <= std_logic_vector(r_reg);
    max_tick <= '1' when r_reg = M-1 else
                '0';


end Behavioral;
