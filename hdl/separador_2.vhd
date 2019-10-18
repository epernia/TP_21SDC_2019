----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.09.2019 20:19:50
-- Design Name: 
-- Module Name: separador_2 - Behavioral
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

entity separador_2 is
    Port ( vector : in STD_LOGIC_VECTOR(15 downto 0);
           x0 : out STD_LOGIC_VECTOR(7 downto 0);
           y0 : out STD_LOGIC_VECTOR(7 downto 0));
end separador_2;

architecture Behavioral of separador_2 is

begin
    x0 <= vector(15 downto 8);
    y0 <= vector(7 downto 0);
end Behavioral;
