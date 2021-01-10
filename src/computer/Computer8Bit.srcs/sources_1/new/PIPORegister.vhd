
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

    process(clk, rst, en, load, dataBus, reg)
    begin
        -- dataBus <= (others => 'Z');
        if(rst = '1') then
            reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(load = '1') then
                reg <= dataBus;
            end if;
        end if;
    end process;

    --Output on dataBus only when enabled
    dataBus <= reg when en = '1' else (others => 'Z'); 

    --Always output on q
    q <= reg;

end Behavioral;
