----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:02:10 26/07/2019 
-- Design Name: 
-- Module Name:    cordic - Behavioral 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cordic is
generic (N : natural := 16;
			ITER : natural := 8 );
			
port (clk : in std_logic;
		rst,valid_in : in std_logic;
		valid_out : out std_logic;
		x0  : in std_logic_vector (7 downto 0);
		y0  : in std_logic_vector (7 downto 0);
		zn  : out std_logic_vector (3 downto 0));
end cordic;

architecture Behavioral of cordic is

component cordic_iter is
generic (N : natural := 16;
			SHIFT : natural := 1 );
port ( 	clk	: in std_logic;
			rst   : in std_logic;
			xi 	: in std_logic_vector (N-1 downto 0);
			yi		: in std_logic_vector (N-1 downto 0);
			zi		: in std_logic_vector (N-1 downto 0);
			ci		: in std_logic_vector (N-1 downto 0);
			xip1	: out std_logic_vector (N-1 downto 0);
			yip1	: out std_logic_vector (N-1 downto 0);
			zip1	: out std_logic_vector (N-1 downto 0));
end component;

type ConnectVector is array(ITER-1 downto 0) of std_logic_vector(N-1 downto 0);
signal wirex, wirey, wirez : ConnectVector;

signal x0in, y0in, znout, offset, index : std_logic_vector(N-1 downto 0);

type atanLUT_t is array (0 to ITER-1) of std_logic_vector(N-1 downto 0);
constant atanLUT : atanLUT_t := (
	std_logic_vector(to_unsigned(100,N)),
	std_logic_vector(to_unsigned(59 ,N)),
	std_logic_vector(to_unsigned(31 ,N)),
	std_logic_vector(to_unsigned(15 ,N)),
	std_logic_vector(to_unsigned(7  ,N)),
	std_logic_vector(to_unsigned(3  ,N)),
	std_logic_vector(to_unsigned(1  ,N)),
	std_logic_vector(to_unsigned(0  ,N))
	);

	--Registro de entrada
	signal x_reg,y_reg : std_logic_vector (7 downto 0);
	signal valid_reg : std_logic;

	--Registro de salida
	signal z_reg : std_logic_vector (3 downto 0);
	
	

begin
	
	--Registro de entrada
	process(clk,rst)
	begin
	
		if (clk'event and clk='1')
		then
			if (rst='1')
			then
				x_reg<= (others=> '0');
			   y_reg<= (others=> '0');
				valid_reg <= '0';
				
			elsif (valid_in='1')
			then
				x_reg<= x0;
				y_reg<= y0; 
				valid_reg<= valid_in;
			elsif (valid_in='0')
			then
				valid_reg<='0';
			end if;
		end if;
	end process;
	
	--Registro de salida
	
	process(clk,rst)
	begin
	
		if (clk'event and clk='1')
		then
			if (rst='1')
			then
				zn<= (others=> '0');
			   valid_out <= '0';
				
			elsif (valid_reg='1')
			then
				zn <= z_reg;
				valid_out<= valid_reg;
			elsif (valid_reg='0')
			then
				valid_out<='0';
			end if;
		end if;
	end process;
	
	quadrant_correction:
	x0in(7 downto 0) <= x_reg when (signed(x_reg) >= 0) else
		     y_reg when (signed(y_reg) >= 0) else
			  std_logic_vector(unsigned(not(y_reg)) + 1);
	
	x0in(N-1 downto 8) <= (others => '0') when (x0in(7) = '0') else
								 (others => '1');

	y0in(7 downto 0) <= y_reg when (signed(x_reg) >= 0) else
		     std_logic_vector(unsigned(not(x_reg)) + 1) when (signed(y_reg)>=0) else
		     x_reg;
	y0in(N-1 downto 8) <= (others => '0') when (y0in(7) = '0') else
	                      (others => '1');
	
	offset <= std_logic_vector(to_signed(201,N)) when  ((signed(x_reg)<0) and (signed(y_reg)>=0)) else
		       std_logic_vector(to_signed(-201,N)) when ((signed(x_reg)<0) and (signed(y_reg)<0)) else
				 (others => '0');
	
	generic_inst:
	for j in 0 to ITER-1 generate
	begin
		it0:
		if j = 0 generate
		begin
			iter0: cordic_iter
			generic map(N,0)
			port map(
				clk => clk,
				rst => rst,
				xi => x0in,
				yi => y0in,
				zi => (others => '0'),
				ci => atanLUT(0),
				xip1 => wirex(0),
				yip1 => wirey(0),
				zip1 => wirez(0)
			);
		end generate;
		itj:
		if j>0 and j<(ITER-1) generate
		begin
			iterj: cordic_iter
			generic map(N,j)
			port map(
				clk => clk,
				rst => rst,
				xi => wirex(j-1),
				yi => wirey(j-1),
				zi => wirez(j-1),
				ci => atanLUT(j),
				xip1 => wirex(j),
				yip1 => wirey(j),
				zip1 => wirez(j)
			);
		end generate;
		itM_1:
		if j=(ITER-1) generate
		begin
			iterM_1: cordic_iter
			generic map(N,j)
			port map(
				clk => clk,
				rst => rst,
				xi => wirex(j-1),
				yi => wirey(j-1),
				zi => wirez(j-1),
				ci => atanLUT(j),
				xip1 => open,
				yip1 => open,
				zip1 => znout
			);
		end generate;
	end generate;
	
	index <= std_logic_vector(signed(znout) + signed(offset));
	
	z_reg <= "0000" when ((signed(index) >= 0) and (signed(index) < 50)) else
			"0001" when ((signed(index) >= 50) and (signed(index) < 100)) else
			"0010" when ((signed(index) >= 100) and (signed(index) < 150)) else
			"0011" when ((signed(index) >= 150) and (signed(index) < 200)) else
			"0100" when ((signed(index) >= 200) and (signed(index) < 250)) else
			"0101" when ((signed(index) >= 250) and (signed(index) < 300)) else
			"0110" when ((signed(index) >= 300) and (signed(index) < 350)) else
			"0111" when ((signed(index) >= 350) and (signed(index) < 400)) else
			"1111" when ((signed(index) < 0) and (signed(index) > -50)) else
			"1110" when ((signed(index) <= -50) and (signed(index) > -100)) else
			"1101" when ((signed(index) <= -100) and (signed(index) > -150)) else
			"1100" when ((signed(index) <= -150) and (signed(index) > -200)) else
			"1011" when ((signed(index) <= -200) and (signed(index) > -250)) else
			"1010" when ((signed(index) <= -250) and (signed(index) > -300)) else
			"1001" when ((signed(index) <= -300) and (signed(index) > -350)) else
			"1000";
end Behavioral;
