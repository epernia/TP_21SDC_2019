----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2019 17:10:49
-- Design Name: 
-- Module Name: separador - Behavioral
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

entity separador is
    Port ( mod_in : in STD_LOGIC_VECTOR(8-1 downto 0);
           fase_in : in STD_LOGIC_VECTOR(8-1 downto 0);
           valid_in : std_logic;
           modulo : out STD_LOGIC_VECTOR(8-1 downto 0);
           fase : out STD_LOGIC_VECTOR(8-1 downto 0));
end separador;

architecture Behavioral of separador is

begin
    modulo <= mod_in;
    fase   <= not fase_in;

end Behavioral;
