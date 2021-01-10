
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is
    generic(N : integer := 8;
            M : integer := 128);
    Port ( rst 		: in STD_LOGIC;
           clk 		: in STD_LOGIC;
           en 		: in STD_LOGIC;
           inc : in STD_LOGIC;
           load : in STD_LOGIC;
           dataBus : inout STD_LOGIC_VECTOR (N-1 downto 0));
end ProgramCounter;

architecture Behavioral of ProgramCounter is

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

    --Next state logic
    r_next <= (others => '0') when r_reg = M-1 else
              r_reg + 1;

    --Output logic
    dataBus <= STD_LOGIC_VECTOR(r_reg) when en = '1' else
               (others => 'Z');

end Behavioral;
