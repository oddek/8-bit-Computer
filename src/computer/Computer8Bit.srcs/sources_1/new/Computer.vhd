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
           seg : out STD_LOGIC_VECTOR(7 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           JB : out STD_LOGIC_VECTOR(7 downto 0);
           lcd_rs, lcd_rw, lcd_en : out STD_LOGIC);
end Computer;

architecture Behavioral of Computer is



    --Internal signals
    signal mem_en : STD_LOGIC;
    signal cpu_rw : STD_LOGIC;
    signal dataBus : STD_LOGIC_VECTOR(7 downto 0); 
    signal addrBus : STD_LOGIC_VECTOR(7 downto 0);

    signal romEnable : STD_LOGIC;
    signal ramEnable : STD_LOGIC;

    signal load_io_a, load_io_b : STD_LOGIC;
    signal lcd_a, lcd_b : STD_LOGIC_VECTOR(7 downto 0);

    signal hexDisp : STD_LOGIC_VECTOR(15 downto 0);

    signal global_clk : STD_LOGIC; 

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

    Component SixteenBitDisplay
        Port ( sw : in STD_LOGIC_VECTOR (15 downto 0);
               clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               seg : out STD_LOGIC_VECTOR (7 downto 0);
               an : out STD_LOGIC_VECTOR(3 downto 0));
    end Component;

    Component ModMCounter 
        Generic(N : integer := 7;
                M : Integer := 100);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               q : out STD_LOGIC_VECTOR(N-1 downto 0);
               max_tick : out STD_LOGIC);

    end Component;


    Component IO 
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
                          en_load : in STD_LOGIC; 

               load_a : in STD_LOGIC;
               load_b : in STD_LOGIC;
               dataBus : in STD_LOGIC_VECTOR(7 downto 0);
               Z_a  : out STD_LOGIC_VECTOR(7 downto 0);
               Z_b  : out STD_LOGIC_VECTOR(7 downto 0));
    end Component;




begin

    --Rom is enabled when mem_en is high and were in the lower address space
    romEnable <= '1' when (mem_en = '1' and addrBus(7) = '0') else
                 '0';

    --Ram is enabled when mem_en is high and were in the upper address space
    ramEnable <= '1' when (mem_en = '1' and addrBus(7) = '1') else
                 '0';

    --Display address bus and data bus on seven segment display
    hexDisp(15 downto 8) <= addrBus(7 downto 0);
    hexDisp(7 downto 0) <= dataBus(7 downto 0);

    --Io is currently setup to only work as output, to interface with an lcd display:
    load_io_a <= '1' when addrBus = "11111111" else
                 '0';
    load_io_b <= '1' when addrBus = "11111110" else
                 '0';
    JB <= lcd_b;
    lcd_rs <= lcd_a(5); 
    lcd_rw <= lcd_a(6); 
    lcd_en <= lcd_a(7);



    processor : CPU
    port map
    (
        clk => global_clk,
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
        clk => global_clk,
        load => cpu_rw,
        en => ramEnable,
        addr => addrBus(6 downto 0),
        dataBus => dataBus
    );
    
    

    sseg: SixteenBitDisplay
    port map
    (
        sw => hexDisp,
        clk => clk,
        rst => rst,
        seg => seg,
        an => an
    );


    modMillionCounter : ModMCounter
    generic map
    (
        N => 27,
        M => 1000000
    )
    port map
    (
        clk => clk,
        rst => rst,
        q => open,
        max_tick => global_clk --set as open for simulation
    );
    --Uncomment for simulation
    --global_clk <= clk;
    
    

    io_reg : IO
    port map
    (
        clk => global_clk,
        rst => rst,
        en_load => cpu_rw,
        load_a => load_io_a,
        load_b => load_io_b,
        dataBus => dataBus,
        Z_a => lcd_a,
        Z_b => lcd_b
    );

end Behavioral;
