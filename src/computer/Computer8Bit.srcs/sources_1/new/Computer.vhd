----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/20/2020 09:28:05 PM
-- Design Name: 
-- Module Name: Computer - Behavioral
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

entity Computer is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           y : out STD_LOGIC);
end Computer;

architecture Behavioral of Computer is

    --Internal signals
    signal mem_en : STD_LOGIC;
    signal cpu_rw : STD_LOGIC;
    signal dataBus : STD_LOGIC_VECTOR(7 downto 0); 
    signal addrBus : STD_LOGIC_VECTOR(7 downto 0);

    signal romEnable : STD_LOGIC;
    signal ramEnable : STD_LOGIC;

    Component CPU 
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               rw : out STD_LOGIC;
               mem_en : out STD_LOGIC;
               addr : out STD_LOGIC_VECTOR (7 downto 0);
               dataBus : inout STD_LOGIC_VECTOR (7 downto 0));
    end Component;

    Component ROM 
        Generic(AddrSize : Integer := 7;
                DataSize : Integer := 8); 
        Port ( addr :           in STD_LOGIC_VECTOR (AddrSize-1 downto 0);
               en : in STD_LOGIC;
               dataOut :    out STD_LOGIC_VECTOR (Datasize-1 downto 0));
    end Component;

    Component RAM 
        Generic(    AddrSize : Integer := 7;
                    DataSize : Integer := 8); 
        Port ( clk :            in STD_LOGIC;
               load :    in STD_LOGIC;
               en :      in STD_LOGIC;
               addr :           in STD_LOGIC_VECTOR (AddrSize-1 downto 0);
               dataBus :  inout STD_LOGIC_VECTOR (DataSize-1 downto 0));
    end Component;

begin

    --Rom is enabled when mem_en is high and were in the lower address space
    romEnable <= '1' when (mem_en = '1' and addrBus(7) = '0') else
                 '0';

    --Ram is enabled when mem_en is high and were in the upper address space
    ramEnable <= '1' when (mem_en = '1' and addrBus(7) = '1') else
                 '0';


    processor : CPU
    port map
    (
        clk => clk,
        rst => rst,
        rw => cpu_rw,
        mem_en => mem_en,
        addr => addrBus,
        dataBus => dataBus
    );

    readOnlyMem : ROM
    port map
    (
        addr => addrBus(6 downto 0),
        en => romEnable,
        dataOut => dataBus
    );

    writeMem : RAM
    port map
    (
        clk => clk,
        load => cpu_rw,
        en => ramEnable,
        addr => addrBus(6 downto 0),
        dataBus => dataBus
    );


end Behavioral;
