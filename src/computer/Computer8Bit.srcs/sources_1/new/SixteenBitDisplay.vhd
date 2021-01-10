
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SixteenBitDisplay is
    Port ( sw : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (7 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0));
end SixteenBitDisplay;

architecture Behavioral of SixteenBitDisplay is

    Component HexToSseg 
        Port ( hex : in STD_LOGIC_VECTOR (3 downto 0);
               seg : out STD_LOGIC_VECTOR (7 downto 0));
    end Component;

    Component SixteenToFourMux 
        Port ( x : in STD_LOGIC_VECTOR (15 downto 0);
               sel : in STD_LOGIC_VECTOR (1 downto 0);
               y : out STD_LOGIC_VECTOR (3 downto 0));
    end Component;

    signal sel : STD_LOGIC_VECTOR(1 downto 0);
    signal output : STD_LOGIC_VECTOR(3 downto 0);
    type states is (d0, d1, d2, d3);
    signal d_reg, d_next : states := d0;
    signal counter : integer range 0 to 100000 := 0;

begin
    process(clk, rst)
    begin
        if(rst = '1') then
            d_reg <= d0;
        elsif(rising_edge(clk)) then
            if(counter = 0) then
                d_reg <= d_next;
            end if;
            counter <= counter + 1;
        end if;
    end process;

    process(d_reg)
    begin
        case d_reg is
            when d0 =>
                sel <= "00";
                an <= "1110";
                d_next <= d1;
            when d1 =>
                sel <= "01";
                an <= "1101";
                d_next <= d2;
            when d2 =>
                sel <= "10";
                an <= "1011";
                d_next <= d3;
            when d3 =>
                sel <= "11";
                an <= "0111";
                d_next <= d0;
        end case;
    end process;

    mux : SixteenToFourMux
    port map(x => sw, sel => sel, y => output);

    hexToSsegComp : HexToSseg
    port map(hex => output, seg => seg);

end Behavioral;
