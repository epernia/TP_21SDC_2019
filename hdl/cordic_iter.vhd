----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:02:10 26/07/2019 
-- Design Name: 
-- Module Name:    cordic_iter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordic_iter is
	generic(N     : natural := 16;
	        SHIFT : natural := 1);
	port(clk  : in  std_logic;
	     rst  : in  std_logic;
	     xi   : in  std_logic_vector(N - 1 downto 0);
	     yi   : in  std_logic_vector(N - 1 downto 0);
	     zi   : in  std_logic_vector(N - 1 downto 0);
	     ci   : in  std_logic_vector(N - 1 downto 0);
	     xip1 : out std_logic_vector(N - 1 downto 0);
	     yip1 : out std_logic_vector(N - 1 downto 0);
	     zip1 : out std_logic_vector(N - 1 downto 0));
end cordic_iter;

architecture Behavioral of cordic_iter is

begin
	zip1 <= std_logic_vector(signed(zi) - signed(ci)) when (signed(yi) < 0) else
			  std_logic_vector(signed(zi) + signed(ci));
	xip1 <= std_logic_vector(signed(xi) - signed(shift_right(signed(yi),SHIFT))) when (signed(yi) < 0) else
		     std_logic_vector(signed(xi) + signed(shift_right(signed(yi),SHIFT)));
	yip1 <= std_logic_vector(signed(yi) + signed(shift_right(signed(xi),SHIFT))) when (signed(yi) < 0) else
		     std_logic_vector(signed(yi) - signed(shift_right(signed(xi),SHIFT)));
end Behavioral;

