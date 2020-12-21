----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/21/2020 03:40:15 PM
-- Design Name: 
-- Module Name: Register_tb - Behavioral
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

entity Register_tb is
--  Port ( );
	end Register_tb;

architecture Behavioral of Register_tb is

	signal clk, rst, en, load : STD_LOGIC;
	constant clk_period : time := 10 ps;
	signal q : STD_LOGIC_VECTOR(7 downto 0);
	signal dataBus : STD_LOGIC_VECTOR(7 downto 0);
	

	Component PIPORegister 
        Generic(data_width : integer := 8);
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               en : in STD_LOGIC;
               load : in STD_LOGIC;
               q : out STD_LOGIC_VECTOR (data_width-1 downto 0);
               dataBus : inout STD_LOGIC_VECTOR (data_width-1 downto 0));
    end Component;
    
begin
	UUT: PIPORegister
	port map
	(
		clk => clk,
		rst => rst,
		en => en,
		load => load,
		q => q,
		dataBus => dataBus
	);


	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	process
	begin
		rst <= '1';
		en <= '0';
		load <= '0';
		
		wait for clk_period*4;
		rst <= '0';
		wait for clk_period*2;
		dataBus <= x"11";
		wait for clk_period/2;
		dataBus <= x"FF";
		load <= '1';
		wait for clk_period/2;
		load <= '0';
		wait for clk_period*100;
		wait;
	end process;

end Behavioral;
