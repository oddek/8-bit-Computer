
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HexToSseg is
    Port ( hex : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (7 downto 0));
end HexToSseg;

architecture Behavioral of HexToSseg is

begin
    
    seg(7) <= '1';

    process(hex)
    begin
        case hex is
            when "0000" => -- 0
                seg(6 downto 0) <= "1000000";
            when "0001" => -- 1
                seg(6 downto 0) <=  "1111001";
            when "0010" => -- 2
                seg(6 downto 0) <=  "0100100";
            when "0011" => -- 3
                seg(6 downto 0) <=  "0110000";
            when "0100" => --4
                seg(6 downto 0) <=  "0011001";
            when "0101" => --5
                seg(6 downto 0) <=  "0010010";
            when "0110" => -- 6
                seg(6 downto 0) <=  "0000010";
            when "0111" => -- 7
                seg(6 downto 0) <=  "1111000";
            when "1000" => -- 8	
                seg(6 downto 0) <=  "0000000";
            when "1001" => -- 9
                seg(6 downto 0) <=  "0010000";
            when "1010" => -- 10 | A
                seg(6 downto 0) <=  "0001000";
            when "1011" => -- 11|B
                seg(6 downto 0) <=  "0000011";
            when "1100" => -- 12 |C
                seg(6 downto 0) <=  "1000110";
            when "1101" => -- 13 |D
                seg(6 downto 0) <=  "0100001";
            when "1110" => -- 14 |E
                seg(6 downto 0) <=  "0000110";
            when others => -- 15 | F
                seg(6 downto 0) <=  "0001110";
        end case;

    end process;
end Behavioral;
