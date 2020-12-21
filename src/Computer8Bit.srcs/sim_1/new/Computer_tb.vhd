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

	signal clk, rst, y : STD_LOGIC;
	constant clk_period : time := 10 ps;

	Component Computer 
		Port ( clk : in STD_LOGIC;
			   rst : in STD_LOGIC;
			   y : out STD_LOGIC);
	end Component;

begin
	UUT: Computer
	port map
	(
		clk => clk,
		rst => rst,
		y => y
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
