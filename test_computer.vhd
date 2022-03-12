library ieee;
use ieee.std_logic_1164.all;

entity test_computer is
end test_computer;

architecture test of test_computer is
	component computer is
		generic(N : integer := 16;
				M : integer := 3);
		port(clk, reset, OE : in std_logic;
			PIO : out std_logic_vector(N-1 downto 0));
	end component;
	
	signal clk, reset, OE : std_logic := '0';
	signal PIO : std_logic_vector(7 downto 0);
begin
	DUT : computer
		port map ( 	clk => clk,
					reset => reset,
					OE => OE,
					PIO => PIO);
	
	clk <= not(clk) after 5 ns;
	reset <= '1' after 2 ns, '0' after 11 ns;
	OE <= '1' after 11 ns;
end test;
