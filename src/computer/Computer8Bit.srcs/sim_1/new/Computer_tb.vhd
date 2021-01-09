----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/21/2020 10:40:36 AM
-- Design Name: 
-- Module Name: Computer_tb - Behavioral
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

entity Computer_tb is
	--  Port ( );
	end Computer_tb;

architecture Behavioral of Computer_tb is

	signal clk, rst : STD_LOGIC;
	constant clk_period : time := 10 ps;
	signal seg : STD_LOGIC_VECTOR(7 downto 0);
	signal an : STD_LOGIC_VECTOR(3 downto 0);
	signal JB : STD_LOGIC_VECTOR(7 downto 0);
	signal lcd_rs, lcd_rw, lcd_en : STD_LOGIC;

	Component Computer 
		Port ( clk : in STD_LOGIC;
			   rst : in STD_LOGIC;
			   seg : out STD_LOGIC_VECTOR(7 downto 0);
			   an : out STD_LOGIC_VECTOR(3 downto 0);
			   JB : out STD_LOGIC_VECTOR(7 downto 0);
		lcd_rs, lcd_rw, lcd_en : out STD_LOGIC);
	end Component;

begin
	UUT: Computer
	port map
	(
		clk => clk,
		rst => rst,
		seg => seg,
		an => an,
		JB => JB,
		lcd_rs => lcd_rs,
		lcd_rw => lcd_rw,
		lcd_en => lcd_en
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
		wait for clk_period*1;
		rst <= '0';
		wait for clk_period*100;
		wait;
	end process;

end Behavioral;
